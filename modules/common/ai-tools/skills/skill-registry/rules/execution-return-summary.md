---
title: Return Summary
impact: MEDIUM
impactDescription: Provides feedback to user
tags: output, summary
---

## Return Summary

**Impact: MEDIUM**

Return a structured summary:

```markdown
## Skill Registry Updated

**Project**: {project name}
**Persistence**: {mode} — {session only | Engram skill-registry | .atl/skill-registry.md | both}
**Indexed skills**: {count}

### Indexed Skills
| Name | Scope | Path |
|------|-------|------|
| {name} | {project/global} | {exact SKILL.md path} |

### Shadowed / Ambiguous
| Name | Kept | Shadowed | Reason |
|------|------|----------|--------|

### Project Conventions
| File | Path | Scope |
|------|------|-------|
| {file} | {path} | {subtree} |

### Next Steps
Delegators read this index and pass exact `SKILL.md` paths to sub-agents
via `## Skills to load before work`. Run refresh after installing/removing skills.
```

If listing was requested instead of a refresh, report `Read-only listing — nothing written`.
