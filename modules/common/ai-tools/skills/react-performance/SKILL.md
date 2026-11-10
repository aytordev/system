---
name: react-performance
description: "Trigger: React or Next.js feels slow — a search box or list that stutters while typing, a page that burns CPU while it sits open, a sluggish dashboard, jank on scroll, a slow first load — or a bundle, waterfall, re-render, or hydration problem is suspected, or a performance diff or rule conflict is being reviewed. Measurement-first: baseline the symptom, attribute the cost with evidence, apply one rule at a time, re-measure, and revert what does not move the number."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# React Performance

Performance work fails in two predictable ways: optimizing something that was
never the bottleneck, and buying speed with a mutation, a cast, or a deleted
test. This skill exists to prevent both. It owns the *method*; rule catalogues
own the *rules*.

**The catalogue is not the plan.** Where the project pins a rule catalogue (for
example Vercel's React/Next.js best-practices collections), its rules are ordered
by typical impact, not by what is slow in *this* application. A rule earns its
way into a diff by a measurement, not by appearing high in the list. Read the
specific rule file, not just the index, before applying it.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- A React or Next.js surface is reported slow in user-observable terms.
- A bundle, request-waterfall, re-render, serialization, or hydration problem is
  suspected.
- A diff is being reviewed for performance impact.
- A performance rule appears to conflict with immutability, test-first, or
  type-safety guidance.

Do not use it to apply rules top-down from a catalogue with no profile, or to
bundle many optimizations into one change.

## Hard Rules

1. **No baseline, no change.** Name the symptom in user-observable terms and
   capture a reproducible number — a profile, a bundle report, a trace, a field
   metric — before touching code. Record how it was measured.
2. **Attribute before choosing a category.** The catalogue's impact order is a
   hypothesis generator, not a diagnosis; the dominant cost must be attributed to
   a specific boundary with evidence before any rule is picked.
3. **One hypothesis per diff.** Change one thing, named by the rule it
   implements; batched "performance passes" make re-measurement
   uninterpretable.
4. **Re-measure with the same method.** A change that does not move the number is
   reverted, not kept "because it is better practice" — an unmeasured optimization
   is mechanism without benefit.
5. **Behaviour tests do not change to accommodate a performance change.** A perf
   refactor that requires editing assertions is a behaviour change wearing a
   disguise; deleting or weakening a test to make a benchmark look better is
   never in scope.
6. **Immutability holds until a measurement says otherwise.** Micro-optimizations
   that mutate or reuse are legitimate only inside a proven hot path and only
   local to a pure function's own scope — never a caller's array or a shared
   object.
7. **No `any`, no unjustified assertion, for speed.** Skipping schema validation
   at a trust boundary is a correctness change, not an optimization.
8. **Memoization is earned, not default.** `useMemo`/`useCallback`/`memo` assume
   a measured re-render problem; prefer deleting the cause over adding a cache.
9. **Prefer removing mechanism to adding it.** A fix that deletes a waterfall, a
   provider, or a bundle entry beats one that adds a cache, a ref, or a memo with
   the same measured effect.
10. **Measure what the user feels.** Development mode, warm caches, and
    bundle-size wins off the critical path are not user evidence.

## Execution Steps

1. **BASELINE** — write down the symptom, the measurement method, and the
   starting number; confirm it is reproducible (`rules/measurement-method.md`).
2. **ATTRIBUTE** — profile and locate the dominant cost at a specific boundary
   with the evidence that attributes it.
3. **APPLY** — read the specific rule, change exactly one thing, and check it
   against the house rules (`rules/house-rules.md`).
4. **RE-MEASURE** — repeat the step-1 measurement; revert if the number did not
   move; record the before/after pair where the reviewer will see it.
5. **VERIFY** — behaviour tests unchanged and green; every micro-optimization
   inside a proven hot path with immutability and typing intact
   (`rules/anti-patterns.md` completion check).

If two rule sources disagree, the more specific one wins: framework-specific
semantics over general React, field-metric guidance over component-level
micro-cost.

## Output Contract

Every performance change is reported with: the user-observable symptom, the
measurement method, the before/after pair from the same method, the single rule
applied, and confirmation that behaviour tests are unchanged and green. A diff
that cannot state its before/after pair is not done. Reverted attempts are
reported as reverted, not hidden.

## References

- `rules/measurement-method.md` — the four-step method with completion criteria.
- `rules/house-rules.md` — where house rules win over performance advice.
- `rules/anti-patterns.md` — failure modes and the completion check.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When they are not installed, apply the rules
directly: prove browser-observable behaviour survived with the front-end-testing
and react-testing companions' subject matter; treat re-render storms caused by
flow logic scattered across `useState`/`useEffect` as a modelling problem —
a state machine or derived value, not another effect (the xstate companion's
subject); record a rule's conflict with a primary source via the project's
expectations ledger; and treat added mechanism as a cost (the
reduce-system-complexity companion's subject).
