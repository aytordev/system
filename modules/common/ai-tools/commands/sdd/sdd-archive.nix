{
  sdd-archive = {
    description = "Archive a completed SDD change — syncs specs and closes the cycle";
    allowedTools = "Read, Write, Edit, Bash, Grep, Glob";
    argumentHint = "[change-name]";
    agent = "sdd-orchestrator";
    prompt = ''
      Archive the completed SDD change (or "{argument}" if specified).

      Launch the sdd-archive sub-agent to:
      1. Check verification report for CRITICAL issues (block if found)
      2. Sync delta specs to main specs
      3. Move change folder to archive
      4. Verify archive completeness

      Present the archive summary and confirm the SDD cycle is complete.
    '';
  };
}
