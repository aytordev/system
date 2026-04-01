---
title: Warning Classification
impact: HIGH
impactDescription: Prevents fix churn on theoretical issues
tags: execution, warnings
---

## Warning Classification (Pattern 3)

**Impact: HIGH**

Judges MUST classify every WARNING into:

```
WARNING (real)        → Causes bug, data loss, security hole in a realistic scenario.
                        Fix required.
WARNING (theoretical) → Requires contrived scenario, corrupted input, or conditions
                        that cannot arise through normal usage. Report as INFO.
```

**How to classify**: Ask "Can a normal user, using the tool as intended, trigger this?"
- YES → real
- NO (requires malicious input, renamed dir, race in <1ms, etc.) → theoretical

**Theoretical warnings**:
- Reported as INFO in the verdict table
- NOT fixed, do NOT trigger re-judgment
- Do NOT count toward convergence threshold
- Included in final report for awareness only
