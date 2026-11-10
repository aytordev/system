---
title: Stop at Selection and Route Implementation
impact: HIGH
impactDescription: Prevents the audit from becoming unauthorized design or edits
tags: architecture, selection, routing
---

## Stop at Selection and Route Implementation

**Impact: HIGH**

The audit ends when candidates are ranked. Everything after selection is a
separate, user-owned decision.

### Let the user select the design target

Stop after the audit unless the user already authorized a specific candidate.
Ask which candidate to explore, leading with the top recommendation.

For the selected candidate:

1. When constraints or trade-offs remain decision-heavy, ask one focused
   question at a time and include a recommended answer with its trade-off.
2. Design a consequential contract with a Design-It-Two-Passes process: sketch
   the contract twice under materially different designs, compare caller burden
   and hidden knowledge, and only then commit to one.
3. Route a new or changed domain term through the project's own glossary
   mechanism instead of coining it silently.
4. When placement, packages, exports, or dependency enforcement would change,
   audit the physical structure before proposing moves.
5. Research existing solutions only when the selected direction introduces or
   replaces a material generic mechanism or dependency — not for every audit
   candidate.
6. Offer to record a durable accepted or rejected architecture decision through
   the project's decision-record mechanism when future reviews would otherwise
   re-litigate it.

### Route implementation — only when requested

Match the request to the discipline it needs; when the matching companion
skill is installed, prefer it:

- Untested or untestable existing behavior: characterize the behavior first,
  then put preservation tests around it before changing anything.
- Behavior-preserving restructuring with a trustworthy safety net: refactoring
  discipline — keep observable behavior stable.
- Selected whole-path subtraction with a trustworthy safety net: reduction
  discipline — preserve behavior while applying the behavior gate on every
  slice and the mechanism gate at terminal reduction.
- New or changed behavior: test-first discipline during implementation, then
  verify the accumulated change once at review readiness.
- Public compatibility: design the versioned contract before changing it.
- Package and import migration: apply the project's migration gates.
- Significant multi-slice delivery: plan the slices after the candidate and
  contract are selected.
- Finished high-stakes work: an adversarial second opinion is worthwhile;
  prefer an independent reviewer that starts cold.

Keep moves, dependency inversion, behavior changes, and compatibility removal
in separate verifiable slices wherever possible.

### Completion check

- Did the review target stay fixed?
- Did project intent, tests, callers, history, and runtime shape inform the
  findings?
- Are intentionally thin edges protected from false shallow-module findings?
- Does every candidate include evidence and counterevidence?
- Are consolidation and splitting both considered?
- Is the top recommendation valuable now rather than architecturally
  fashionable?
- Is the HTML report portable, accessible, escaped, and free of remote runtime
  dependencies?
- Did the audit stop before speculative interface design or unauthorized
  edits?
