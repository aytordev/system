{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.applications.desktop.communications.discord;

  # Check if betterdiscordctl is available for the current platform
  betterdiscordctlAvailable =
    pkgs.betterdiscordctl.meta.available or false
    && (pkgs.betterdiscordctl.meta.platforms or [])
    ++ (pkgs.betterdiscordctl.meta.badPlatforms or [])
    == [];
in {
  options.aytordev.applications.desktop.communications.discord = {
    enable = mkEnableOption "Discord";
    canary.enable = mkEnableOption "Discord Canary";
    firefox.enable = mkEnableOption "the Firefox version of Discord";
    enableBetterDiscord =
      mkEnableOption "BetterDiscord installation"
      // {
        default = betterdiscordctlAvailable;
        defaultText = lib.literalExpression "true if betterdiscordctl is available on this platform";
        description = ''
          Whether to install and configure BetterDiscord.
          This is only available on platforms where betterdiscordctl is supported.
        '';
      };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        if cfg.canary.enable
        then khanelinix.discord-canary
        else if cfg.firefox.enable
        then khanelinix.discord-firefox
        else discord
      )
    ];

    home.activation = mkIf (cfg.enableBetterDiscord && betterdiscordctlAvailable) {
      betterdiscordInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Running betterdiscord install"
        ${lib.getExe pkgs.betterdiscordctl} install || ${lib.getExe pkgs.betterdiscordctl} reinstall || true
      '';
    };
  };
}
