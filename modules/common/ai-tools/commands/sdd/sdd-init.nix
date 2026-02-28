{
  sdd-init = {
    description = "Initialize SDD context — detects project stack and bootstraps persistence backend";
    allowedTools = "Read, Write, Bash, Grep, Glob";
    agent = "sdd-orchestrator";
    prompt = ''
      Initialize Spec-Driven Development in this project.

      Launch the sdd-init sub-agent to:
      1. Detect the project tech stack and conventions
      2. Bootstrap the persistence backend (engram/openspec/none)
      3. Generate configuration if using openspec mode

      Present the initialization summary to the user when complete.
    '';
  };
}
