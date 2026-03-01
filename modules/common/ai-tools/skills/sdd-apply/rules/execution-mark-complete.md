## Mark Tasks Complete and Return Summary

**Impact: CRITICAL**

After implementing tasks, update tasks.md and return an implementation progress summary.

### Update tasks.md

Change `- [ ]` to `- [x]` for completed tasks.

**Before:**

```markdown
## Phase 2: Core Implementation
- [ ] 2.1 Implement hashPassword in services/auth.ts
- [ ] 2.2 Implement verifyPassword in services/auth.ts
- [ ] 2.3 Implement generateToken in services/auth.ts
```

**After:**

```markdown
## Phase 2: Core Implementation
- [x] 2.1 Implement hashPassword in services/auth.ts
- [x] 2.2 Implement verifyPassword in services/auth.ts
- [x] 2.3 Implement generateToken in services/auth.ts
```

**In openspec mode:** Write updated `tasks.md` back to filesystem.

**In engram/none mode:** Return updated tasks in the envelope.

### Return Implementation Progress Summary

**Executive Summary:**

```
Implemented Phase 2, tasks 2.1-2.3 for {change-name}.
Mode: {TDD | Standard}
Status: {ok | warning | blocked}
Files changed: {count}
{Tests passed | No tests run}
```

**Detailed Report:**

```markdown
## Implementation Progress: {change-name}

### Completed Tasks

**Change:** {change-name}
**Mode:** {TDD | Standard}
**Phase:** {phase number and name}
**Tasks:** {2.1-2.3}

### Files Changed

| File | Action |
|------|--------|
| services/auth.ts | Created, added hashPassword, verifyPassword, generateToken |
| types/auth.ts | Created, added AuthToken type |

### Tests (TDD Mode Only)

| Task | RED | GREEN | REFACTOR |
|------|-----|-------|----------|
| 2.1 hashPassword | ✓ | ✓ | ✓ |
| 2.2 verifyPassword | ✓ | ✓ | — |
| 2.3 generateToken | ✓ | ✓ | ✓ |

### Deviations from Design

{List any deviations, or "None" if following design exactly}

Example:
- Changed hash algorithm from SHA-256 to bcrypt to match existing project patterns

### Issues Found

{List any issues discovered, or "None"}

Example:
- Design specified using a non-existent `@/lib/jwt` module; used `jsonwebtoken` package instead

### Remaining Incomplete Tasks

**Phase 3: Integration** (not yet started)
- [ ] 3.1 Create auth middleware in middleware/auth.ts
- [ ] 3.2 Register auth middleware in routes/api.ts

### Overall Status

{ok | warning | blocked}

{If warning or blocked, explain why}
```

### Artifacts Field

```json
{
  "artifacts": {
    "tasks_updated": "{updated tasks.md content or reference}",
    "files_changed": [
      "services/auth.ts",
      "types/auth.ts"
    ],
    "completed_task_count": 3
  }
}
```

### Next Recommended

Suggest the next batch of tasks:

```
Next recommended: apply (Phase 3, tasks 3.1-3.2)
```

Or if all tasks are complete:

```
Next recommended: verify
```

Or if blocked:

```
Next recommended: design (update design to fix {issue})
```
