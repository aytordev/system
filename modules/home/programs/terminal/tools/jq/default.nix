{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.programs.terminal.tools.jq;
in {
  options.aytordev.programs.terminal.tools.jq = {
    enable = mkEnableOption "jq";
  };
  config = mkIf cfg.enable {
    programs.jq = {
      enable = true;
      package = pkgs.jq;
    };
  };
}
