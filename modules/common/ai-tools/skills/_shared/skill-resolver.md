# Skill Resolver — Universal Protocol

Any agent that **delegates work to sub-agents** MUST follow this protocol to resolve and inject relevant skills. This applies to the SDD orchestrator, judgment-day, and any future workflow that launches sub-agents.

## When to Apply

Before EVERY sub-agent launch that involves **reading, writing, or reviewing code**. Skip only for purely mechanical delegations (e.g., "run this test command").

## The Protocol

### Step 1: Obtain the Skill Registry (once per session)

The registry contains a **Compact Rules** section with pre-digested rules per skill (5-15 lines each). This is what you inject — NOT full SKILL.md paths.

Resolution order:
1. Already cached from earlier in this session? → use cache
2. `mem_search(query: "skill-registry", project: "{project}")` → `mem_get_observation(id)` for full content
3. Fallback: read `.atl/skill-registry.md` from the project root if it exists
4. No registry found? → proceed without skills, warn the user: "No skill registry found — sub-agents will work without project-specific standards. Run `skill-registry` to fix this."

### Step 2: Match Relevant Skills

Match on TWO dimensions:

**A. Code Context** — what files will the sub-agent touch?
Use the `Trigger` field in the registry's User Skills table. Skills whose triggers mention the relevant technology or file type are matches.

**B. Task Context** — what actions will the sub-agent perform?

| Sub-agent action | Match triggers mentioning... |
|-----------------|------------------------------|
| Write/review code | The specific framework/language |
| Create a PR | "PR", "pull request" |
| Write tests | "test", "vitest", "pytest" |
| Nix modules | "nix", "module", "flake" |

### Step 3: Inject into Sub-Agent Prompt

From the registry's **Compact Rules** section, copy matching skill blocks into the sub-agent's prompt:

```
## Project Standards (auto-resolved)

{paste compact rules blocks for each matching skill}
```

This goes BEFORE the task-specific instructions. Inject the COMPACT RULES text, not paths.

### Step 4: Include Project Conventions

If the registry has a **Project Conventions** section, add:

```
## Project Conventions
Read these files for project-specific patterns:
- {path1} — {notes}
```

## Token Budget

Compact rules add ~50-150 tokens per skill. For 3-4 matching skills, that's ~400-600 tokens. If more than **5 skill blocks** match, keep only the 5 most relevant (prioritize code context over task context).

## Compaction Safety

This protocol is compaction-safe because:
- The registry lives in engram/filesystem, not in orchestrator memory
- Each delegation re-reads the registry if needed (Step 1 handles cache miss)
- Compact rules are copied into each sub-agent's prompt at launch — even if the orchestrator forgets, the sub-agents already have the rules

## Feedback Loop

Sub-agents report their skill resolution status via the `skill_resolution` field in the return envelope (see `_shared/return-envelope.md`).

If a sub-agent reports anything other than `injected`:
1. Re-read the skill registry immediately
2. Ensure ALL subsequent delegations include `## Project Standards (auto-resolved)`
