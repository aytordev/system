# Skill Resolver — Universal Protocol

Any agent that **delegates work to sub-agents** MUST follow this protocol to resolve relevant skills and pass exact `SKILL.md` paths. This applies to the SDD orchestrator, judgment-day, and any future workflow that launches sub-agents.

## Why This Exists

Sub-agents start with no project skill context. The registry gives delegators a cheap **index** of available skills — name, full description, scope, exact `SKILL.md` path, and a freshness identity — without rewriting or summarizing those skills. `SKILL.md` remains the source of truth.

## When to Apply

Before EVERY sub-agent launch that involves reading, writing, reviewing, testing, documenting, or creating project artifacts. Skip only for purely mechanical commands.

## The Protocol

### Step 1: Obtain the Skill Index (once per session)

The registry is an **index** of names, full descriptions, scopes, and exact `SKILL.md` paths. It is not a compact-rules bundle.

Resolution order:
1. Already cached from earlier in this session? → use cache
2. `mem_search(query: "skill-registry", project: "{project}")` → `mem_get_observation(id)` for full content
3. Fallback: read `.atl/skill-registry.md` from the project root when file persistence was selected **and it is index-first** (it contains `## Index`). An older summary cache has no `## Index`; do not use it — preserve it and regenerate through the `skill-registry` skill (`aytordev-sdd migrate registry --input .atl/skill-registry.md` detects it)
4. No index found? → proceed without skills, warn the user: "No skill registry found — sub-agents will work without project-specific standards. Run `skill-registry` to fix this."

### Step 2: Match Relevant Skills

Match on TWO dimensions:

| Context | Match against |
|---------|---------------|
| Code/files | Index description mentions the language, framework, tool, or path context |
| Task/action | Index description mentions actions like PR, review, docs, tests, comments, release |

Prefer the smallest useful set. If more than **5 skills** match, keep the 5 most relevant (prioritize code context over task context).

### Step 3: Inject Skill Paths

Inject paths, not summaries:

```markdown
## Skills to load before work

Read these exact files before reading, writing, reviewing, testing, or creating artifacts:

- /absolute/path/to/skills/nix/SKILL.md
- /absolute/path/to/skills/dotfiles-coder/SKILL.md
```

This goes BEFORE the task-specific instructions. The sub-agent MUST read those files before task-specific work. Project-scope paths take precedence over global-scope paths; never silently pick between ambiguous duplicates — surface them to the user.

### Step 4: Include Project Conventions

If the index has a **Project Conventions** section, add:

```markdown
## Project Conventions
Read these files for project-specific patterns:
- {path1} — {notes}
```

Keep each convention scoped to the subtree it documents; do not flatten every referenced path into a global standard.

## Token Budget

Exact paths are compact. For 3-4 matching skills that is a few lines. If more than **5 skill paths** match, keep only the 5 most relevant (prioritize code context over task context).

## Compaction Safety

- The index lives in Engram or `.atl/skill-registry.md`, not in orchestrator memory.
- Each delegation re-reads the index if needed (Step 1 handles a cache miss).
- Sub-agents receive exact files to read, so skill meaning is not degraded by generated summaries.

## Feedback Loop

Sub-agents report their skill resolution status via the `skill_resolution` field in the return envelope (see `_shared/return-envelope.md`).

If a sub-agent reports anything other than `paths-injected`:
1. Re-read the skill registry index immediately
2. Ensure ALL subsequent delegations include `## Skills to load before work` with exact `SKILL.md` paths
