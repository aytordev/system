{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.engram;
in {
  options.aytordev.programs.terminal.tools.engram = {
    enable = lib.mkEnableOption "engram";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.aytordev.engram
    ];
  };
}
