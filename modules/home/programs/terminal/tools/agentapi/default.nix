{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.aytordev.programs.terminal.tools.agentapi;
in {
  options.aytordev.programs.terminal.tools.agentapi = {
    enable = mkEnableOption "AgentAPI - HTTP API wrapper for AI coding agents";

    package = mkOption {
      type = types.package;
      default = pkgs.aytordev.agentapi;
      description = "The AgentAPI package to use";
    };

    defaultPort = mkOption {
      type = types.port;
      default = 3284;
      description = "Default port for AgentAPI server instances";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for AgentAPI";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package];

      shellAliases = mkIf cfg.shellAliases {
        agentapi-claude = "agentapi server -p ${toString cfg.defaultPort} -- claude";
        agentapi-gemini = "agentapi server -p ${toString (cfg.defaultPort + 1)} -- gemini";
        agentapi-aider = "agentapi server -p ${toString (cfg.defaultPort + 2)} -- aider";
      };
    };
  };
}
