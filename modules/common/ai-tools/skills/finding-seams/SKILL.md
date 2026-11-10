---
name: finding-seams
description: "Trigger: existing code has untestable dependencies that prevent writing tests - hard-coded construction of collaborators, direct global or static calls, process.env or Date.now reads inside the unit, singletons, or components that fetch their own data. Identifies the narrowest substitution point (seam) and its enabling point that puts legacy or tightly-coupled behavior under test without editing at the call site; not for test-driving new behavior or refactoring code that already has tests."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Finding Seams

Introduce the minimum substitution point needed to place existing behavior
under test; whether the seam belongs in the durable contract is a
lasting-design question (the codebase-design companion, when installed). The
steps that follow — characterizing existing behavior
(characterisation-tests), test-driving new behavior (tdd), general test
patterns (testing), and refactoring after tests exist (refactoring) — build
on the seams placed here.

## Activation Contract

Use this skill when:

- A function cannot be called in a test harness because it reaches for
  external systems directly, hard-codes a dependency, or reads
  `process.env`/the clock inside its body.
- Global or static dependencies, singletons, or internal data fetching make
  isolation impossible.

Do not use it for greenfield test-driving, general test-writing patterns, or
refactoring code that already has trustworthy tests.

## Core Concept

> A **seam** is a place where you can alter behavior in your program without
> editing in that place.

Every seam has an **enabling point** — the place where you choose which
behavior to activate. The source code at the seam stays identical in
production and test; only the enabling point differs.

A seam is not automatically a public interface, port, or permanent
abstraction; introduce the narrowest safe substitution point first. Ports in
an explicitly ports-and-adapters system are designed-in seams (port =
contract, composition root = enabling point); this skill is for code that
lacks them.

*— Michael Feathers, Working Effectively with Legacy Code (2004)*

## Hard Rules

1. **Every seam has an enabling point.** No place that chooses which behavior
   runs means it is not a seam.
2. **Parameter injection is the default choice.** Pass the dependency as a
   parameter with a production default that reproduces today's behavior
   exactly.
3. **Module mocking is scaffolding, never architecture.** `vi.mock()` /
   `jest.mock()` bypasses type safety, couples tests to implementation, and
   needs cleanup. Never write a new module mock when you can change the
   signature, and never copy one from a neighbouring test: an existing module
   mock is scaffolding to migrate away from.
4. **Never pass the real collaborator through the seam.** A fake is a stand-in
   you hand-write in the test and fully control — not the production client or
   an in-memory convenience object, whatever its comments claim. A test built
   on the real collaborator still breaks when its shape changes.
5. **If the test still needs `vi.mock()`, `vi.stubEnv()` or fake timers, a
   dependency is still hidden** — move it to the argument list instead.
6. **Break one dependency at a time:** seam, passing test, next dependency.

## Execution Steps

1. List **every** hidden dependency the function reaches for — collaborators
   it constructs, `Date.now()` / `new Date()`, `process.env`, singletons. All
   of them, not just the one that annoys you most.
2. Move each one to the argument list with a production default that
   reproduces today's behavior exactly — the `new` and the env read now live
   in the default, so production is unchanged. When you are done the function
   under test constructs nothing and reads no global.
3. Write the test by passing fakes in as arguments, choosing the lightest
   seam type that works (Quick Reference below; detail in
   `rules/seam-selection.md`).
4. Remove any module mock of that dependency the existing tests carry — the
   seam replaces it, and leaving both means the old test still cannot see what
   the mock hides.

### Quick Reference: Seam Types for TypeScript/JS

| Seam Type | Mechanism | Enabling Point | Prefer When |
|-----------|-----------|---------------|-------------|
| **Function Parameter** | Pass dependency as argument | The argument list | **Default choice.** Functional code, explicit contracts |
| **Configuration** | Receive config/env values as arguments | The argument list of the receiving function | Infrastructure-level concerns; a `process.env` read inside the unit is a hidden dependency, not a Configuration seam |
| **Module** | `vi.mock()` / `jest.mock()` replaces imports | Test file mock configuration | **Last resort.** Scaffolding only |
| **Object** | Subclass and override, or DI via constructor | Where the object is created | Legacy class-based code (`references/oop-patterns.md`) |

From preferred to last resort, start with the most explicit option that
works: (1) function parameter injection, (2) higher-order factory,
(3) configuration injection, (4) module mocking (**scaffolding only**),
(5) subclass and override, legacy class code only. Steps 1–3 become durable
design only when the lasting contract earns them; steps 4–5 are normally
temporary scaffolding.

### Quick example

```typescript
// BEFORE: a hidden API dependency blocks testing (full walkthrough in
//   references/creating-seams.md). AFTER: parameter seam with default.
type TransitDaysResolver = (region: string) => number;

const scheduleDelivery = (
  delivery: Delivery,
  resolveTransitDays: TransitDaysResolver = fetchTransitDays,
): DeliveryPlan => {
  const transitDays = resolveTransitDays(delivery.region);
  return { ...delivery, totalDays: delivery.preparationDays + transitDays };
};

// Test -- swap in a fake at the enabling point (the argument list)
const result = scheduleDelivery(testDelivery, () => 2);
```

Production code is unchanged at every call site (the default kicks in). Tests
pass a fake. The seam is the parameter; the enabling point is the argument
list.

## Output Contract

When you hand the work back, name the seam type you introduced and where its
enabling point is (file and line of the parameter default, the `??` fallback,
or the factory call), confirm the existing call sites are unchanged, and list
any module mocks removed or still pending migration. No enabling-point
location, no complete hand-back.

## References

- `rules/seam-selection.md` — finding seams, granularity, smell-to-technique.
- `rules/common-mistakes.md` — mistakes table and sensing without mocks.
- `references/seam-types.md`, `references/creating-seams.md`,
  `references/oop-patterns.md` — FP-first and OOP deep-dive examples.
- `references/provenance.md` — upstream source, revision, and licence notice.
