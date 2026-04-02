# SDD Phase Common — Executor Protocol

Every SDD phase agent is an **EXECUTOR**, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents or bounce work back unless the phase skill explicitly says to stop and report a blocker.

This file replaces `skill-loading.md` and `return-envelope.md`. All four sections are required reading for every SDD phase.

---

## Section A — Skill Loading

Check these in order — first match wins:

1. **Injected (preferred)**: Check if the orchestrator injected a `## Project Standards (auto-resolved)` block in your launch prompt. If yes, follow those rules — they are pre-digested compact rules from the skill registry. Do NOT read any SKILL.md files.

2. **Fallback — skill registry**: If no Project Standards block was provided, search for the skill registry:
   - `mem_search(query: "skill-registry", project: "{project}")` → `mem_get_observation(id)` for full content
   - Fallback: read `.atl/skill-registry.md` from the project root if it exists
   - From the registry's **Compact Rules** section, apply rules whose triggers match your current task

3. **Fallback — SKILL.md paths**: If the orchestrator passed `SKILL: Load` instructions, read those exact skill files.

4. **None**: Proceed with your phase skill only.

**Key Rules**:
- If `## Project Standards` is present, IGNORE any `SKILL: Load` instructions — they are redundant
- Searching the registry is skill loading, not delegation
- Report how skills were loaded in your return envelope via `skill_resolution` (Section D)

---

## Section B — Artifact Retrieval

Before executing your phase, retrieve prior artifacts in this order:

### engram mode
1. `mem_search(query: "sdd/{change-name}/{artifact-type}", project: "{project}")`
2. `mem_get_observation(id)` on the best match
3. If no result: check filesystem fallback path (openspec convention)

### openspec mode
1. Read files from `openspec/changes/{change-name}/` per `openspec-convention.md`
2. If file missing: report as blocker, do not fabricate content

### hybrid mode
1. Try Engram first (steps as in engram mode)
2. If Engram returns no results, fall back to filesystem (steps as in openspec mode)
3. Both paths must succeed for a write to be considered complete

### none mode
1. Use only what the orchestrator passed in the launch prompt context
2. Do not attempt to read any files or search Engram

### Dependency map (what to retrieve per phase)

| Phase | Needs |
|-------|-------|
| sdd-spec | proposal |
| sdd-design | proposal |
| sdd-tasks | proposal + spec + design |
| sdd-apply | spec + design + tasks |
| sdd-verify | all prior artifacts |
| sdd-archive | all prior artifacts |

---

## Section C — Artifact Persistence

The orchestrator passes `artifact_store.mode` as one of: `engram | openspec | hybrid | none`.

### Mode behavior

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| `engram` | Engram | Engram | Never |
| `openspec` | Filesystem | Filesystem | Yes |
| `hybrid` | Engram (primary) + Filesystem (fallback) | Both | Yes |
| `none` | Orchestrator prompt only | Nowhere | Never |

### Rules

- If mode is `none`: do NOT create or modify any project files. Return results inline only.
- If mode is `engram`: do NOT write any project files. Persist to Engram and return observation IDs.
- If mode is `openspec`: write files ONLY to the paths defined in `openspec-convention.md`.
- If mode is `hybrid`: write to BOTH Engram AND filesystem. Both writes MUST succeed. Read from Engram first; fall back to filesystem if Engram returns no results.
- NEVER force `openspec/` creation unless the orchestrator explicitly passed `openspec` or `hybrid` mode.
- If you are unsure which mode to use, default to `none`.
- **Token cost**: `hybrid` consumes more tokens per operation (two persistence calls). Use only when cross-session recovery AND a local file audit trail are both needed.

### Detail level

The orchestrator may pass `detail_level`: `concise | standard | deep`. This controls output verbosity only — always persist the full artifact regardless of detail level.

---

## Section D — Return Envelope

Every SDD phase MUST return a structured envelope to the orchestrator.

### Required fields

| Field | Type | Description |
|-------|------|-------------|
| `status` | `success \| partial \| blocked` | Phase completion status |
| `executive_summary` | string | 1–3 sentence summary of what was done |
| `detailed_report` | string (optional) | Full phase output, or omit if already inline |
| `artifacts` | list | Artifact keys/paths written |
| `next_recommended` | string | Next SDD phase to run, or "none" |
| `risks` | string | Risks discovered, or "None" |
| `skill_resolution` | string | How skills were loaded (see values below) |

### `skill_resolution` values

| Value | Meaning |
|-------|---------|
| `injected` | Received `## Project Standards (auto-resolved)` from orchestrator |
| `fallback-registry` | Self-loaded from skill registry (engram or `.atl/skill-registry.md`) |
| `fallback-path` | Loaded via `SKILL: Load` path instructions |
| `none` | No skills loaded — only phase skill used |

### Example

```markdown
**Status**: success
**Summary**: Proposal created for `add-dark-mode`. Defined scope, approach, and rollback plan.
**Artifacts**: Engram `sdd/add-dark-mode/proposal`
**Next**: sdd-spec or sdd-design
**Risks**: None
**Skill Resolution**: injected — 3 skills (nix, dotfiles-coder, skill-creator)
```

### Orchestrator self-correction

If a sub-agent reports anything other than `injected`, the orchestrator MUST:
1. Re-read the skill registry immediately (may have been lost to context compaction)
2. Ensure ALL subsequent delegations include `## Project Standards (auto-resolved)`
3. Log a warning: "Skill cache miss detected — reloaded registry for future delegations."
