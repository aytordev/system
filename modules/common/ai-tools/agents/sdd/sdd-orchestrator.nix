{lib, ...}: let
  # Canonical model IDs — single source of truth for SDD phase routing.
  # Change a model here and it propagates automatically to the orchestrator prompt.
  sddModels = {
    haiku = "anthropic/claude-haiku-4-5-20251001";
    sonnet = "anthropic/claude-sonnet-4-5-20250929";
  };

  phaseModels = [
    {
      phase = "sdd-init";
      model = sddModels.haiku;
      rationale = "Quick context detection";
    }
    {
      phase = "sdd-explore";
      model = sddModels.sonnet;
      rationale = "Deep codebase analysis";
    }
    {
      phase = "sdd-propose";
      model = sddModels.sonnet;
      rationale = "Structured writing";
    }
    {
      phase = "sdd-spec";
      model = sddModels.sonnet;
      rationale = "Structured writing";
    }
    {
      phase = "sdd-design";
      model = sddModels.sonnet;
      rationale = "Architecture reasoning";
    }
    {
      phase = "sdd-tasks";
      model = sddModels.sonnet;
      rationale = "Structured writing";
    }
    {
      phase = "sdd-apply";
      model = sddModels.sonnet;
      rationale = "Code generation";
    }
    {
      phase = "sdd-verify";
      model = sddModels.sonnet;
      rationale = "Analysis + test execution";
    }
    {
      phase = "sdd-archive";
      model = sddModels.haiku;
      rationale = "Simple file operations";
    }
  ];

  renderModelRow = entry: "| ${entry.phase} | `${entry.model}` | ${entry.rationale} |";
  modelRouterRows = lib.concatMapStringsSep "\n" renderModelRow phaseModels;

  orchestratorContent =
    builtins.replaceStrings
    ["@SDD_MODEL_ROUTER_ROWS@"]
    [modelRouterRows]
    (builtins.readFile ./sdd-orchestrator.md);
in {
  sdd-orchestrator = {
    name = "sdd-orchestrator";
    description = "SDD Orchestrator - delegates spec-driven development to sub-agents via Task tool";
    tools = ["Read" "Write" "Edit" "Bash" "Grep" "Glob"];
    model = {
      claude = "sonnet";
      opencode = sddModels.sonnet;
    };
    permission = {
      edit = "ask";
      bash = "ask";
    };
    content = orchestratorContent;
  };
}
