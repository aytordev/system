{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.git-crypt;
in {
  options.aytordev.programs.terminal.tools.git-crypt = {
    enable = mkEnableOption "git-crypt - Transparent file encryption in git";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [git-crypt];
  };
}
