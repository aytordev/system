---
title: Return Result Values for Expected Failures
impact: MEDIUM
impactDescription: Makes the failure contract checkable by the compiler
tags: errors, result, contracts
---

## Return Result Values for Expected Failures

**Impact: MEDIUM**

Use a `Result` type when expected failures are part of the caller-facing contract
and callers must handle both branches. Do not convert every failure into one.

```typescript
type Result<T, E = Error> =
  | { readonly success: true; readonly data: T }
  | { readonly success: false; readonly error: E };

function processBatch(batch: Batch): Result<BatchRun> {
  if (batch.itemCount <= 0) {
    return { success: false, error: new Error('Batch must contain an item') };
  }
  return { success: true, data: executeBatch(batch) };
}

const result = processBatch(batch);
if (!result.success) return logError(result.error);
console.log(result.data.batchId); // narrowed: data exists here
```

### Preserve the existing convention

An established exception, nullable-value, or framework error convention that
communicates the contract more clearly stays. Consistency at the call site beats
a second error style inside one module.

### Business outcomes are not errors

Existing outcome unions can remain values, including refusals. Translate them
directly at the consumer boundary instead of converting each refusal into an
exception or a tagged failure and immediately catching it to recover the same
outcome.

**Incorrect (an expected refusal becomes an exception):**

```typescript
try {
  const outcome = chargeCard(card);
  if (outcome === 'duplicate') return 'ignored';
} catch (error) {
  if (error instanceof DuplicateCharge) return 'ignored';
}
```

**Correct (the refusal is already a value):**

```typescript
const outcome = chargeCard(card);
if (outcome === 'duplicate') return 'ignored';
```

### Rules for Result

- Include the failure mode in the type; never leave `unknown` in an error field
  the caller must inspect.
- Return early on the failure branch; do not nest the success path inside an `if`.
- Do not throw from a function that returns `Result` for its expected failures;
  unexpected failures may still throw to the boundary that owns reporting.
- Do not wrap and unwrap in the same layer. If the caller only re-throws, the
  wrapper adds nothing.
- Use `readonly` members so a receiver cannot rewrite the outcome.
