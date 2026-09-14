---
title: Persist the Registry
impact: HIGH
impactDescription: Refresh follows the selected persistence policy
tags: persistence, engram, filesystem
---

## Persist the Registry

**Impact: HIGH**

Refresh follows the active artifact/persistence policy (`engram | openspec | hybrid | none`; see `_shared/persistence-contract.md`). Resolve the mode once. When no mode is provided and the user did not explicitly request file persistence, default to **session-only**.

| Mode | Where the index lives | Project files |
|------|-----------------------|---------------|
| `none` | Session memory only | Never |
| `engram` | Engram (`topic_key: skill-registry`) | Never |
| `openspec` | `.atl/skill-registry.md` | Yes |
| `hybrid` | Engram **and** `.atl/skill-registry.md` | Yes |

### `none` — session-only

Return the index inline. Do NOT create `.atl/`, do NOT edit `.gitignore`, and do NOT save to Engram.

### `engram` — memory only

Save or upsert the index; do not write project files silently.

```
mem_save(
  title: "skill-registry",
  topic_key: "skill-registry",
  type: "config",
  project: "{project}",
  capture_prompt: false,
  content: "{registry markdown}"
)
```

`topic_key` ensures upserts — running again updates the same observation, not a duplicate.

### `openspec` / `hybrid` — explicit file persistence

Create the `.atl/` directory in the project root if needed, then write:

```
.atl/skill-registry.md
```

In `hybrid`, also save to Engram as above. Both writes MUST succeed.

### `.gitignore`

NEVER silently edit `.gitignore`. If `.atl` is not ignored, mention it in the summary and let the user decide.

### Cache invalidation and legacy migration

Old summary caches cannot satisfy this contract. Reject any cache whose entries
lack the index fields or whose `freshness` no longer matches the current
`SKILL.md`; regenerate instead.

Before writing the new index, detect an older summary cache at the target path
(no `## Index` section). Preserve its bytes as `.atl/skill-registry.legacy.md`
(never overwrite it in place), then write the fresh index-first registry.
`aytordev-sdd migrate registry --input .atl/skill-registry.md` reports the
classification, preserves the original, and stops with a reason; the skill then
performs the actual regeneration. Never upgrade a summary cache into an index by
transcribing its summaries — `SKILL.md` stays the source of truth.
