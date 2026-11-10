---
title: Decide and Report the Verdict
impact: HIGH
impactDescription: Produces a machine-readable, closable acceptance result
tags: acceptance-review, verdict, report
---

## Decide and Report the Verdict

**Impact: HIGH**

### Criterion statuses

| Status | Meaning |
| --- | --- |
| Covered | The complete path and proportionate verification support the criterion |
| Partial | Some required outcomes, surfaces, or edge cases are unsupported |
| Missing | The production path is absent or disconnected |
| Regressed | Comparison evidence shows previously supported behavior broke |
| Unverified | Authority or evidence is insufficient to decide |

### Verdict derivation

- `Satisfies`: at least one criterion exists and every criterion is covered.
- `Does not satisfy`: any criterion is partial, missing, or regressed.
- `Indeterminate`: at least one criterion is unverified and every other
  criterion is covered, or no in-scope acceptance criterion exists.

### Report shape

Lead with `VERDICT: satisfies`, `VERDICT: does-not-satisfy`, or
`VERDICT: indeterminate`, followed by the subject, base, and authoritative
sources.

| ID | Criterion | Status | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- |

Then list failed or unavailable checks and the minimum evidence or
implementation needed to close every non-covered row. Keep unrelated code
review findings outside this report.

**Complete when:** every criterion appears once, every citation resolves, and
every non-covered row names what would close it.

### Hand-off

If fixes are also requested, the verdict comes first; the non-covered rows are
the gap list handed to the implementation work. For evidence design or a
requested behavior fix, apply the applicable test-first discipline directly:
write the failing test for the new or changed behavior before changing the
code — a companion testing or TDD skill may carry that method when installed,
but the rule above stands without one.
