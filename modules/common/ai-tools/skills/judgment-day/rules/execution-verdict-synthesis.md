---
title: Verdict Synthesis
impact: CRITICAL
impactDescription: Determines which findings are real vs noise
tags: execution, verdict
---

## Verdict Synthesis (Pattern 2)

**Impact: CRITICAL**

The **orchestrator** (NOT a sub-agent) compares results after both judges return:

```
Confirmed     → found by BOTH agents          → high confidence, fix
Suspect A     → found ONLY by Judge A         → needs triage
Suspect B     → found ONLY by Judge B         → needs triage
Contradiction → agents DISAGREE on same thing → flag for manual decision
```

### Output Format

```markdown
## Judgment Day — {target}

### Round {N} — Verdict

| Finding | Judge A | Judge B | Severity | Status |
|---------|---------|---------|----------|--------|
| Missing null check in auth.go:42 | found | found | CRITICAL | Confirmed |
| Race in worker.go:88 | found | — | WARNING (real) | Suspect (A only) |
| Windows edge case | — | found | WARNING (theoretical) | INFO — reported |

**Confirmed issues**: {N}
**Suspect issues**: {N}
**Contradictions**: {N}
```
