{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.dircolors;
in {
  options.aytordev.programs.terminal.tools.dircolors = {
    enable = lib.mkEnableOption "dircolors";
    package = lib.mkPackageOption pkgs "dircolors" {default = "coreutils";};
  };
  config = lib.mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
      inherit (cfg) package;
    };
  };
}
