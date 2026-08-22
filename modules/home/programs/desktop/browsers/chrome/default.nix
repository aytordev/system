{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;

  cfg = config.aytordev.programs.desktop.browsers.chrome;
in {
  options.aytordev.programs.desktop.browsers.chrome = {
    enable = mkEnableOption "Whether or not to enable Chromium";
    package = mkPackageOption pkgs "google-chrome" {};
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
