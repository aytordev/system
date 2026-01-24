{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.aytordev) enabled;

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
        jankyborders = mkDefault enabled;
      };

      programs.desktop.bars.sketchybar = mkDefault enabled;
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
