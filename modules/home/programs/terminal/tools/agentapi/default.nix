{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    types
    getExe
    ;

  cfg = config.aytordev.programs.terminal.tools.agentapi;
in
{
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

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for AgentAPI";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      shellAliases = mkIf cfg.shellAliases {
        agentapi-claude = "${getExe cfg.package} server -p ${toString cfg.defaultPort} -- claude";
        agentapi-gemini = "${getExe cfg.package} server -p ${toString (cfg.defaultPort + 1)} -- gemini";
        agentapi-aider = "${getExe cfg.package} server -p ${toString (cfg.defaultPort + 2)} -- aider";
      };
    };
  };
}
