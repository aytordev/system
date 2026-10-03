{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.rainfrog;
in {
  options.aytordev.programs.terminal.tools.rainfrog = {
    enable = lib.mkEnableOption "rainfrog, the SQL-focused database TUI";
    package = lib.mkPackageOption pkgs "rainfrog" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
