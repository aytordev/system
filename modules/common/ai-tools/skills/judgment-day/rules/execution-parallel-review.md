---
title: Parallel Blind Review
impact: CRITICAL
impactDescription: Core mechanism — two independent perspectives
tags: execution, parallel, judges
---

## Parallel Blind Review (Pattern 1)

**Impact: CRITICAL**

- Launch **TWO** sub-agents via `delegate` (async, parallel — never sequential)
- Each agent receives the **same target** but works **independently**
- **Neither agent knows about the other** — no cross-contamination
- Both use identical review criteria but may find different issues
- NEVER do the review yourself as the orchestrator — your job is coordination only

### Judge Return Format

Each judge returns a structured list of findings:

```
Each finding:
- Severity: CRITICAL | WARNING (real) | WARNING (theoretical) | SUGGESTION
- File: path/to/file.ext (line N if applicable)
- Description: What is wrong and why
- Suggested fix: one-line intent (not code)

If NO issues: VERDICT: CLEAN — No issues found.
```
