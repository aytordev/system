{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.hunk;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution (official exact when the family ships a Hunk theme,
  # otherwise a palette-generated `[custom_theme]` block).
  hunkTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeResolution = hunkTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeCfg.integrations.${themeCfg.name}.hunk or null;
  };

  generatedTheme = hunkTheme.render {
    inherit (themeCfg) palette ansi;
  };

  configText = hunkTheme.configText {
    resolution = themeResolution;
    generated = generatedTheme;
  };

  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated block, manual pins id, none leaves Hunk's default.";
      };
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Theme id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.hunk = {
    enable = mkEnableOption "hunk diff viewer";
    package = mkPackageOption pkgs "hunk" {};

    theme = mkOption {
      type = types.nullOr (types.either types.str themeOverrideType);
      default = null;
      description = ''
        Hunk theme override. Null follows `aytordev.theme` through the hybrid
        resolver: the family's official `[custom_theme]` block when it covers the
        active variant (Sora), otherwise a palette-generated block. A bare id (or
        `{ mode = "manual"; id = ...; }`) pins a selection; `{ mode = "none"; }`
        leaves Hunk's own default.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    # Hunk reads `~/.config/hunk/config.toml`; a repo `.hunk/config.toml` still
    # wins at runtime. The generated config disables Hunk's view-preference save
    # prompt because this file is a read-only store symlink.
    xdg.configFile."hunk/config.toml".text = configText;
  };
}
