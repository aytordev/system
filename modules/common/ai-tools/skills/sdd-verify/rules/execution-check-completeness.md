## Check Task Completion Status

**Impact: CRITICAL**

Step 1: Validate that all implementation tasks are complete.

### Task Completion Check

Read the **persisted** tasks artifact from the change's backend (the same store
the orchestrator resolved) and count:

- **Total tasks**
- **Completed tasks** (marked done/checked)
- **Incomplete tasks** (not marked done)

The persisted checkboxes are authoritative: an envelope claiming completion that
the re-read tasks artifact does not show does NOT advance. Verify that every
task's cumulative progress matches the artifact.

### Categorization

Categorize incomplete tasks by type:

- **Core implementation** tasks (new features, bug fixes, critical changes)
- **Cleanup tasks** (refactoring, documentation, minor improvements)

### Severity Assignment

- **CRITICAL** if core implementation tasks are incomplete
- **WARNING** if only cleanup tasks are incomplete
- **PASS** if all tasks are complete

### Output

Return a summary:

```
Task Completion: {total} total, {completed} completed, {incomplete} incomplete
Incomplete Core Tasks: {count}
Incomplete Cleanup Tasks: {count}
Verdict: CRITICAL | WARNING | PASS
```
