{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.databases.dbgate;
in {
  options.aytordev.programs.desktop.databases.dbgate = {
    enable = lib.mkEnableOption "DbGate, the graphical SQL/MongoDB/Redis client";
    package = lib.mkPackageOption pkgs "dbgate" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
