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
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.opencode;

  aiTools = import (lib.getFile "modules/common/ai-tools") {inherit lib;};

  primaryAgents = [
    "sdd-orchestrator"
  ];

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
  imports = [
    ./formatters.nix
    ./lsp.nix
    ./mcp.nix
    ./permission.nix
    ./provider.nix
  ];

  options.aytordev.programs.terminal.tools.opencode = {
    enable = mkEnableOption "OpenCode configuration";
    package = lib.mkPackageOption pkgs "opencode" {nullable = true;};

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
    home.shellAliases = {
      oc = "opencode";
      oc-sonnet = "opencode run -m anthropic/claude-sonnet-4-6";
      oc-opus = "opencode run -m anthropic/claude-opus-4-7";
      oc-haiku = "opencode run -m anthropic/claude-haiku-4-5-20251001";
    };
    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      settings = {
        model = lib.mkDefault cfg.model.model;
        autoshare = false;
        autoupdate = false;

        agent = buildAgentConfigs aiTools.opencode.agentConfigs;
      };

      tui = {
        theme = "opencode";
      };

      inherit (aiTools.opencode) agents commands;

      context = builtins.readFile (lib.getFile "modules/common/ai-tools/base.md");

      # OpenCode is now the primary harness for the shared ai-tools skills
      # (Claude Code/Gemini CLI were removed).
      skills = lib.getFile "modules/common/ai-tools/skills";
    };
  };
}
