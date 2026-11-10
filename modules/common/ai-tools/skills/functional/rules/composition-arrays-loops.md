---
title: Choose Array Methods or Loops by Intent
impact: HIGH
impactDescription: Makes whole-collection work declarative and immutable by default
tags: arrays, iteration, composition
---

## Choose Array Methods or Loops by Intent

**Impact: HIGH**

Prefer `map`, `filter`, and `reduce` for transformations: they are declarative
(what, not how) and return new arrays instead of mutating.

```typescript
const scenarioIds = scenarios.map((scenario) => scenario.id);
const activeScenarios = scenarios.filter((scenario) => scenario.active);
const totalActiveMinutes = sessions
  .filter((session) => session.active)
  .map((session) => session.durationMinutes * session.repetitions)
  .reduce((sum, minutes) => sum + minutes, 0);
```

### Map the intent to the method

| Intent | Use |
| --- | --- |
| Transform every element | `map` |
| Keep a subset | `filter` |
| Fold into one value | `reduce` |
| First match | `find` / `findIndex` |
| Existence | `some` / `every` |
| Group by a field | `Object.groupBy` or a `Map` built in a `reduce` |
| Lookup keyed by a field | `Map` built in a `reduce`, or `Object.fromEntries` |

### When a loop is the right choice

An imperative loop is fine when:

- Early termination is essential — use `for...of` with `break` or `return`.
- It is measurably performance-critical. Measure first.
- Side effects are the point (logging, DOM, awaiting in sequence).

A loop that runs to completion is none of those cases, however clearly it reads
and whatever it accumulates into. Folding each element into a value declared just
above the loop, grouping by key, building a lookup, or tallying a total is
`reduce` — including when the fold calls a helper whose return value becomes the
accumulator. A one-to-one rewrite is `map`; keeping a subset is `filter`; a
lookup keyed by a field is `reduce`/`Object.groupBy`, not a `for...of` that `set`s
into a pre-made `Map`.

**Incorrect (a fold spelled as a loop):**

```typescript
const totals = new Map<string, number>();
for (const line of lines) {
  const current = totals.get(line.sku) ?? 0;
  totals.set(line.sku, current + line.quantity);
}
```

**Correct (the fold is the intent):**

```typescript
const totals = lines.reduce(
  (acc, line) => acc.set(line.sku, (acc.get(line.sku) ?? 0) + line.quantity),
  new Map<string, number>(),
);
```

Keep a loop that already `break`s or `return`s out of its body rather than
contorting an early exit into a method chain.

### Avoid mutation inside the callback

`map`, `filter`, and `reduce` callbacks must not write outside themselves: a
`map` with a `push` into an outer array is a `filter`. Return the value.

### Chained chains have a cost

Each step allocates. That is usually the right trade for clarity; when a chain is
hot, measure before collapsing it into one `reduce` or a loop.
