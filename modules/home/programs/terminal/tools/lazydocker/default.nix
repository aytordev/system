{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aytordev.programs.terminal.tools.lazydocker = {
    enable = lib.mkEnableOption "lazydocker";
    package = lib.mkPackageOption pkgs "lazydocker" {};
  };
  config = lib.mkIf config.aytordev.programs.terminal.tools.lazydocker.enable {
    home.packages = [
      config.aytordev.programs.terminal.tools.lazydocker.package
    ];
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
