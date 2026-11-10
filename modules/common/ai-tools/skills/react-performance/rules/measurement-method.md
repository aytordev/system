---
title: Baseline, Attribute, Apply One, Re-measure
impact: CRITICAL
impactDescription: The method that stops optimizing the wrong thing
tags: react-performance, measurement, method
---

## Baseline, Attribute, Apply One, Re-measure

**Impact: CRITICAL**

### 1. Establish the baseline

Name the symptom in user-observable terms — a slow route, an unresponsive input,
a heavy first load — and capture a *number* before touching code: a profile, a
bundle report, a trace, a field metric. Record how it was measured so the same
measurement can be repeated.

**Complete when:** the symptom, the measurement method, and the starting number
are all written down, and the number is reproducible.

### 2. Locate the cost

Find where the time actually goes before choosing a category. The prioritized
order in a rule catalogue is a good *search* order — waterfalls and bundle size
first, micro-optimizations last — but it is a hypothesis generator, not a
diagnosis. React Profiler, `next build` output, a bundle analyzer, and a network
waterfall are evidence; a plausible story about re-renders is not.

**Complete when:** the dominant cost is attributed to a specific boundary — a
request waterfall, a bundle entry, a serialization payload, a re-render path, a
layout or hydration step — with the evidence that attributes it.

### 3. Apply one rule at a time

Read the specific rule — from the project's pinned rule catalogue where one
exists, not from memory — then change one thing. Batched "performance passes"
make the re-measurement uninterpretable and turn a review into a guess.

Before the change lands, check it against the house rules.

**Complete when:** exactly one hypothesis is in the diff, and the rule it
implements is named.

### 4. Re-measure and keep the evidence

Repeat the step-1 measurement. A change that does not move the number is
reverted, not kept "because it is better practice" — an unmeasured optimization
is mechanism without benefit, and added mechanism is a cost even when a rule
suggested it.

Record the before/after pair in the PR. Performance is a non-functional
guarantee, so this measurement *is* the evidence for the change; it does not
substitute for the behavior tests, which must be unchanged and green.

**Complete when:** the same measurement is reported before and after, and every
behavior test still passes without modification.

### Where the rules live

Rule catalogues, where a project pins one, own the individual rules; this skill
owns the method that governs applying any of them. Typical catalogue shapes:

- Prioritized React/Next.js rule collections (`async-` waterfalls, `bundle-`
  size, server/client rendering and fetching, `rerender-`, rendering, `js-`
  micro-costs) — reach for the specific rule file once a bottleneck is measured.
- Component-API composition guidance — when the re-render or prop-drilling
  problem is really a component-API problem.
- Framework semantics (App Router structure, RSC boundaries, caching and
  revalidation) — when the question is framework behaviour rather than React
  cost.
- Field-metric guidance (LCP/INP/CLS, non-React budgets, images, fonts, third
  parties) — when the complaint is a user-facing metric, not a React-internal
  cost.

If two sources disagree, the more specific one wins: framework-specific
semantics over general React, field-metric guidance over component-level
micro-cost. When a catalogue rule contradicts the primary documentation
(React or Next.js) for the version actually in use, the primary source wins and
the divergence is recorded in the project's expectations ledger.
