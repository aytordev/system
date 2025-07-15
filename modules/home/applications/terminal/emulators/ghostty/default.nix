{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optional;
  cfg = config.applications.terminal.emulators.ghostty;

  monaspaceKrypton = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Krypton Var" else "MonaspaceKrypton";
  monaspaceNeon = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Neon Var" else "MonaspaceNeon";
  monaspaceRadon = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Radon Var" else "MonaspaceRadon";
  monaspaceXenon = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Xenon Var" else "MonaspaceXenon";
in {
  options.applications.terminal.emulators.ghostty = {
    enable = mkEnableOption "ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;

      installBatSyntax = pkgs.stdenv.hostPlatform.isLinux;
      installVimSyntax = pkgs.stdenv.hostPlatform.isLinux;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        "adw-toolbar-style" = "flat";
        "background-opacity" = lib.mkDefault 0.8;
        "clipboard-trim-trailing-spaces" = true;
        "copy-on-select" = "clipboard";
        "focus-follows-mouse" = true;
        "font-size" = lib.mkDefault 13;
        "font-family" = lib.mkForce monaspaceNeon;
        "font-family-bold" = lib.mkForce monaspaceXenon;
        "font-family-italic" = lib.mkForce monaspaceRadon;
        "font-family-bold-italic" = lib.mkForce monaspaceKrypton;
        "font-feature" = "+ss01,+ss02,+ss03,+ss04,+ss05,+ss06,+ss07,+ss08,+ss09,+ss10,+liga,+dlig,+calt";
        "gtk-single-instance" = false;
        "macos-titlebar-style" = "hidden";
        "macos-option-as-alt" = true;
        "quit-after-last-window-closed" = true;
        "window-decoration" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;
      };
    };
  };
}
