{
  sdd-apply = {
    description = "Implement SDD tasks — writes code following specs and design";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Implement tasks for the active SDD change (or "{argument}" if specified).

      Launch the sdd-apply sub-agent to read specs, design, and tasks,
      then implement the next batch of incomplete tasks.

      Batch tasks — do not send all at once. After each batch, show progress
      to the user (which tasks completed, any issues or deviations) and ask
      to continue with the next batch.
    '';
  };
}
