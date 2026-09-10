{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.agentapi;
in {
  options.aytordev.programs.terminal.tools.agentapi = {
    enable = mkEnableOption "AgentAPI - HTTP API wrapper for AI coding agents";

    package = mkPackageOption pkgs "agentapi" {
      default = [
        "aytordev"
        "agentapi"
      ];
    };

    defaultPort = mkOption {
      type = types.port;
      default = 3284;
      description = "Default port for AgentAPI server instances";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
