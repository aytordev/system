{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;

  cfg = config.aytordev.suites.desktop;
in {
  options.aytordev.suites.desktop = {
    enable = lib.mkEnableOption "common desktop applications";
  };

  config = mkIf cfg.enable {
    aytordev = {
      theme = {
        enable = mkDefault true;
        variant = mkDefault "wave";
      };

      programs = {
        desktop = {
          bars = {
            sketchybar = {
              enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
              items = {
                menus.enable = true;
                themePicker.enable = true;
                pomodoro.enable = true;
              };
            };
          };
          browsers = {
            brave.enable = mkDefault true;
            chrome.enable = mkDefault true;
            chrome-dev.enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
            chromium.enable = mkDefault true;
            firefox.enable = mkDefault true;
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
        jankyborders.enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
      };
    };

    home.packages = with pkgs; [
      # TODO: Add more packages
    ];

    home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "Pictures/screenshots/.keep".text = "";
    };

    targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };
}
