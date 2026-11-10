---
title: Choose the Authorized Handoff
impact: CRITICAL
impactDescription: Diagnosis does not authorize mutation; fixes land at the owning boundary
tags: debugging, handoff, verification
---

## Choose the Authorized Handoff

**Impact: CRITICAL**

### Diagnosis-only requests stop at the report

If the request is diagnosis-only, report the supported cause, evidence,
affected paths, uncertainty, and recommended fix, then stop. Diagnosis does
not authorize production edits, dependency changes, test writes, or
external-state mutation.

### Fixes go at the earliest causal point

When the user requested a fix, fix the earliest causal point shared by every
affected path. Avoid downstream guards that leave sibling callers broken.

For changed observable behavior, turn the reproduction into a failing
regression test first, then make the minimum production change and refactor
only if useful. Keep mitigation cleanup separate when removing it now would
increase incident risk. Name its owner and exit condition.

### Verify and report

For an authorized fix, run the focused regression, affected tests, and
proportionate broader checks. Re-run the original reproduction and inspect
relevant failure paths. For either handoff, report:

- root cause and why the evidence supports it;
- recommended or implemented fix location and affected callers;
- checks run with results, distinguishing diagnostic probes from fix
  verification;
- mitigation or residual uncertainty;
- follow-up only when a concrete risk remains.

### Complete when

- A diagnosis-only request has an evidence-backed report and no
  implementation mutation.
- For an authorized reproducible behavior change, the regression guard fails
  before the fix and passes after.
- For unreproducible, external, or operational causes, the strongest
  controlled probe, static check, or telemetry guard passes and the remaining
  observation gap is explicit.
- In every case the recommended or implemented fix addresses the supported
  cause rather than only the reported symptom.
