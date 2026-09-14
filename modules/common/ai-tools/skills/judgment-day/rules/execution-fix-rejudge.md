---
title: Fix and Re-judge
impact: HIGH
impactDescription: Drives convergence
tags: execution, fix, rejudge
---

## Fix and Re-judge (Pattern 4)

**Impact: HIGH**

1. If **confirmed CRITICAL issues or real WARNING issues** exist → delegate a **Fix Agent** in the **authorized correction lane** (a separate delegation, distinct from both judges)
2. After Fix Agent completes → re-launch **both judges in parallel** (fresh contexts, same target revision, same blind protocol)
3. **After 2 fix iterations**, if issues remain → ASK user: "Issues remain after 2 iterations. Continue?"
4. If both judges return clean → JUDGMENT: APPROVED

### Authorized Correction Lane

The Fix Agent is the only writer in the protocol. It receives the confirmed
findings, not a full judge transcript, and it never reuses a judge session. Any
write outside this lane is a policy violation.

### Fix Agent Scope Rule

If the Fix Agent fixes a pattern in one file (e.g., adds error logging for a silent discard), search for the SAME pattern in ALL other files touched by this change and fix them ALL. Inconsistent fixes across files cause unnecessary re-judge rounds.

### Round-by-round behavior

**Round 1**: Present verdict table. ASK user: "Fix confirmed issues?" Only fix after confirmation.

**Round 2+**: Only re-judge if confirmed CRITICAL issues remain.
- **Real WARNING issues** (confirmed): fix inline, do NOT re-launch judges. Report as "fixed without re-judge."
- **Theoretical WARNING issues**: report as INFO. Do NOT fix.
- **SUGGESTIONs**: fix inline if trivial. Do NOT re-judge.

**APPROVED criteria**: 0 confirmed CRITICAL issues + 0 confirmed real WARNING issues = APPROVED.
