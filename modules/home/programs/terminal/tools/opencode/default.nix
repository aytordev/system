{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.opencode;

  aiTools = import (lib.getFile "modules/common/ai-tools") { inherit lib; };

  primaryAgents = [
    "sdd-orchestrator"
  ];

  buildAgentConfigs =
    agentConfigs:
    lib.mapAttrs (
      name: agentConfig:
      agentConfig
      // {
        mode = if builtins.elem name primaryAgents then "primary" else "subagent";
      }
    ) agentConfigs;

in
{
  options.aytordev.programs.terminal.tools.opencode = {
    enable = mkEnableOption "OpenCode configuration";

    model = {
      model = mkOption {
        type = types.str;
        default = "anthropic/claude-sonnet-4-5";
        description = "Default model to use";
      };

      provider = mkOption {
        type = types.str;
        default = "anthropic";
        description = "Default provider for model";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      settings = {
        theme = "opencode";
        model = lib.mkDefault cfg.model.model;
        autoshare = false;
        autoupdate = false;

        agent = buildAgentConfigs aiTools.opencode.agentConfigs;
      };

      inherit (aiTools.opencode) agents commands;

      rules = builtins.readFile (lib.getFile "modules/common/ai-tools/base.md");
    };
  };
}
