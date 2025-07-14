{
  config,
  lib,
  pkgs,
  ...
}: {
  options.applications.terminal.tools.dircolors = {
    enable = lib.mkEnableOption "dircolors";
  };

  config = lib.mkIf config.applications.terminal.tools.dircolors.enable {
    programs.dircolors = {
      enable = true;
    };
  };
}
