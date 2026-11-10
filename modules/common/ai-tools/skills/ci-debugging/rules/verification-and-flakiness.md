---
title: Prove the Fix and Prove Flakiness
impact: HIGH
impactDescription: Keeps a fix from masking the real failure
tags: ci, verification, flakiness
---

## Prove the Fix and Prove Flakiness

**Impact: HIGH**

### Fix verification

After identifying the cause:

1. Explain **why** the fix addresses the root cause, not just the symptom.
2. Run the exact failing command locally.
3. Check that the fix does not mask the real problem. A retry, a sleep, or a
   widened timeout added without a cause hides a race or a resource constraint.

### Proving flakiness

Different outcomes across independent runs with the same controlled inputs are
evidence that the outcome is nondeterministic. That proves flakiness even before
the source is diagnosed. Record which inputs and environment facts were
controlled, then localize the cause: race, time, shared state, resource
pressure, or an external dependency.

A single unexplained failure stays a real failure. It is not permission to rerun
until green.

### Anti-patterns

| Anti-pattern | Why it is wrong | Instead |
| --- | --- | --- |
| "It's flaky, re-run it" | Masks a real issue | Investigate the failure |
| Blind retries or sleeps | Hide timing bugs | Identify the cause; add a bounded retry only when the external contract requires it |
| Pushing speculative fixes | Wastes CI cycles | Reproduce and verify locally |
| Reading only the last error line | Misses the root cause | Read the full output from the top |
| Fixing symptoms | The problem recurs | Trace to the root cause |

### Handoff

For a diagnosis-only request, end with the evidence and the recommended guard.
For an authorized fix, leave the smallest durable regression guard that fits:

- Production behaviour: write the failing behaviour test before the fix; capture
  legacy behaviour first when it is untested.
- Provider configuration, permissions, or an external outage: use a config
  assertion, a dry run, a contract check, or monitored recovery proof.
- No executable guard feasible: record the evidence and the remaining detection
  path instead of fabricating a test.
