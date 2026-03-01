## Return Task Breakdown Summary

**Impact: CRITICAL**

After creating tasks.md, return a summary in the result envelope.

### Summary Format

**Executive Summary:**

```
Created task breakdown for {change-name} with {N} tasks across {M} phases.
Estimated complexity: {LOW | MEDIUM | HIGH | VERY HIGH}
Next recommended step: apply (Phase 1, tasks 1.1-1.3)
```

**Detailed Report:**

```markdown
## Task Breakdown: {change-name}

### Overview

| Phase | Tasks | Focus Area |
|-------|-------|------------|
| 1: Foundation | {count} | {brief description} |
| 2: Core Implementation | {count} | {brief description} |
| 3: Integration | {count} | {brief description} |
| 4: Testing | {count} | {brief description} |
| 5: Cleanup | {count} | {brief description} |

**Total tasks:** {N}

### Implementation Order Notes

- Phase 1 establishes {what}
- Phase 2 can proceed in parallel for {which components}
- Phase 3 requires completion of Phase 2 tasks {list dependencies}
- Testing in Phase 4 validates {what}

### Estimated Complexity

{LOW | MEDIUM | HIGH | VERY HIGH} — {brief justification}

### Next Steps

Recommended: Start with Phase 1, tasks 1.1-1.3 (Foundation)
```

### Artifacts Field

```json
{
  "artifacts": {
    "tasks": "{tasks.md content or reference}",
    "phase_count": 5,
    "task_count": 23
  }
}
```

### Next Recommended

Typically: `"apply"` with specific Phase 1 tasks to start implementation.
