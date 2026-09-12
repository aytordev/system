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
    mkOption
    types
    ;

  # Get the path to the themes directory relative to this file
  themesDir = ./themes;
  shadersDir = ./shaders;

  # Check if themes directory exists
  hasThemes = builtins.pathExists themesDir;
  hasShaders = builtins.pathExists shadersDir;

  # List all theme files in the themes directory if it exists
  themeFiles =
    if hasThemes
    then builtins.attrNames (builtins.readDir themesDir)
    else [];

  # Create a list of theme names by removing the .conf extension
  availableThemes = map (file: builtins.replaceStrings [".conf"] [""] file) themeFiles;

  cfg = config.aytordev.programs.terminal.emulators.ghostty;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution: exact official resource when the active family
  # ships one for the active variant, otherwise the palette-generated conf.
  ghosttyTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  ghosttyIntegration = themeCfg.integrations.${themeCfg.name}.ghostty or null;
  generatedTheme = ghosttyTheme.render {
    inherit (themeCfg) palette ansi;
  };
  themeResolution = ghosttyTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = ghosttyIntegration;
  };

  # Manual override validation: the generated conf is the only theme not
  # vendored, so a bare override (or submodule id) must name a vendored conf.
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated conf, manual pins id, none leaves Ghostty's default.";
      };
      id = mkOption {
        type = types.nullOr (types.enum availableThemes);
        default = null;
        description = "Vendored theme basename to pin when mode = \"manual\".";
      };
    };
  };

  mapleMono =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Maple Mono"
    else "MapleMono";

  # Function to create theme symlinks for XDG
  mkThemeSymlink = theme: {
    name = "ghostty/themes/${theme}.conf";
    value = {
      source = config.lib.file.mkOutOfStoreSymlink "${themesDir}/${theme}.conf";
    };
  };

  # Function to create shader symlinks for XDG
  mkShaderSymlink = shader: {
    name = "ghostty/shaders/${shader}";
    value = {
      source = config.lib.file.mkOutOfStoreSymlink "${shadersDir}/${shader}";
    };
  };

  # Create theme symlinks if themes are enabled
  themeSymlinks =
    if cfg.enableThemes && hasThemes && availableThemes != []
    then builtins.listToAttrs (map mkThemeSymlink availableThemes)
    else {};

  # List all shader files in the shaders directory if it exists
  shaderFiles =
    if hasShaders
    then builtins.attrNames (builtins.readDir shadersDir)
    else [];

  # Create shader symlinks
  shaderSymlinks =
    if hasShaders && shaderFiles != []
    then builtins.listToAttrs (map mkShaderSymlink shaderFiles)
    else {};

  # Base settings for Ghostty
  baseSettings = {
    "adw-toolbar-style" = "flat";
    "background-opacity" = 0.95;
    "background-blur-radius" = 20;
    "clipboard-trim-trailing-spaces" = true;
    "copy-on-select" = "clipboard";
    "focus-follows-mouse" = true;
    "font-size" = lib.mkDefault 16;
    "font-family" = lib.mkForce mapleMono;
    "font-family-bold" = lib.mkForce mapleMono;
    "font-family-italic" = lib.mkForce mapleMono;
    "font-family-bold-italic" = lib.mkForce mapleMono;
    "font-feature" = "+ss01,+ss02,+ss03,+ss04,+ss05,+ss06,+ss07,+ss08,+ss09,+ss10,+liga,+dlig,+calt";
    "gtk-single-instance" = false;
    "gtk-tabs-location" = "hidden";
    "macos-titlebar-style" = "hidden";
    "macos-option-as-alt" = "left";
    "quit-after-last-window-closed" = true;
    "window-decoration" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;
    "window-padding-color" = "extend";
    "window-padding-balance" = true;
    "window-step-resize" = false;
    "window-width" = 100;
    "window-height" = 100;
    "keybind" = [
      "alt+left=unbind"
      "alt+right=unbind"
      "alt+v=new_split:right"
      "alt+d=new_split:down"
      "alt+k=goto_split:up"
      "alt+j=goto_split:down"
      "alt+h=goto_split:left"
      "alt+l=goto_split:right"
      "ctrl+shift+j=resize_split:up,10"
      "ctrl+shift+k=resize_split:down,10"
      "ctrl+shift+h=resize_split:left,10"
      "ctrl+shift+l=resize_split:right,10"
      "cmd+k=clear_screen"
      "shift+enter=text:\\x1b\\r"
      "alt+s=write_screen_file:paste"
    ];
  };
  # Add theme settings if enabled
  # Combine all settings
in {
  options.aytordev.programs.terminal.emulators.ghostty = {
    enable = mkEnableOption "ghostty terminal emulator";

    package = mkOption {
      type = types.nullOr types.package;
      default =
        if pkgs.stdenv.hostPlatform.isDarwin
        then null
        else pkgs.ghostty;
      description = "The Ghostty package to use, or null to use the system installation.";
    };

    theme = mkOption {
      type = types.nullOr (types.either (types.enum availableThemes) themeOverrideType);
      default = null;
      description = ''
        Ghostty theme override. Null follows `aytordev.theme` through the hybrid
        resolver. A bare vendored basename, or `{ mode = "manual"; id = ...; }`,
        pins a theme; `{ mode = "none"; }` leaves Ghostty's own default.
        Vendored themes: ${builtins.concatStringsSep ", " availableThemes}
      '';
    };

    enableThemes = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable theme support";
    };
  };

  config = mkIf cfg.enable (
    let
      # Point the `theme` setting at the resolved conf. Official confs are the
      # vendored symlinks; a generated conf is materialized below.
      themeSettings =
        if cfg.enableThemes && themeResolution.kind != "none"
        then {
          "theme" = "${config.xdg.configHome}/ghostty/themes/${themeResolution.id}.conf";
        }
        else {};

      # The cursor-smear shader ships under the same master switch as themes, so
      # `enableThemes = false` removes both the file and its `custom-shader`
      # setting instead of leaving a dangling reference.
      shaderSettings =
        if cfg.enableThemes
        then {
          "custom-shader" = "shaders/${ghosttyTheme.cursorShader}";
        }
        else {};

      finalSettings = baseSettings // themeSettings // shaderSettings;

      # Materialize the generated conf only when the resolver selected it.
      generatedFiles =
        if cfg.enableThemes
        then
          ghosttyTheme.generatedFile {
            resolution = themeResolution;
            text = generatedTheme;
          }
        else {};
    in {
      # Vendored theme symlinks, generated conf and shaders. Composition is a
      # plain attrset merge via `ghosttyTheme.xdgEntries`; the earlier
      # `lib.mkIf condition attrs // shaderSymlinks` dropped the shader entries.
      xdg.configFile = lib.mkMerge [
        (ghosttyTheme.xdgEntries {
          inherit (cfg) enableThemes;
          themeEntries = themeSymlinks;
          generated = generatedFiles;
          shaderEntries = shaderSymlinks;
        })
      ];

      programs.ghostty = {
        enable = true;
        inherit (cfg) package;

        installBatSyntax = pkgs.stdenv.hostPlatform.isLinux;
        installVimSyntax = pkgs.stdenv.hostPlatform.isLinux;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        settings = finalSettings;
      };
    }
  );
}
