{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;

  cfg = config.aytordev.programs.terminal.tools.pi;
in {
  options.aytordev.programs.terminal.tools.pi = {
    enable = mkEnableOption "Pi coding agent";
    package = mkPackageOption pkgs "pi-coding-agent" {};
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
