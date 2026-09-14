{
  sdd-continue = {
    description = "Continue the next SDD phase in the dependency chain";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Continue the SDD workflow for the active change (or "$ARGUMENTS" if specified).

      This requires multi-phase coordination. Launch the SDD orchestrator to:

      1. Check which artifacts already exist for the change
      2. Determine the next phase from the dependency graph:
         proposal → [specs ‖ design] → tasks → apply → verify → archive
      3. Launch the appropriate sub-agent(s) for the next phase
         (specs and design can run in parallel if both are needed)
      4. In interactive mode, present results and ask to proceed; in automatic
         mode, continue and report at the next mandatory pause
         (see _shared/execution-modes.md)

      Do NOT execute phase work inline — always delegate to sub-agents.
    '';
  };
}
