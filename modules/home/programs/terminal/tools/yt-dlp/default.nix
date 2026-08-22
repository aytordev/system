{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.yt-dlp;
in {
  options.aytordev.programs.terminal.tools.yt-dlp = {
    enable = mkEnableOption "yt-dlp";
    package = lib.mkPackageOption pkgs "yt-dlp" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
