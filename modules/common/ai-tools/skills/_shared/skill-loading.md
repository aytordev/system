# Skill Loading Protocol (shared across all SDD skills)

Every SDD phase agent is an EXECUTOR, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents or bounce work back unless the phase skill explicitly says to stop and report a blocker.

## Source of Truth

The original `SKILL.md` is the source of truth. Load the selected originals plus only the references the task needs. The skill registry is an **index of exact paths**, not a digest: generated summaries and compact rules are never authoritative and must not replace reading the original.

Paths are relative to the configured skills root (the directory that contains this skill package, e.g. `$XDG_CONFIG_HOME/opencode/skills` for OpenCode or `~/.pi/agent/skills` for Pi).

## Loading Priority

Check these in order — first match wins:

1. **Paths injected (preferred)**: If the orchestrator injected a `## Skills to load before work` block in your launch prompt, read every exact `SKILL.md` path listed there before task-specific work.

2. **Fallback — skill registry index**: If no paths were injected, search for the index:
   - `mem_search(query: "skill-registry", project: "{project}")` → `mem_get_observation(id)` for the full index
   - Fallback: read `.atl/skill-registry.md` from the project root if it exists (file persistence was selected) **and it is index-first** — it must contain an `## Index` section
   - If that file has no `## Index` (an older summary cache cannot satisfy this contract), STOP: preserve the file and regenerate it through the `skill-registry` skill; do not read its summaries as skill content. Detect it with `aytordev-sdd migrate registry --input .atl/skill-registry.md`
   - Match your task against the index descriptions, then read the exact `SKILL.md` paths for the matches

3. **Fallback — explicit `SKILL: Load` paths**: If the orchestrator passed `SKILL: Load` instructions, read those exact skill files.

4. **None**: Proceed with your phase skill only.

## Progressive Loading

- Read the selected `SKILL.md` entry point first.
- Then read only the `rules/`, `modules/`, or `references/` files that entry point and the task require.
- A rule that lives in a selected reference remains available: read that reference instead of assuming a summary covers it.

## Key Rules

- If `## Skills to load before work` is present, IGNORE any redundant `SKILL: Load` instructions
- Searching the index is SKILL LOADING, not delegation
- Report how skills were loaded in your return envelope via the `skill_resolution` field (see `_shared/return-envelope.md`)
