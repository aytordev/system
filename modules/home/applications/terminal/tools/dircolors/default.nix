{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aytordev.applications.terminal.tools.dircolors = {
    enable = lib.mkEnableOption "dircolors";
  };
  config = lib.mkIf config.aytordev.applications.terminal.tools.dircolors.enable {
    applications.dircolors = {
      enable = true;
    };
  };
}
