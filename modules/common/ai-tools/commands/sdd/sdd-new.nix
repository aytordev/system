{
  sdd-new = {
    description = "Start a new SDD change — runs exploration then creates a proposal";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "<change-name>";
    agent = "sdd-orchestrator";
    prompt = ''
      Start a new SDD change named "{argument}".

      1. Launch sdd-explore sub-agent to investigate the codebase for this change
      2. Present exploration results to the user
      3. Launch sdd-propose sub-agent to create a proposal
      4. Present the proposal and ask to continue with specs/design

      Follow the dependency graph: explore → propose.
    '';
  };
}
