{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.jq;
in {
  options.applications.terminal.tools.jq = {
    enable = mkEnableOption "jq";
  };
  config = mkIf cfg.enable {
    programs.jq = {
      enable = true;
      package = pkgs.jq;
    };
  };
}
