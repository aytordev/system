{
  sdd-explore = {
    description = "Explore and investigate an idea or feature — reads codebase and compares approaches";
    allowedTools = "Read, Grep, Glob";
    argumentHint = "<topic>";
    agent = "sdd-orchestrator";
    prompt = ''
      Explore the following topic: {argument}

      Launch the sdd-explore sub-agent to:
      1. Investigate the codebase related to this topic
      2. Compare multiple approaches
      3. Return a structured analysis

      This is exploration only — no files or code should be modified.
      Present the analysis to the user when complete.
    '';
  };
}
