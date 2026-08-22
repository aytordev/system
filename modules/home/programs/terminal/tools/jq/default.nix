{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.jq;
in {
  options.aytordev.programs.terminal.tools.jq = {
    enable = mkEnableOption "jq";
    package = lib.mkPackageOption pkgs "jq" {};
  };
  config = mkIf cfg.enable {
    programs.jq = {
      enable = true;
      inherit (cfg) package;
    };
  };
}
