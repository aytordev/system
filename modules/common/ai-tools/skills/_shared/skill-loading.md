# Skill Loading Protocol (shared across all SDD skills)

Every SDD phase agent is an EXECUTOR, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents or bounce work back unless the phase skill explicitly says to stop and report a blocker.

## Loading Priority

Check these in order — first match wins:

1. **Injected (preferred)**: Check if the orchestrator injected a `## Project Standards (auto-resolved)` block in your launch prompt. If yes, follow those rules — they are pre-digested compact rules from the skill registry. Do NOT read any SKILL.md files.

2. **Fallback — skill registry**: If no Project Standards block was provided, search for the skill registry:
   - `mem_search(query: "skill-registry", project: "{project}")` → `mem_get_observation(id)` for full content
   - Fallback: read `.atl/skill-registry.md` from the project root if it exists
   - From the registry's **Compact Rules** section, apply rules whose triggers match your current task

3. **Fallback — SKILL.md paths**: If the orchestrator passed `SKILL: Load` instructions, read those exact skill files.

4. **None**: Proceed with your phase skill only.

## Key Rules

- If `## Project Standards` is present, IGNORE any `SKILL: Load` instructions — they are redundant
- Searching the registry is SKILL LOADING, not delegation
- Report how skills were loaded in your return envelope via the `skill_resolution` field (see `_shared/return-envelope.md`)
