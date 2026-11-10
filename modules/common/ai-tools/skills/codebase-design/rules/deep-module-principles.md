---
title: Keep Depth Cohesive and Honest
impact: CRITICAL
impactDescription: Prevents god modules and shallow pass-through chains
tags: codebase-design, depth, cohesion
---

## Keep Depth Cohesive and Honest

**Impact: CRITICAL**

### Vocabulary

| Term | Meaning |
|------|---------|
| **Module** | A cohesive unit with an implementation and one or more role-shaped caller contracts: a function, object, package, or capability. Scale alone does not make it a module. |
| **Interface / public contract** | Everything a caller must know to use the module correctly: operations, types, invariants, errors, ordering, configuration, lifecycle, effects, and relevant performance characteristics. This is broader than a TypeScript `interface` or a type signature. |
| **Implementation** | The decisions and behavior hidden behind the caller-facing contract. Private functions may be small and numerous without becoming public modules. |
| **Depth** | How much coherent capability and decision-making a caller gains for the contract burden it must learn. Do not measure depth by lines of code. |
| **Leverage** | The caller benefit of depth: one learned contract applies useful behavior consistently across many scenarios. |
| **Locality** | The maintainer benefit of depth: related knowledge, changes, bugs, and verification concentrate in one owner. |
| **Seam** | Per Michael Feathers, a place where behavior can be changed without editing at that place; every seam has an enabling point. Not every module contract is a seam. |
| **Adapter** | A concrete translator or implementation selected at a seam. In ports-and-adapters systems, keep that pattern's driving, driven, and test-interactor distinctions. |

Use these terms to disambiguate, not to erase useful established vocabulary.
`API`, `component`, `service`, `signature`, `boundary`, `port`, and
`bounded context` remain valid when they name those specific concepts.

### Design principles

- **Hide decisions, not merely code.** Place a responsibility behind a module
  when callers should not each know its policy, sequencing, representation,
  error recovery, or provider mechanics. A private helper extraction does not
  deepen a module if the same knowledge still leaks through its parameters and
  call order.
- **Keep depth cohesive.** A tiny contract over an incoherent implementation
  is a god module, not a good deep module. Combine behavior only when it
  shares meaning, invariants, ownership, lifecycle, or a real axis of change.
  Preserve separate modules when they evolve, fail, deploy, or authorize
  independently. An extraction earns its boundary when the reader can name the
  decision or responsibility it owns and understand the caller with less
  cross-file reconstruction; a file per helper or a chain of trivial
  forwarding functions does not establish ownership.
- **Pull complexity downward deliberately.** Make the common call simple.
  Accept complexity inside the implementation when doing so removes
  configuration, ordering, special cases, or provider knowledge from callers.
  Keep effects, failure modes, resource ownership, and performance costs
  explicit enough that callers can use the module safely.
- **Justify seams with evidence.** Create a seam for a concrete need:
  substitution, independent testing, volatility isolation, ownership, trust,
  runtime failure, or deployment. Adapter count is evidence, not a rule. A
  production adapter plus a faithful test interactor may justify a seam; two
  accidental wrappers do not.
- **Test at the stable contract.** Make caller-observable behavior the primary
  test surface. Do not export private helpers or expose internal seams solely
  to test them. A private subsystem may have focused tests when it is itself a
  coherent module or when an algorithm needs precise failure localization;
  those tests must not freeze incidental orchestration.
- **Preserve intentionally thin edges.** Do not diagnose a route leaf, CLI
  command, adapter, generated client, or composition root as shallow merely
  because it is thin. Translation and wiring should often be thin. Judge
  whether policy is hidden in the correct inside module and whether the edge
  leaks provider or transport knowledge across its contract.

### The behavior-preserving inlining test

Imagine inlining the module into every caller while preserving behavior:

- If policy, sequencing, error handling, or representation knowledge spreads
  across callers, the module earns its place.
- If callers become simpler because a pass-through disappears and no knowledge
  is duplicated, the module is shallow or misplaced.

This is the useful form of the deletion test. Do not imagine deleting the
behavior itself.
