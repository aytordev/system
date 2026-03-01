## Check Task Completion Status

**Impact: CRITICAL**

Step 1: Validate that all implementation tasks are complete.

### Task Completion Check

Retrieve the task list for this change and count:

- **Total tasks**
- **Completed tasks** (marked done/checked)
- **Incomplete tasks** (not marked done)

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
