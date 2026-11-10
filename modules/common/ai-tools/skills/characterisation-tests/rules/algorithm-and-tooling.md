---
title: Record Behaviour From a Run
impact: CRITICAL
impactDescription: Stops a misreading of the code from becoming a certified test
tags: characterisation, snapshots, async
---

## Record Behaviour From a Run

**Impact: CRITICAL**

### The placeholder loop

```typescript
// 1. Assertion you know will fail
it('characterises formatPrice', () => {
  expect(formatPrice(1999)).toBe('PLACEHOLDER');
});
// Runner: expected 'PLACEHOLDER' but received '$19.99'

// 2. Paste what the runner printed
it('characterises formatPrice', () => {
  expect(formatPrice(1999)).toBe('$19.99');
});
```

Never compute the expected value by reading the implementation, and never copy the
function into a scratch script: both pin your reading, and a misreading becomes a
test that certifies the mistake. The file is written at least twice, with a run in
between.

### Output longer than a line

For rendered text, a formatted document, or a large object, call
`toMatchInlineSnapshot()` with no argument, run once, and let the runner write the
observed output into the test file. That is the same algorithm, automated, and it
fails on a single wrong character. Type an expectation by hand only when it is
short enough to read at a glance.

### Async code

```typescript
it('characterises fetchUserOrders for a known user', async () => {
  const result = await fetchUserOrders('user-123');
  expect(result).toEqual([
    expect.objectContaining({ id: 'order-1', status: 'shipped' }),
  ]);
});
```

- Await results. A synchronous assertion on a promise always passes.
- Characterise both resolved and rejected states:
  `await expect(fn()).rejects.toThrow()`.
- Control time with fake timers where timing matters.
- Collect emitted values into an array, then assert on the collection.

### I/O and side effects

Pass the sensing dependency in as a parameter instead of mocking internals; a
characterisation file is not the place to redesign testability. If the code cannot
be reached at all without a seam, treat that as design evidence and introduce one
coherent seam first.

### Inner-loop scope

Discover oracles with the characterisation file or its exact selector. Once the
oracle is stable, move to the runner-derived affected scope from the repository
root so transitive consumers stay eligible. Before review, stop watchers and run
the repository's complete non-watch gate.

### Common mistakes

| Mistake | Fix |
| --- | --- |
| Treating them as permanent | Replace with behaviour tests as you refactor |
| "Fixing" a bug found while characterising | Document it, mark suspicious, escalate |
| Characterising the whole codebase | Change area plus one layer out |
| Asserting what the code *should* do | Assert what the run reported |
| Deriving expected values by reading the code | Run the real module |
| Treating coverage as proof of strength | Pin likely mutant risks |
| Not awaiting async results | `async`/`await` everywhere |
