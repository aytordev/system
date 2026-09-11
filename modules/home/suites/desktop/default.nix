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
      programs = {
        desktop = {
          bars = {
            sketchybar = {
              enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
              items = {
                menus.enable = mkDefault true;
                themePicker.enable = mkDefault true;
                pomodoro.enable = mkDefault true;
              };
            };
          };
          browsers = {
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

    # Deploy apps as read-only symlinks (linkApps) rather than writable copies
    # (copyApps). Writable copies let apps like Raycast self-update past the
    # nixpkgs version, migrate their DBs, then nix reverts the app → schema
    # mismatch → "Failed to start". Immutable symlinks force updates to come
    # from a nix rebuild, keeping DBs consistent with the installed version.
    targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      copyApps.enable = mkDefault false;
      linkApps.enable = mkDefault true;
    };
  };
}
