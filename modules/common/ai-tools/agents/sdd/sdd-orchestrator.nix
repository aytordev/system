{
  sdd-orchestrator = {
    name = "sdd-orchestrator";
    description = "SDD Orchestrator - delegates spec-driven development to sub-agents via Task tool";
    tools = ["Read" "Write" "Edit" "Bash" "Grep" "Glob"];
    model = {
      claude = "sonnet";
      opencode = "anthropic/claude-sonnet-4-5-20250929";
    };
    permission = {
      edit = "ask";
      bash = "ask";
    };
    content = builtins.readFile ./sdd-orchestrator.md;
  };
}
