---
title: Test Through the Owning Interface
impact: CRITICAL
impactDescription: Keeps tests valid across refactors and honest about the layer proved
tags: testing, contract, layering
---

## Test Through the Owning Interface

**Impact: CRITICAL**

Every layer has its own public interface, and the claim under test decides which
one owns the evidence.

| Claim under test | Interface that owns the evidence |
| --- | --- |
| Domain or application behaviour | Exported domain or application operation |
| HTTP API contract | HTTP client plus the documented request/response contract |
| Component behaviour | Rendered DOM plus public props and events |
| Browser or frontend behaviour | Navigation, accessible UI, lifecycle, browser-observed network |
| User journey | Accessible user actions and user-visible outcomes on the real path |

An endpoint can be public and still be the wrong interface for a browser claim: a
"user creates X" test that calls the endpoint directly proves an HTTP contract
while bypassing the UI handler, cookie policy, CSRF checks, redirects, loading and
error state, and rendering. It stays green when any of those break.

**Incorrect — proving HOW, or proving a lower layer:**

```typescript
it('should call validateAmount', () => {
  const spy = vi.spyOn(validator, 'validateAmount');
  processPayment(payment);
  expect(spy).toHaveBeenCalled();
});

it('should validate CVV format', () => {
  expect(validator._validateCVV('123')).toBe(true);
});
```

**Correct — asserting the observable outcome:**

```typescript
it('rejects negative amounts', () => {
  const payment = getMockPayment({ amountMinorUnits: -100, currency: 'GBP' });
  expect(processPayment(payment)).toEqual({
    success: false,
    error: expect.stringContaining('Amount must be positive'),
  });
});
```

Assert on the whole `Result` rather than reaching for `result.error` after a
separate `expect(result.success)` check: `toBe(false)` does not narrow a
discriminated union, and the whole-value assertion is stronger against mutants
anyway.

### Reach code through behaviour

Validation is exercised by tests of the behaviour it protects. When coverage
drops, ask "what business behaviour am I not testing?", not "what line am I
missing?".

### Do not extract merely to mirror tests

Do not split a helper into its own file so it can have a matching test. Extract
when it creates a coherent contract or seam, improves readability, or represents
shared knowledge. If a behaviour is hard to test because a dependency is in the
way, treat that as design evidence and introduce one coherent seam rather than
hiding it behind implementation-detail tests.

The anti-pattern is the 1:1 map: one implementation file, one test file. Inline
code is covered by its consumer's behavioural tests.
