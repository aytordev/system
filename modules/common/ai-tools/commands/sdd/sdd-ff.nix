{
  sdd-ff = {
    description = "Fast-forward all SDD planning phases — proposal through tasks";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Fast-forward all SDD planning phases for "{argument}".

      Launch sub-agents in sequence:
      1. sdd-propose — create the change proposal
      2. sdd-spec — write specifications
      3. sdd-design — create technical design
      4. sdd-tasks — break down into implementation tasks

      Show a combined summary after ALL phases complete (not between each one).
      Recommend /sdd-apply as the next step.
    '';
  };
}
