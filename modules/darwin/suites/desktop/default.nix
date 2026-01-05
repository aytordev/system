{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.aytordev) enabled disabled;

  cfg = config.aytordev.suites.desktop;
in
{
  options.aytordev.suites.desktop = {
    enable = lib.mkEnableOption "common desktop configuration";
  };

  config = mkIf cfg.enable {
    aytordev = {
      # Enable log rotation for desktop services
      services = {
        protonmail-bridge = mkDefault enabled;
        openssh = mkDefault enabled;
      };

      programs.desktop.bars.sketchybar = mkDefault disabled;
    };

    homebrew = {
      casks = [
        "sf-symbols"
      ];

      masApps = mkIf config.aytordev.tools.homebrew.masEnable {
        # TODO: Add Mac App Store apps
      };
    };
  };
}
