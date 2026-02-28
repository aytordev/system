{
  sdd-apply = {
    description = "Implement SDD tasks — writes code following specs and design";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Implement tasks for the active SDD change (or "{argument}" if specified).

      Launch the sdd-apply sub-agent to:
      1. Read specs, design, and tasks
      2. Implement the next batch of incomplete tasks
      3. Mark completed tasks in tasks.md

      Batch tasks — do not send all at once. After each batch, show progress
      and ask the user to continue.
    '';
  };
}
