{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aytordev.applications.terminal.tools.lazydocker = {
    enable = lib.mkEnableOption "lazydocker";
  };
  config = lib.mkIf config.aytordev.applications.terminal.tools.lazydocker.enable {
    home.packages = with pkgs; [
      lazydocker
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
