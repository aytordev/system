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
**Persistence**: {none | engram | file} — {session only | Engram aytordev/local-skill-registry | .ai-local/skill-registry.md}
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
Read selected original `SKILL.md` files. Refresh this local index explicitly
when needed; it does not replace Shell's registry or install a workflow.
```

If listing was requested instead of a refresh, report `Read-only listing — nothing written`.
