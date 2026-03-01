{
  sdd-verify = {
    description = "Validate implementation matches specs, design, and tasks";
    allowedTools = "Read, Write, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Verify the implementation for the active SDD change (or "{argument}" if specified).

      Launch the sdd-verify sub-agent to:
      1. Check task completeness
      2. Verify spec correctness (static analysis)
      3. Check design coherence
      4. Execute tests and build
      5. Generate spec compliance matrix
      6. Return verification report with verdict (PASS / PASS WITH WARNINGS / FAIL)

      Present the verification report to the user.
    '';
  };
}
