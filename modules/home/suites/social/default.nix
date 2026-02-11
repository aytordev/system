{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.aytordev) enabled disabled;

  cfg = config.aytordev.suites.social;
in {
  options.aytordev.suites.social = {
    enable = lib.mkEnableOption "social configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        element-desktop
        # TODO: migrate to darwin after version bump
        slack
        telegram-desktop
      ];

    aytordev = {
      programs = {
        desktop = {
          communications = {
            discord = lib.mkDefault enabled;
            vesktop = lib.mkDefault disabled;
          };
        };
      };
    };
  };
}
