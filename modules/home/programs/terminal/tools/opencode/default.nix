{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aytordev.programs.terminal.tools.opencode;

  aiTools = import (lib.getFile "modules/common/ai-tools") {inherit lib;};

  # Primary agents: most commonly used, Tab-switchable in OpenCode
  primaryAgents = [
    "sdd-orchestrator"
  ];

  # Add mode (primary vs subagent) to each agent config
  buildAgentConfigs = agentConfigs:
    lib.mapAttrs (
      name: agentConfig:
        agentConfig
        // {
          mode =
            if builtins.elem name primaryAgents
            then "primary"
            else "subagent";
        }
    )
    agentConfigs;
in {
  options.aytordev.programs.terminal.tools.opencode = {
    enable = mkEnableOption "OpenCode configuration";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      settings = {
        theme = "opencode";
        model = "anthropic/claude-sonnet-4-5";
        autoshare = false;
        autoupdate = false;

        # Agent configurations with model, tools, and permissions
        agent = buildAgentConfigs aiTools.opencode.agentConfigs;
      };

      inherit (aiTools.opencode) agents commands;

      rules = builtins.readFile (lib.getFile "modules/common/ai-tools/base.md");
    };
  };
}
