{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.gentle-ai;
in {
  options.aytordev.programs.terminal.tools.gentle-ai = {
    enable = mkEnableOption "the official Gentle AI CLI and native installer prerequisites";
    package = mkPackageOption pkgs "gentle-ai" {
      default = ["aytordev" "gentle-ai"];
    };
  };

  config = mkIf cfg.enable {
    # The native installer uses npm; Pi's transitive Node closure is not PATH.
    home.packages = [cfg.package pkgs.nodejs];
    home.sessionVariables.GENTLE_AI_NO_SELF_UPDATE = "1";
  };
}
