## Mark Tasks Complete, Re-read, and Return Summary

**Impact: CRITICAL**

After implementing tasks, update the persisted tasks artifact, **re-read it from
the same store**, and only then report completion. Progress prose in the envelope
is not authoritative — the persisted, re-read tasks artifact is.

### Update `tasks.md`

Change `- [ ]` to `- [x]` for completed tasks, keeping each unit's `check:`,
`scenario:`, and `rollback:` fields intact.

**Before:**

```markdown
## Phase 2: Core Implementation
- [ ] 2.1 Implement hashPassword in services/auth.ts — check: `npm test -- auth`; scenario: REQ-01/S1; rollback: remove hashPassword
```

**After:**

```markdown
## Phase 2: Core Implementation
- [x] 2.1 Implement hashPassword in services/auth.ts — check: `npm test -- auth`; scenario: REQ-01/S1; rollback: remove hashPassword
```

Update the backend the orchestrator resolved (no cross-store fallback):

- **openspec**: Write the updated `tasks.md` back to the filesystem.
- **engram**: Persist the updated tasks observation to the Engram topic key
  `sdd/{change-name}/tasks` (upsert).
- **hybrid**: Both stores, with the partial-write/retry rules.
- **none**: Session-local; keep the updated tasks in the envelope/session only.

### Re-read and Verify (MANDATORY)

After writing, re-read the tasks artifact from the **same** store and confirm:

1. Every task this batch reports as complete is `[x]` in the re-read artifact.
2. No task outside this batch was flipped.
3. The cumulative completed count equals the persisted `[x]` count.

If the readback disagrees with the intended update, do NOT report `success`:
return `status: partial` (write landed but readback unconfirmed) or `status:
blocked` (write failed), naming the store. Never report completion from memory.

### Cumulative Apply-Progress Across Resumed Batches

The `apply-progress` artifact is cumulative, not per-batch:

- Read the existing `apply-progress` first when resuming (the orchestrator
  passes its locator and a MERGE instruction).
- Merge the new batch into the prior progress; never overwrite or drop earlier
  batches.
- Keep the running completed/total counts consistent with the re-read tasks
  artifact across every resumed batch.
- If a prior batch's progress cannot be read, report `blocked` rather than
  silently restarting counts from zero.

Authorized code/config edits made by this phase are implementation work, not
persistence artifacts, and are allowed in every backend.

### Return Implementation Progress Summary

Return an `sdd-result/v1` envelope (`_shared/return-envelope.md`) with
`schema`, `kind`, `status`, `executive_summary`, `artifacts`, `evidence`,
`next_recommended`, `risks`, and `skill_resolution`.

**Executive Summary:**

```
Implemented Phase 2, tasks 2.1-2.3 for {change-name}.
Mode: {TDD | Standard}
Status: {success | partial | blocked | failed}
Files changed: {count}
Re-read tasks artifact: {locator} — {completed}/{total} checked
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

### Persisted Tasks Readback

| Store | Locator | Checked this batch | Cumulative checked/total | Readback |
|-------|---------|--------------------|--------------------------|----------|
| openspec | openspec/changes/{change}/tasks.md | 2.1-2.3 | 3/12 | matches |

### Evidence

| Task | check | exit | result | revision | relevant |
|------|-------|------|--------|----------|----------|
| 2.1 | `npm test -- auth` | 0 | pass | 3752d5c | REQ-01/S1 |

### Deviations from Design

{List any deviations, or "None" if following design exactly}

### Issues Found

{List any issues discovered, or "None"}

### Remaining Incomplete Tasks

**Phase 3: Integration** (not yet started)
- [ ] 3.1 Create auth middleware in middleware/auth.ts

### Overall Status

{success | partial | blocked | failed}
```

### Artifacts Field

```json
{
  "artifacts": {
    "tasks_updated": "{re-read tasks content or locator}",
    "tasks_readback": "{locator re-read from the same store}",
    "apply_progress": "{cumulative apply-progress locator}",
    "files_changed": ["services/auth.ts", "types/auth.ts"],
    "completed_task_count": 3,
    "cumulative_completed_task_count": 3
  }
}
```

### Next Recommended

Suggest the next batch of tasks (`apply`), or `verify` if all tasks are
complete, or `design` if a blocker requires a design change.
