---
title: House Rules Win Where a Micro-Optimization Would Trade Them Away
impact: CRITICAL
impactDescription: Speed is never bought with mutation, casts, or deleted tests
tags: react-performance, house-rules, immutability, typing
---

## House Rules Win Where a Micro-Optimization Would Trade Them Away

**Impact: CRITICAL**

Performance advice written for the general case sometimes trades away something
this repository does not trade. When they collide, these hold:

1. **Behavior tests do not change to accommodate a performance change.** A perf
   refactor that requires editing assertions is a behavior change wearing a
   disguise — route it through the failing-test-first workflow. Deleting or
   weakening a test to make a benchmark look better is never in scope.
2. **Immutability holds until a measurement says otherwise.** Micro-optimization
   rules that cache property lookups, mutate accumulators, or reuse arrays in hot
   loops are legitimate *inside a proven hot path*, and only there. The mutation
   stays local to a pure function's own scope — never a caller's array or a
   shared object.
3. **No `any`, no unjustified assertion, for speed.** Skipping schema validation
   at a trust boundary is a correctness change, not an optimization.
4. **Memoization is earned, not default.** Re-render rules assume a measured
   re-render problem. Reflexive `useMemo`/`memo` costs more than it saves.
   Prefer deleting the cause — derived state during render, a narrower
   subscription, a moved boundary — over adding a cache.
5. **Prefer removing mechanism to adding it.** A fix that deletes a waterfall, a
   provider, or a bundle entry beats one that adds a cache, a ref, or a memo with
   the same measured effect.
6. **Effects stay modelled.** If the fix is "add another `useEffect` to
   coordinate", the flow logic wants a machine or a derived value, not another
   effect.
7. **Third-party rules are pinned, not gospel.** External catalogues are
   installed at reviewed commits. When a rule contradicts a primary source (React
   or Next.js docs) for the version actually in use, the primary source wins and
   the divergence is worth recording in the project's expectations ledger.
