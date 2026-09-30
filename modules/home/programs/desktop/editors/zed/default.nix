{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption types;
  themeCfg = config.aytordev.theme;
  cfg = config.aytordev.programs.desktop.editors.zed;

  profile = import ./profile.nix {inherit lib;};
  terminal = import ./terminal.nix {};
  # Synthetic homes need not import either multiplexer capability.
  capabilities = lib.attrByPath ["aytordev" "programs" "terminal" "tools"] {} config;
  terminalShell = terminal.shell {
    inherit capabilities;
    inherit (cfg.terminal) multiplexer;
    helpers = lib.genAttrs ["zellij" "tmux"] (name:
      lib.getExe ((import (../../../terminal/tools + "/${name}/session.nix") {inherit lib;}).build {
        inherit pkgs;
        inherit (capabilities.${name}) package;
      }));
  };
  preferences = import ./preferences.nix {
    inherit lib terminalShell;
    inherit (cfg) package;
  };
  ownedKeymap = import ./keymaps.nix;
  composed = profile.compose {
    ownedSettings = preferences.settings;
    inherit (preferences) excludedSettings;
    ownedKeymaps = ownedKeymap.blocks;
    inherit (ownedKeymap) excludedBindings;
  };

  # Keep the existing pure resolver as the sole appearance authority.
  zedTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  zedIntegration = themeCfg.integrations.${themeCfg.name}.zed or null;
  generatedTheme = zedTheme.render {
    inherit (themeCfg) palette ansi isLight;
  };
  themeResolution = zedTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = zedIntegration;
  };
  themeSettings = zedTheme.themeSetting themeResolution;
  generatedFiles = zedTheme.themeFiles {
    resolution = themeResolution;
    text = generatedTheme;
  };
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum ["auto" "manual" "none"];
        default = "auto";
        description = "auto follows the family integration, manual pins id, none leaves Zed's default.";
      };
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Theme name to pin when mode = \"manual\".";
      };
    };
  };
in {
  # Capability boundary: contained siblings are pure data/helpers, not modules.
  options.aytordev.programs.desktop.editors.zed = {
    enable = mkEnableOption "Whether or not to enable zed-editor";
    package = mkPackageOption pkgs "zed-editor" {};
    terminal.multiplexer = mkOption {
      type = types.enum ["zellij" "tmux" "system"];
      default = "zellij";
      description = ''
        Workspace-named terminal session helper. Falls back to the system shell
        when the selected multiplexer capability is absent, disabled, or has no
        package. Select system to opt out; the login shell is never changed.
      '';
    };
    theme = mkOption {
      type = types.nullOr (types.either types.str themeOverrideType);
      default = null;
      description = ''
        Zed theme override. Null follows `aytordev.theme` through the integration
        resolver. A bare theme name, or `{ mode = "manual"; id = ...; }`, pins a
        theme; `{ mode = "none"; }` leaves Zed's own default.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      inherit (cfg) package;
      # Ordinary HM list definitions remain additive; mkForce replaces the list.
      inherit (preferences) extensions;
      userSettings =
        (lib.recursiveUpdate (profile.defaultLeaves composed.settings) preferences.safety)
        // themeSettings;
      userKeymaps = composed.keymaps;
    };
    xdg.configFile = generatedFiles;
  };
}
