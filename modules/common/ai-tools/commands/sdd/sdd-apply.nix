{
  sdd-apply = {
    description = "Implement SDD tasks — writes code following specs and design";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Implement tasks for the active SDD change (or "$ARGUMENTS" if specified).

      Launch the sdd-apply sub-agent to read specs, design, and tasks,
      then implement the next batch of incomplete tasks.

      Batch tasks — do not send all at once. After each batch, show progress
      (which tasks completed, any issues or deviations). In interactive mode ask
      to continue; in automatic mode continue and report at the next mandatory
      pause. Follow _shared/execution-modes.md.
    '';
  };
}
