---
title: Configure Strict Mode Deliberately
impact: HIGH
impactDescription: Makes the compiler enforce the contract instead of politely warning
tags: tsconfig, compiler, strict
---

## Configure Strict Mode Deliberately

**Impact: HIGH**

Read the repository's `tsconfig.json` before proposing flags. Enabling a flag is
a migration, not a preference: it produces errors that someone must fix, and a
flag enabled with widespread `@ts-expect-error` comments is not enforced.

### Baseline

```json
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

- **`strict: true`** enables the strict family, including `noImplicitAny` and
  `strictNullChecks`. Do not enable its members individually as a substitute;
  that is how a project ends up with "strict" that is not.
- **`noUnusedLocals`**, **`noUnusedParameters`** — dead values must not linger.
- **`noImplicitReturns`** — every code path returns a value.
- **`noFallthroughCasesInSwitch`** — no accidental case fallthrough.

### Flags to assess against the codebase

These are stricter than the baseline and each one has a real migration cost. Add
them when the codebase can absorb the change; do not claim strictness the
configuration does not have.

```json
{
  "compilerOptions": {
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "forceConsistentCasingInFileNames": true,
    "allowUnusedLabels": false
  }
}
```

- **`noUncheckedIndexedAccess`** — array and record access returns `T |
  undefined`, preventing runtime failures from assuming an element exists. It is
  the highest-value addition and the most invasive.
- **`exactOptionalPropertyTypes`** — distinguishes `property?: T` from
  `property: T | undefined`.
- **`noPropertyAccessFromIndexSignature`** — forces bracket notation for
  dynamic keys, making dynamic access visible.
- **`forceConsistentCasingInFileNames`** — prevents case-sensitivity failures
  across operating systems.
- **`allowUnusedLabels: false`** — catches labels that do nothing.

### `noUnusedParameters` catches design issues

An unused parameter often means the value belongs to a different layer, or the
function is doing work that its signature no longer describes. Treat the error as
a design question before reaching for a leading underscore.

### Changing a shared configuration

A `tsconfig.json` is a contract others consume. When changing one:

1. Run the type-check and count failures per file.
2. Fix the failures rather than suppressing them.
3. Keep `include`/`exclude` and project references intact.
4. Record the flag change where the repository records decisions.
