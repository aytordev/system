{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;

  cfg = config.aytordev.programs.desktop.browsers.chrome-dev;
in {
  options.aytordev.programs.desktop.browsers.chrome-dev = {
    enable = mkEnableOption "Whether or not to enable Chromium";
    package = mkPackageOption pkgs "google-chrome-dev" {};
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
