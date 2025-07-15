{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.git-crypt;
in {
  options.applications.terminal.tools.git-crypt = {
    enable = mkEnableOption "git-crypt - Transparent file encryption in git";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [git-crypt];
  };
}
