---
title: Convergence Threshold
impact: HIGH
impactDescription: Prevents infinite fix-review loops
tags: execution, convergence
---

## Convergence Threshold (Pattern 5)

**Impact: HIGH**

### After 2 fix iterations

If issues still remain, ASK the user:
- "Issues remain after 2 iterations. Continue iterating?"
- YES → continue fix + judge cycle (no limit)
- NO → JUDGMENT: ESCALATED (report remaining issues)

### Terminal States

| State | Condition |
|-------|-----------|
| APPROVED | Both judges return clean after fix round |
| ESCALATED | User chose to stop, or unresolvable issues remain |

### Self-Check (before ANY terminal action)

Before pushing, committing, summarizing, or telling the user "done":

1. List every active JD target
2. For each: is it in state APPROVED or ESCALATED?
3. If ANY had fixes applied, did re-judgment run?
4. If re-judgment found issues, did you ASK the user?

**If ANY answer is "no"** → go back and complete it.
