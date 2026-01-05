{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.programs.desktop.browsers.chrome-dev;
in {
  options.aytordev.programs.desktop.browsers.chrome-dev = {
    enable = mkEnableOption "Whether or not to enable Chromium";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.google-chrome-dev
    ];
  };
}
