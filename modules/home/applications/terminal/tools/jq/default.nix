{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.applications.terminal.tools.jq;
in {
  options.aytordev.applications.terminal.tools.jq = {
    enable = mkEnableOption "jq";
  };
  config = mkIf cfg.enable {
    applications.jq = {
      enable = true;
      package = pkgs.jq;
    };
  };
}
