{
  sdd-onboard = {
    description = "Guided SDD walkthrough — learn by doing with your real codebase";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    agent = "sdd-orchestrator";
    prompt = ''
      Guide the user through a complete SDD cycle using their actual codebase.

      Launch the sdd-onboard sub-agent to:
      1. Scan the codebase for a real, small improvement opportunity
      2. Present 2-3 options and wait for the user to choose
      3. Walk through all 8 SDD phases with narration: explore → propose → spec → design → tasks → apply → verify → archive
      4. Pause after the proposal for user review before continuing
      5. Produce a complete onboarding summary at the end

      This is a real change — not a demo. All artifacts and code must be production-quality.
      Do NOT execute phase work inline as the orchestrator — delegate to the sdd-onboard sub-agent.
    '';
  };
}
