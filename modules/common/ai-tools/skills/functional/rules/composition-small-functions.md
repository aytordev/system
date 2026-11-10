---
title: Compose Small Functions
impact: HIGH
impactDescription: Replaces monolithic logic with testable pieces, without abstraction sprawl
tags: composition, refactoring
---

## Compose Small Functions

**Impact: HIGH**

Compose small functions into larger ones. Each function does one thing well, so
each is easier to understand, test, reuse, and change independently.

Small pure functions are an implementation technique, not a mandate to publish
one function per module. Keep related helpers private and colocated when they
compose into one coherent responsibility, and let the caller-facing contract
stay stable while the internals move.

**Incorrect (one function doing validation, transformation, and I/O):**

```typescript
function registerScenario(input: unknown) {
  if (typeof input !== 'object' || !input) throw new Error('Invalid input');
  if (!('id' in input) || typeof input.id !== 'string') throw new Error('Missing id');
  if (!('name' in input) || typeof input.name !== 'string') throw new Error('Missing name');
  if (!('mocks' in input) || !Array.isArray(input.mocks)) throw new Error('Missing mocks');
  // ...50 more lines of validation and registration
}
```

**Correct (composed, each step named):**

```typescript
const validate = (input: unknown): Scenario => ScenarioSchema.parse(input);
const register = (scenario: Scenario): void => registry.register(scenario);

const registerScenario = (input: unknown): void => register(validate(input));
```

### Compose instead of nesting calls

A three-argument call built from inner calls hides the reading order. Name the
intermediate values, or use a value-first `pipe` when the project already has one:

```typescript
const finalizeOrder = (order: Order): Order => {
  const discounted = addDiscount(order, 1_000);
  const shipped = addShipping(discounted, createMoney(599, order.currency));
  return addTax(shipped, 2_000);
};
```

Worked pipelines are in
[composition patterns](../references/composition-patterns.md).

### Functional Light guardrail

**Do:** pure functions, immutable data, composition, declarative code, array
methods, `readonly` typing.

**Don't:** category theory, monads, heavy FP libraries, or an abstraction whose
only justification is that it is functional.

**Incorrect (abstraction with no second caller):**

```typescript
const compose =
  <T>(...fns: Array<(arg: T) => T>) =>
  (x: T) =>
    fns.reduceRight((value, fn) => fn(value), x);

const withoutInactive = compose(
  (users: readonly User[]) => users.filter((user) => user.active),
  (users: readonly User[]) => users.filter((user) => !user.suspended),
)(users);
```

**Correct (the pipeline is visible):**

```typescript
const withoutInactive = users
  .filter((user) => user.active)
  .filter((user) => !user.suspended);
```

### Extracting is a design act

Extract when a name explains *why*, when a piece is reused, or when a test needs
the boundary. Do not extract a single expression that its one caller already
reads clearly.
