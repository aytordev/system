# Return Envelope (shared across all SDD skills)

Every SDD phase MUST return a structured envelope to the orchestrator.

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `status` | `success \| partial \| blocked` | Phase completion status |
| `executive_summary` | string | 1-3 sentence summary of what was done |
| `detailed_report` | string (optional) | Full phase output, or omit if already inline |
| `artifacts` | list | Artifact keys/paths written |
| `next_recommended` | string | Next SDD phase to run, or "none" |
| `risks` | string | Risks discovered, or "None" |
| `skill_resolution` | string | How skills were loaded (see below) |

## `skill_resolution` Values

| Value | Meaning |
|-------|---------|
| `injected` | Received `## Project Standards (auto-resolved)` from orchestrator |
| `fallback-registry` | Self-loaded from skill registry (engram or `.atl/skill-registry.md`) |
| `fallback-path` | Loaded via `SKILL: Load` path instructions |
| `none` | No skills loaded — only phase skill used |

## Example

```markdown
**Status**: success
**Summary**: Proposal created for `add-dark-mode`. Defined scope, approach, and rollback plan.
**Artifacts**: Engram `sdd/add-dark-mode/proposal`
**Next**: sdd-spec or sdd-design
**Risks**: None
**Skill Resolution**: injected — 3 skills (nix, dotfiles-coder, skill-creator)
```

## Orchestrator Self-Correction

If a sub-agent reports anything other than `injected`, the orchestrator MUST:
1. Re-read the skill registry immediately (may have been lost to context compaction)
2. Ensure ALL subsequent delegations include `## Project Standards (auto-resolved)`
3. Log a warning: "Skill cache miss detected — reloaded registry for future delegations."
