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
  };
}
