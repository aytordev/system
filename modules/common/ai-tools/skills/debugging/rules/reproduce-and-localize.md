---
title: Reproduce, Then Localize Before Editing
impact: CRITICAL
impactDescription: A fix without localization fixes the symptom, not the cause
tags: debugging, reproduction, localization
---

## Reproduce, Then Localize Before Editing

**Impact: CRITICAL**

### Define and reproduce

Write expected versus actual behavior, the narrowest known trigger,
frequency, and the last known working case. Reproduce with the smallest
faithful command, test, request, or observation. If reproduction is
unavailable, say why and use observability data or a controlled probe rather
than pretending certainty.

Compare a working and failing path when possible. Change one variable at a
time.

### Localize before editing

Trace the real flow end to end:

- entry point, callers, data transformations, state owners, effects, and
  error handling;
- configuration and environment deltas;
- recent changes and the last known good revision;
- sibling paths using the same boundary;
- where the observed value first diverges from the expected value.

Use `git log`, `git blame`, or `git bisect` only when history can
discriminate between causes. Search every caller before changing a shared
function — a shared-function edit is a contract change for all of them.

### Complete when

The failure is reproducible or the exact observation gap is named, and the
causal boundary is narrow enough for one discriminating check.
