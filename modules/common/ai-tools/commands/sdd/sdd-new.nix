{
  sdd-new = {
    description = "Start a new SDD change — runs exploration then creates a proposal";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "<change-name>";
    agent = "sdd-orchestrator";
    prompt = ''
      Start a new SDD change named "$ARGUMENTS".

      This requires multi-phase coordination (explore → propose). Launch the SDD orchestrator
      to manage the workflow:

      1. Launch sdd-explore sub-agent to investigate the codebase for this change
      2. Present the exploration summary to the user
      3. Launch sdd-propose sub-agent to create a proposal based on the exploration
      4. In interactive mode, present the proposal and ask whether to continue
         with specs and design; in automatic mode, continue and report at the
         next mandatory pause (see _shared/execution-modes.md)

      Follow the dependency graph and present results between phases.
      Do NOT execute phase work inline — always delegate to sub-agents.
    '';
  };
}
