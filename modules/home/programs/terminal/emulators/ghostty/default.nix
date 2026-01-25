{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;

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
    "custom-shader" = "shaders/cursor_smear.glsl";
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

    theme = mkOption {
      type = types.nullOr (types.enum availableThemes);
      default =
        if availableThemes != []
        then config.aytordev.theme.appTheme.kebab
        else null;
      description = "Theme to use for Ghostty. Available themes: ${builtins.concatStringsSep ", " availableThemes}";
    };

    enableThemes = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable theme support";
    };
  };

  config = mkIf cfg.enable (let
    # Combine all settings including theme if specified
    finalSettings =
      baseSettings
      // (
        if cfg.enableThemes && cfg.theme != null
        then {
          "theme" = "${config.xdg.configHome}/ghostty/themes/${cfg.theme}.conf";
        }
        else {}
      );
  in {
    # Add theme symlinks to XDG config if themes are enabled
    xdg.configFile = (lib.mkIf cfg.enableThemes themeSymlinks) // shaderSymlinks;

    programs.ghostty = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;

      installBatSyntax = pkgs.stdenv.hostPlatform.isLinux;
      installVimSyntax = pkgs.stdenv.hostPlatform.isLinux;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = finalSettings;
    };
  });
}
