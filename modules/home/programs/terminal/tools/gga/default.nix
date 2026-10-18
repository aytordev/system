{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.gga;
in {
  options.aytordev.programs.terminal.tools.gga = {
    enable = mkEnableOption "gga (Gentleman Guardian Angel), the provider-agnostic AI code review CLI";
    package = mkPackageOption pkgs "gga" {
      default = ["aytordev" "gga"];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
