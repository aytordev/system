---
title: Flatten Nesting with Guard Clauses
impact: HIGH
impactDescription: Keeps the main path visible and testable
tags: composition, control-flow, readability
---

## Flatten Nesting with Guard Clauses

**Impact: HIGH**

Treat deep nesting as a readability signal, not a numeric rule. When nested
control flow hides the main path, flatten it with guard clauses or extract a
named predicate.

**Incorrect (the successful path is the deepest branch):**

```typescript
function processOrder(order: Order) {
  if (order.items.length > 0) {
    if (order.customer.verified) {
      if (order.total > 0) {
        if (order.payment.valid) {
          // main logic, four levels down
        }
      }
    }
  }
}
```

**Correct (guards state the preconditions first):**

```typescript
function processOrder(order: Order) {
  if (order.items.length === 0) return;
  if (!order.customer.verified) return;
  if (order.total <= 0) return;
  if (!order.payment.valid) return;

  // main logic at the top level
}
```

**Also correct (the predicate has a name):**

```typescript
function processOrder(order: Order) {
  if (!canProcessOrder(order)) return;
  const validated = validateOrder(order);
  return executeOrder(validated);
}

function canProcessOrder(order: Order): boolean {
  return order.items.length > 0
    && order.customer.verified
    && order.total > 0
    && order.payment.valid;
}
```

### Guards vs a boolean expression

- Use guards when each failure means "stop here", so the main path stays flat.
- Use one boolean expression when the function's whole answer is that decision.
- Use extraction when the condition needs a name, or when the same predicate
  appears twice.

### Keep the refactor honest

Flattening must not change behaviour: the guard order is the original
short-circuit order, and each guard returns the same value the nested version
fell through to. When the nested version returned different values per branch,
write the guards as explicit returns rather than collapsing them.
