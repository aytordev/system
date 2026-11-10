---
title: Refuse the Unmeasured Change
impact: HIGH
impactDescription: The failure modes and the completion check
tags: react-performance, anti-patterns, completion
---

## Refuse the Unmeasured Change

**Impact: HIGH**

### Anti-Patterns

- Applying rules top-down from the catalogue with no profile — "we did the
  CRITICAL ones" is not a diagnosis.
- A single "performance PR" bundling twenty rules, where no individual change can
  be attributed or reverted.
- `useMemo`, `useCallback`, or `React.memo` added by reflex to components that
  never re-rendered measurably.
- Reaching for micro-optimizations while an un-parallelized `await` chain or a
  barrel import dominates the trace.
- Mutating a caller's array or a shared object in the name of a hot loop.
- Weakening a schema, widening a type, or asserting past a boundary to shave
  milliseconds.
- Moving work to the client to make a server metric look better, or the reverse,
  without measuring the metric the user actually feels.
- Measuring in development mode, or on a warm cache, and reporting it as the
  improvement.
- Treating a bundle-size win as a user win without checking whether the removed
  code was on the critical path.
- Optimizing a re-render storm caused by flow logic scattered across effects,
  instead of modelling the flow.

### Completion Check

- Is the symptom stated in user-observable terms, with a reproducible measurement
  method?
- Was the dominant cost *attributed* with evidence before a category was chosen?
- Does the diff carry one hypothesis, naming the specific rule it applies?
- Does the same measurement, run the same way, show the improvement — and would
  the change be reverted if it did not?
- Are all behavior tests unchanged and green, with no assertion edited to fit the
  optimization?
- Did every micro-optimization stay inside a proven hot path, local in scope,
  with immutability and typing intact at every boundary?
- Was a simpler fix — deleting the waterfall, narrowing the subscription, moving
  the boundary — considered before a cache was added?
- Is the before/after evidence recorded where the reviewer will see it?
