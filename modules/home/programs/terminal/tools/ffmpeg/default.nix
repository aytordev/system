{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.ffmpeg;
in {
  options.aytordev.programs.terminal.tools.ffmpeg = {
    enable = mkEnableOption "ffmpeg";
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.ffmpeg];
  };
}
