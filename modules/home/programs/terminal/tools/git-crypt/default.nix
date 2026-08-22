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
    package = lib.mkPackageOption pkgs "git-crypt" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
