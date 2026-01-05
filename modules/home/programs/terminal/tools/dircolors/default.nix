{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aytordev.programs.terminal.tools.dircolors = {
    enable = lib.mkEnableOption "dircolors";
  };
  config = lib.mkIf config.aytordev.programs.terminal.tools.dircolors.enable {
    programs.dircolors = {
      enable = true;
    };
  };
}
