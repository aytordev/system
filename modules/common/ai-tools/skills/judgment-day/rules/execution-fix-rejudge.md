---
title: Fix and Re-judge
impact: HIGH
impactDescription: Drives convergence
tags: execution, fix, rejudge
---

## Fix and Re-judge (Pattern 4)

**Impact: HIGH**

1. If **confirmed CRITICAL issues or real WARNING issues** exist → delegate a **Fix Agent** (separate delegation)
2. After Fix Agent completes → re-launch **both judges in parallel** (fresh delegates, same blind protocol)
3. **After 2 fix iterations**, if issues remain → ASK user: "Issues remain after 2 iterations. Continue?"
4. If both judges return clean → JUDGMENT: APPROVED

### Fix Agent Scope Rule

If the Fix Agent fixes a pattern in one file (e.g., adds error logging for a silent discard), search for the SAME pattern in ALL other files touched by this change and fix them ALL. Inconsistent fixes across files cause unnecessary re-judge rounds.

### Round-by-round behavior

**Round 1**: Present verdict table. ASK user: "Fix confirmed issues?" Only fix after confirmation.

**Round 2+**: Only re-judge if confirmed CRITICAL issues remain.
- **Real WARNING issues** (confirmed): fix inline, do NOT re-launch judges. Report as "fixed without re-judge."
- **Theoretical WARNING issues**: report as INFO. Do NOT fix.
- **SUGGESTIONs**: fix inline if trivial. Do NOT re-judge.

**APPROVED criteria**: 0 confirmed CRITICAL issues + 0 confirmed real WARNING issues = APPROVED.
