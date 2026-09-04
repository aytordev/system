{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.lazydocker;
in {
  options.aytordev.programs.terminal.tools.lazydocker = {
    enable = mkEnableOption "lazydocker";
    package = mkPackageOption pkgs "lazydocker" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    home.shellAliases = {
      dcd = "docker-compose down";
      dcu = "docker-compose up -d";
      dim = "docker images";
      dps = "docker ps";
      dpsa = "docker ps -a";
      dsp = "docker system prune --all";
    };
  };
}
