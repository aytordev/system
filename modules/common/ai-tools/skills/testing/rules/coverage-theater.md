---
title: Detect Coverage Theatre
impact: HIGH
impactDescription: Finds tests that execute code without proving behaviour
tags: testing, coverage, anti-patterns
---

## Detect Coverage Theatre

**Impact: HIGH**

Four patterns execute code, raise the percentage, and prove nothing.

### 1. Mocking the function under test

```typescript
// WRONG - asserts the mock, not the behaviour
const spy = vi.spyOn(validator, 'validate');
validator.validate(payment);
expect(spy).toHaveBeenCalled();

// CORRECT
expect(validate(getMockPayment({ amountMinorUnits: -100 }))).toEqual({
  success: false,
  error: expect.stringContaining('Amount must be positive'),
});
```

### 2. Asserting only that a collaborator was called

```typescript
// WRONG - "so what?"
expect(spy).toHaveBeenCalledWith(payment);

// CORRECT - assert the outcome
expect(handlePayment(payment)).toEqual({
  success: true,
  data: { transactionId: expect.any(String) },
});
```

**Exception:** asserting on a callback the caller supplied through the public API
is behaviour testing, not theatre — an `onSubmit` prop's invocation *is* the
observable contract. The pattern forbids spying on internal collaborators the
caller never provided.

### 3. Trivial getters and setters

```typescript
// WRONG - proves assignment, not behaviour
worker.setRetryLimit(3);
expect(worker.getRetryLimit()).toBe(3);

// CORRECT - prove the consequence
expect(retryDelaysFor(3)).toEqual([1_000, 2_000, 4_000]);
```

### 4. Full line coverage, no branch coverage

A happy-path-only suite covers the function and misses every refusal. When the
code has refusals, boundaries, or fallbacks, each needs a case.

### Also watch for

- Shared mutable state between tests.
- Lifecycle hooks without reliable cleanup.
- Trusting a coverage percentage without running the repository's own command.
- Duplicating a production-owned schema in a test file.
- Factories that return objects incomplete for the scenario.
- Speculative code with no test demanding it.
