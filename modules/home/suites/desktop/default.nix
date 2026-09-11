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

    home = {
      packages = with pkgs; [
        # TODO: Add more packages
      ];

      file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        "Pictures/screenshots/.keep".text = "";
      };

      # copyApps writes the bundles but does not register them with LaunchServices,
      # so "open -a" / default-app associations can lag. Re-register as the user on
      # every activation so new apps are discoverable immediately.
      activation.registerMacApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          apps_dir="${config.home.homeDirectory}/Applications/Home Manager Apps"
          if [ -d "$apps_dir" ]; then
            /usr/bin/find "$apps_dir" -maxdepth 1 -name '*.app' \
              -exec /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f {} + >/dev/null 2>&1 || true
          fi
        ''
      );
    };

    # Deploy apps as real copies (copyApps), not symlinks. Symlinked bundles
    # resolve into /nix/store, which Spotlight/Launchpad/Raycast do not index,
    # so new apps stayed invisible until launched once. copyApps writes real
    # bundles into "~/Applications/Home Manager Apps" (home-manager's default
    # for stateVersion >= 25.11). Tradeoff: copies are writable, so an app that
    # self-updates can drift from the nixpkgs version until the next switch;
    # disable per-app auto-update (e.g. Raycast) to avoid the schema mismatch.
    targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      copyApps.enable = mkDefault true;
      linkApps.enable = mkDefault false;
    };
  };
}
