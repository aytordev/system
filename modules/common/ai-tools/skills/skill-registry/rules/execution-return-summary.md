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
**Location**: .atl/skill-registry.md
**Engram**: {saved / not available}

### User Skills Found
| Skill | Trigger |
|-------|---------|
| {name} | {trigger} |

### Project Conventions Found
| File | Path |
|------|------|
| {file} | {path} |

### Next Steps
The orchestrator reads this registry once per session and passes
pre-resolved compact rules to sub-agents via their launch prompts.
To update after installing/removing skills, run this again.
```
