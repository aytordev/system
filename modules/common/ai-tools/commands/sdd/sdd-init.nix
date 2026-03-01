{
  sdd-init = {
    description = "Initialize SDD context — detects project stack and bootstraps persistence backend";
    allowedTools = "Read, Write, Bash, Grep, Glob";
    agent = "sdd-orchestrator";
    prompt = ''
      Initialize Spec-Driven Development in this project.

      Launch the sdd-init sub-agent to detect the project tech stack, conventions,
      and bootstrap the active persistence backend (engram/openspec/none).

      Present the initialization summary to the user when complete.
    '';
  };
}
