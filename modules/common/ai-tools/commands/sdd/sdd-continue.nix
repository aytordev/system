{
  sdd-continue = {
    description = "Continue the next SDD phase in the dependency chain";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Continue the SDD workflow for the active change (or "{argument}" if specified).

      Check which artifacts already exist and determine the next phase from the dependency graph:
      - proposal exists, no specs/design → launch sdd-spec and sdd-design (can be parallel)
      - specs and design exist, no tasks → launch sdd-tasks
      - tasks exist, not all applied → launch sdd-apply
      - all applied, not verified → launch sdd-verify
      - verified → launch sdd-archive

      Launch the appropriate sub-agent(s) and present results to the user.
    '';
  };
}
