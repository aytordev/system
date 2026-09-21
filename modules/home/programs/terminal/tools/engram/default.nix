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
    package = lib.mkPackageOption pkgs "engram" {
      default = [
        "aytordev"
        "engram"
      ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
    home.sessionVariables = {
      ENGRAM_BIN = lib.getExe cfg.package;
      ENGRAM_DATA_DIR = "${config.xdg.dataHome}/engram";
      ENGRAM_NO_UPDATE_CHECK = "1";
    };
  };
}
