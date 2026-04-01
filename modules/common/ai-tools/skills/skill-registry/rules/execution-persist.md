---
title: Persist the Registry
impact: HIGH
impactDescription: Must be available for sub-agents
tags: persistence, engram, filesystem
---

## Persist the Registry

**Impact: HIGH**

This step is MANDATORY — do NOT skip it.

### A. Always write the file (guaranteed availability)

Create the `.atl/` directory in the project root if it doesn't exist, then write:

```
.atl/skill-registry.md
```

If the project has a `.gitignore` and `.atl` is not already listed, add `.atl/` to it.

### B. If engram is available, also save to engram

```
mem_save(
  title: "skill-registry",
  topic_key: "skill-registry",
  type: "config",
  project: "{project}",
  content: "{registry markdown}"
)
```

`topic_key` ensures upserts — running again updates the same observation, not duplicates.

### Why both?

- `.atl/skill-registry.md` is the guaranteed fallback (works offline, no MCP dependency)
- Engram provides cross-session searchability and faster access via `mem_search`
