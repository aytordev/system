{
  sdd-explore = {
    description = "Explore and investigate an idea or feature — reads codebase and compares approaches";
    allowedTools = "Read, Grep, Glob";
    argumentHint = "<topic>";
    agent = "sdd-orchestrator";
    prompt = ''
      Explore the following topic: {argument}

      Launch the sdd-explore sub-agent to investigate the codebase, compare
      multiple approaches, and return a structured analysis.

      This is exploration only — no files or code should be modified.
      Present the analysis to the user when complete.
    '';
  };
}
