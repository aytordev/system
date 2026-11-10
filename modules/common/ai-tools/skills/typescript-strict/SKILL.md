---
name: typescript-strict
description: "Trigger: writing or reviewing TypeScript, defining types or schemas, choosing type versus interface, branding identifiers or amounts, tightening tsconfig. Applies strict-mode boundary typing, single-owner value sets, and validating constructors."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# TypeScript Strict

Language-level contract for TypeScript that compiles under strict mode. It
governs how untrusted values are typed, which declaration form to choose, and
which compiler checks back the contract. It does not decide a repository's
architecture, layering, or test strategy.

`rules/` and `references/` are bundled with this skill. Repository facts such as
`tsconfig.json` or a schema library are target-repository context, not bundled
resources. Use the host's equivalent file, search, and terminal capabilities;
report a missing capability instead of claiming the work was verified.

## Activation Contract

Use this skill when:

- Writing or reviewing TypeScript intended to compile under strict mode.
- Introducing, changing, or reviewing a type, a branded primitive, a runtime
  schema, or a fixed set of literal values.
- Choosing between `type` and `interface`, or resolving a disagreement about it.
- Assessing a `tsconfig.json` or proposing stricter compiler flags.

Do not use it to invent an architecture, force a schema library, or restyle
JavaScript that has no TypeScript surface.

## Hard Rules

1. Use `unknown` at untrusted boundaries. Contain unavoidable `any` in a narrow
   external declaration or interop shim, and explain why it is there.
2. No type assertion (`as Type`) without justification. A validating constructor
   or a schema `transform` is that justification; a cast that merely silences the
   compiler is not.
3. Follow the repository's `type`/`interface` convention. When no convention
   exists, choose from language semantics, not from preference.
4. Derive a value set that already has an owner; never spell the same set twice.
5. Validate untrusted data at the boundary, then pass plain derived types through
   internal logic. Internal functions trust their inputs.

## Rules

### 1. Boundaries (CRITICAL)

- `types-unknown-boundaries` — Untrusted input enters as `unknown` and is narrowed by validation
- `types-assertions` — Assertions, `any`, and the narrow cases that still justify them

### 2. Type Shapes (CRITICAL)

- `types-type-vs-interface` — Declaration-form semantics and when each form is correct
- `types-single-owner` — One owner per value set and per owned contract
- `types-branded` — Branded primitives conferred only by a validating constructor

### 3. Schemas (HIGH)

- `schemas-trust-boundaries` — Where a runtime schema is required and where it is noise

### 4. Configuration (HIGH)

- `config-tsconfig` — Strict baseline, additional project checks, and flags to assess

## Execution Steps

1. **Locate the boundary.** Identify where the value enters from HTTP, a queue, a
   file, the environment, a third-party SDK, or storage. Everything after it is
   internal.
2. **Search before declaring.** Look for an existing type, `as const` list, or
   schema that already owns a value set or contract before adding another.
3. **Choose the form.** Apply `types-type-vs-interface` semantics; prefer deriving
   over restating.
4. **Validate once, at the boundary.** Parse with a schema or a validating
   constructor, then hand internal code the derived plain type.
5. **Check the compiler contract.** Read the repository's own `tsconfig.json`
   before proposing flags; add a flag only with the migration it implies.

## Output Contract

Report the boundary that was validated, the single owner of each value set or
contract, and every assertion or `any` that remains with its justification. If
the repository has no readable TypeScript configuration or no runnable
type-check, say so instead of asserting compliance.

## References

- `rules/types-unknown-boundaries.md` — boundary typing.
- `rules/types-assertions.md` — assertions and interop escape hatches.
- `rules/types-type-vs-interface.md` — declaration forms.
- `rules/types-single-owner.md` — derived value sets and schema ownership.
- `rules/types-branded.md` — branded primitives.
- `rules/schemas-trust-boundaries.md` — runtime schema placement.
- `rules/config-tsconfig.md` — compiler settings.
- `references/provenance.md` — upstream source, revision, and license notice.

Immutability typing (`readonly`, `ReadonlyArray<T>`) belongs to the companion
`functional` skill when this collection is installed. Without it, apply the rule
directly: mark every property `readonly` and every array `ReadonlyArray<T>` or
`readonly T[]` where immutability is part of the contract, and remember the
compiler enforces only shallow immutability.
