{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.suites.social;
in
{
  options.aytordev.suites.social = {
    enable = lib.mkEnableOption "social configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        element-desktop
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        # TODO: migrate to darwin after version bump
        slack
        telegram-desktop
      ];

    aytordev = {
      programs = {
        desktop = {
          communications = {
            vesktop = lib.mkDefault enabled;
          };
        };
      };
    };
  };
}
