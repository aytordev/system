---
title: Keep Domain Data Immutable
impact: CRITICAL
impactDescription: Removes aliasing surprises, stale renders, and mutation bugs
tags: immutability, readonly, domain
---

## Keep Domain Data Immutable

**Impact: CRITICAL**

Immutable data makes code predictable (same input, same output), debuggable
(state does not change under a reader), testable (less hidden state), and
render-safe (reference comparison means something). It also removes shared-state
hazards inside one process; it does not by itself prevent races in I/O or
coordination.

**Incorrect (the caller's object changes underneath it):**

```typescript
const user = { name: 'Alice', permissions: ['read'] };
grantPermission(user, 'write'); // mutates user.permissions internally
console.log(user.permissions); // ['read', 'write'] — surprise
```

**Correct (the result is a new value):**

```typescript
const updatedUser = grantPermission(user, 'write');
console.log(user.permissions); // ['read'] — original untouched
console.log(updatedUser.permissions); // ['read', 'write']
```

### The request may say "change it in place"

Wording like "you already hold a reference, just update it and hand it back", or
a neighbouring helper that writes into its argument, sets *what* changes; this
rule sets *how*. That a caller holds the reference is the reason not to write
through it: every other holder sees the change, a test that freezes its inputs
throws instead of passing, and a re-render that compares references sees nothing.

Build the result from the inputs, return it, and say in one sentence why you
returned a new value. If a helper you were told to reuse mutates its argument,
fold through its return value into an accumulator you created, or make that
helper pure first.

### Type the contract, not just the behaviour

When you declare a data type — including a type you add to an existing file, and
an inline `{ ... }[]` in a parameter position — mark every property `readonly`
and every array `ReadonlyArray<T>` or `readonly T[]`.

```typescript
type Scenario = {
  readonly id: string;
  readonly mocks: ReadonlyArray<Mock>;
  readonly response: {
    readonly status: number;
    readonly body: readonly unknown[];
  };
};
```

The compiler enforces shallow immutability only: it stops `scenario.id = x` and
`scenario.mocks.push(x)`, but not a write through a nested mutable object. A
mutable property is the exception you justify, not the default.

### Encapsulated mutable state is allowed

A local accumulator, a cache, a builder, or adapter state may be mutable when it
never leaks into the domain contract and never outlives the operation that owns
it. Return an immutable snapshot, not the accumulator.

### Practical checks

- Tests that assert purity should freeze their inputs (`Object.freeze`) so a
  write-through fails loudly instead of silently passing.
- `structuredClone` or a spread is a shallow copy; nested values are still
  shared.
- Sorting in place (`items.sort()`) mutates the caller's array; copy first.
- The immutable alternative to each common mutation is in
  [the immutability catalog](../references/immutability-catalog.md).
