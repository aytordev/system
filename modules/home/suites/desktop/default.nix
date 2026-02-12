{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.suites.desktop;
in {
  options.aytordev.suites.desktop = {
    enable = lib.mkEnableOption "common desktop applications";
  };

  config = mkIf cfg.enable {
    aytordev = {
      theme = {
        enable = true;
        variant = "wave";
      };

      programs = {
        desktop = {
          bars = {
            sketchybar = enabled;
          };
          browsers = {
            brave = enabled;
            chrome = enabled;
            chrome-dev = enabled;
            chromium = enabled;
            firefox = enabled;
          };
          launchers = {
            raycast.enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
          };
          window-manager-system = {
            aerospace.enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
          };
        };
      };

      services = {
        jankyborders = enabled;
      };
    };

    home.packages = with pkgs; [
      # TODO: Add more packages
    ];

    targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };
}
