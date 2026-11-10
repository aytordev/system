---
title: Plan Tests Against Likely Mutants
impact: HIGH
impactDescription: Catches the green suites that hide a broken rule
tags: testing, mutation, boundaries
---

## Plan Tests Against Likely Mutants

**Impact: HIGH**

When planning or writing tests, scan the code you are about to cover against the
shapes a realistic change would take. A good test fails when the rule changes.

Before the first assertion, make two lists from that code. They are where a green
suite most often stays green over a broken rule.

### 1. Every comparison against a constant

For each `>`, `>=`, `<`, `<=`, or `===` against a threshold, name the exact
threshold and cover just below it, exactly on it, and just above. A value well
past the threshold does not distinguish `>` from `>=`; only the test sitting on
the threshold does.

```typescript
// Rule: batches of at least 100 items use the bulk path
if (items.length >= 100) return bulkPath(items);

it('uses the bulk path at exactly 100 items', () => {
  expect(pathFor(itemsOfLength(100))).toBe('bulk');
});

it('does not use the bulk path at 99 items', () => {
  expect(pathFor(itemsOfLength(99))).toBe('standard');
});
```

### 2. Every call that normalises or transforms a value

Case folding, trimming, sorting, de-duplicating, rounding, defaulting a missing
field: each is caller-observable behaviour, and each is one deletion away from
being gone. For each, pick an input whose answer changes if the call were
removed — a differently cased key where a lookup folds case, padded input where
it is trimmed, unordered input where the output is ordered — and assert the
answer.

### Other shapes worth a test

- Boolean combinations that a `&&` could become `||`.
- Arithmetic identities that a `+` could become `-`.
- Array and string operations that an off-by-one would corrupt.
- Optional chaining that silently swallows a value.
- Side effects that a removed call would drop.

### When the gap is a judgement call

Fix missing assertions, boundaries, branches, and side-effect checks directly. Ask
the human only when the expected behaviour is a product or domain decision, and
offer concrete choices with the trade-off stated.

```text
The bulk path uses `items.length >= 100`, but tests only cover 150.
Should 100 take the bulk path?
- Yes: add a boundary test for 100
- No: change the rule to `> 100`
- Unspecified: document that the boundary is not guaranteed
```
