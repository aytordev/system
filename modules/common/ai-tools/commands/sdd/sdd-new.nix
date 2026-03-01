{
  sdd-new = {
    description = "Start a new SDD change — runs exploration then creates a proposal";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "<change-name>";
    agent = "sdd-orchestrator";
    prompt = ''
      Start a new SDD change named "{argument}".

      This requires multi-phase coordination (explore → propose). Launch the SDD orchestrator
      to manage the workflow:

      1. Launch sdd-explore sub-agent to investigate the codebase for this change
      2. Present the exploration summary to the user
      3. Launch sdd-propose sub-agent to create a proposal based on the exploration
      4. Present the proposal and ask the user if they want to continue with specs and design

      Follow the dependency graph and present results between phases.
      Do NOT execute phase work inline — always delegate to sub-agents.
    '';
  };
}
