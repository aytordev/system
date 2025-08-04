{
  config,
  lib,
  pkgs,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption mkOption types;

  # Get the path to the themes directory relative to this file
  themesDir = ./themes;

  # Check if themes directory exists
  hasThemes = builtins.pathExists themesDir;

  # List all theme files in the themes directory if it exists
  themeFiles =
    if hasThemes
    then builtins.attrNames (builtins.readDir themesDir)
    else [];

  # Create a list of theme names by removing the .conf extension
  availableThemes = map (file: builtins.replaceStrings [".conf"] [""] file) themeFiles;

  cfg = config.applications.terminal.emulators.ghostty;

  monaspaceKrypton =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Monaspace Krypton Var"
    else "MonaspaceKrypton";
  monaspaceNeon =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Monaspace Neon Var"
    else "MonaspaceNeon";
  monaspaceRadon =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Monaspace Radon Var"
    else "MonaspaceRadon";
  monaspaceXenon =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Monaspace Xenon Var"
    else "MonaspaceXenon";
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

  # Create theme symlinks if themes are enabled
  themeSymlinks =
    if cfg.enableThemes && hasThemes && availableThemes != []
    then builtins.listToAttrs (map mkThemeSymlink availableThemes)
    else {};

  # Base settings for Ghostty
  baseSettings = {
    "adw-toolbar-style" = "flat";
    "background-opacity" = lib.mkDefault 1;
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
    "macos-titlebar-style" = "hidden";
    "macos-option-as-alt" = true;
    "quit-after-last-window-closed" = true;
    "window-decoration" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;
  };

  # Add theme settings if enabled
  themeSettings = lib.optionalAttrs (cfg.enableThemes && cfg.theme != null) {
    "theme" = "${config.xdg.configHome}/ghostty/themes/${cfg.theme}.conf";
  };

  # Combine all settings
  ghosttySettings = baseSettings // themeSettings;
in {
  options.applications.terminal.emulators.ghostty = {
    enable = mkEnableOption "ghostty terminal emulator";

    theme = mkOption {
      type = types.nullOr (types.enum availableThemes);
      default =
        if availableThemes != []
        then "catppuccin-mocha"
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
    xdg.configFile = lib.mkIf cfg.enableThemes themeSymlinks;

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
