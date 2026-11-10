---
name: functional
description: "Trigger: writing logic or data transformations, fixing mutation bugs, or any feature that builds, merges, filters, sorts, prices, or reshapes records, lists, carts, orders, or invoices, even when it never mentions immutability. Provides immutable domain data, pure-function boundaries, composition, array-iteration choices, options objects, guard clauses, and Result values."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Functional Patterns

"Functional Light": practical functional patterns without academic abstraction.
The goal is maintainable, testable code, not purity for its own sake.

`rules/` holds directives and `references/` holds worked examples; both are
bundled with this skill. Use the host's equivalent file and terminal
capabilities; report a missing capability instead of claiming the change was
verified.

## Activation Contract

Use this skill when:

- Writing logic, data transformations, or business rules.
- Building, merging, filtering, sorting, pricing, or otherwise reshaping
  records, lists, carts, orders, or invoices — even when the request never
  mentions immutability.
- Diagnosing a mutation bug, an aliasing surprise, or a stale React render.
- Reviewing deeply nested control flow, parameter lists, or error handling.
- Working in a project that already uses Effect (see `references/effect-runtime.md`).

Do not use it to introduce monads, fp-ts, Ramda, or a ports-and-adapters layer
into a project that does not already have them.

## Hard Rules

1. **Immutable domain data by default.** Build the result and return it. Any
   mutation stays inside the function that created the value and never reaches a
   value the caller still holds. When a request asks you to change an object in
   place, the answer is still a new value: build it from the inputs
   (`{ ...value, items }`, `[...xs].sort(...)`, `xs.map(...)`), return it, and
   state in one sentence why you returned a new value rather than the object you
   were handed. If a helper you were told to reuse writes into its argument, fold
   through its return value into your own accumulator, or make that helper pure
   first — never hand it one of your inputs.
2. **Pure functions wherever possible.** Isolate unavoidable I/O, randomness,
   and clock access at the project's chosen edges.
3. **Composition over inheritance.** Small functions with one responsibility,
   composed into larger ones.
4. **Choose iteration for intent.** `map`, `filter`, `reduce`, `find`, `some`,
   `every`, `Object.groupBy` when the walk visits every element or folds into an
   accumulator; a loop earns its place only by exiting early or performing side
   effects.
5. **Do not over-apply.** If a functional pattern makes the code harder to
   understand, do not use it.

## Rules

### 1. Immutability (CRITICAL)

- `immutability-domain-data` — Immutable contracts, `readonly` typing, and encapsulated mutable state

### 2. Purity (HIGH)

- `purity-pure-core` — Pure core, impure shell, and comments that carry their weight

### 3. Composition (HIGH)

- `composition-small-functions` — Compose focused helpers instead of monolithic logic
- `composition-arrays-loops` — Array methods versus loops, chosen by intent
- `composition-guard-clauses` — Flatten nesting with guards and extraction
- `composition-options` — Group parameters when the call site becomes ambiguous

### 4. Errors as Values (MEDIUM)

- `errors-result-type` — Result values when expected failures belong to the return contract

## Execution Steps

1. **Identify the data contract.** Which values does the caller still hold, and
   may they observe a change?
2. **Declare it immutable.** Every property `readonly`, every array
   `ReadonlyArray<T>` or `readonly T[]` — including inline object types in a
   parameter position.
3. **Separate decision from effect.** Compute the outcome purely; perform the
   write, request, or log at the edge that owns it.
4. **Shape the control flow.** Guard clauses for preconditions, extraction for
   the remaining depth, array methods for whole-collection work.
5. **Choose the failure contract.** Preserve an established exception, nullable,
   or framework convention; use a Result value when expected failures are part of
   the caller-facing contract.

## Output Contract

State which values are new and which were reused, where effects are isolated, and
which contract each expected failure uses. When the request explicitly asked for
in-place mutation, report that a new value was returned instead and why. Never
claim purity for a function that reads the clock, randomness, or ambient state.

## References

| Resource | Load when |
| --- | --- |
| [immutability-catalog](references/immutability-catalog.md) | Fixing a mutation bug, applying `readonly`, or looking up the immutable alternative to an array or object mutation |
| [composition-patterns](references/composition-patterns.md) | Composing small functions into pipelines, refactoring a monolith, or flattening nested code |
| [effect-runtime](references/effect-runtime.md) | Working in an Effect-based project: runtime boundaries, service requirements, failure handling, interruption, or resource lifetime |
| [provenance](references/provenance.md) | Checking the upstream source, revision, and license notice |
