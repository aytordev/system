---
title: Scan Project Conventions
impact: HIGH
impactDescription: Captures project-specific patterns without flattening scope
tags: scanning, conventions
---

## Scan Project Conventions

**Impact: HIGH**

Check the project root for convention files:

### Files to look for

- `AGENTS.md` or `agents.md`
- `.cursorrules`
- `copilot-instructions.md`

### Scope preservation

When an index file references other convention files, record each referenced path with the subtree it governs. Do NOT flatten every referenced path into one global standard: a rule that lives under `modules/home/AGENTS.md` applies to `modules/home/`, not to the whole repository. The delegator decides which scoped conventions match the task.

### Output

Build a table of `File | Path | Scope | Notes`, where `Scope` is the directory or subsystem the convention governs. Include the index file itself and each referenced path with its own scope.
