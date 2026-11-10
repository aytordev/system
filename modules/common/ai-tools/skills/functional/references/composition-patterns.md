# Composition Patterns

Worked examples for composing small functions, refactoring monolithic logic, and
flattening deeply nested code. The directives live in
[the skill entry point](../SKILL.md) and its `rules/`.

---

## Composition Over Complex Logic

Compose small functions into larger ones. Each function does one thing well.

Benefits: easier to understand (each piece is simple), easier to test (pieces are
tested independently), easier to reuse (pieces work in several contexts), easier
to maintain (change one piece without touching the rest).

❌ **Monolithic — validation, parsing, and registration in one body**

```typescript
function registerScenario(input: unknown) {
  if (typeof input !== 'object' || !input) throw new Error('Invalid input');
  if (!('id' in input) || typeof input.id !== 'string') throw new Error('Missing id');
  if (!('name' in input) || typeof input.name !== 'string') throw new Error('Missing name');
  if (!('mocks' in input) || !Array.isArray(input.mocks)) throw new Error('Missing mocks');
  // ...50 more lines of validation and registration
}
```

✅ **Composed — each step named and individually testable**

```typescript
const validate = (input: unknown): Scenario => ScenarioSchema.parse(input);
const register = (scenario: Scenario): void => registry.register(scenario);

const registerScenario = (input: unknown): void => register(validate(input));
```

---

## Composing Immutable Transformations

```typescript
type Currency = 'GBP' | 'USD' | 'EUR';
type Money = { readonly minorUnits: number; readonly currency: Currency };

const createMoney = (minorUnits: number, currency: Currency): Money => {
  if (!Number.isSafeInteger(minorUnits) || minorUnits < 0) {
    throw new Error('Invalid money');
  }
  return { minorUnits, currency };
};

const addMoney = (left: Money, right: Money): Money => {
  if (left.currency !== right.currency) throw new Error('Currency mismatch');
  if (!Number.isSafeInteger(left.minorUnits) || !Number.isSafeInteger(right.minorUnits)) {
    throw new Error('Invalid money');
  }
  const minorUnits = left.minorUnits + right.minorUnits;
  if (!Number.isSafeInteger(minorUnits)) throw new Error('Money addition overflowed');
  return createMoney(minorUnits, left.currency);
};

const percentageHalfUp = (money: Money, basisPoints: number): Money => {
  if (!Number.isSafeInteger(money.minorUnits)) throw new Error('Invalid money');
  if (!Number.isSafeInteger(basisPoints) || basisPoints < 0) throw new Error('Invalid rate');
  const rounded = Number(
    (BigInt(money.minorUnits) * BigInt(basisPoints) + 5_000n) / 10_000n,
  );
  return createMoney(rounded, money.currency);
};

const addDiscount = (order: Order, basisPoints: number): Order => ({
  ...order,
  total: createMoney(
    order.total.minorUnits - percentageHalfUp(order.total, basisPoints).minorUnits,
    order.total.currency,
  ),
});

const addShipping = (order: Order, cost: Money): Order => ({
  ...order,
  total: addMoney(order.total, cost),
});

const addTax = (order: Order, basisPoints: number): Order => ({
  ...order,
  total: addMoney(order.total, percentageHalfUp(order.total, basisPoints)),
});

// Compose them, naming each step
const finalizeOrder = (order: Order): Order => {
  const discounted = addDiscount(order, 1_000);
  const shipped = addShipping(discounted, createMoney(599, order.currency));
  return addTax(shipped, 2_000);
};
```

Amounts stay in integer minor units, rates in integer basis points, and
`percentageHalfUp` makes the rounding rule explicit. The currency check prevents
composing values from different currencies. Branding the minor units, as the
`typescript-strict` skill describes when it is installed, prevents an amount and
a rate of the same numeric type from being swapped.

---

## Flattening Deep Nesting

Deep nesting is a readability signal, not a fixed numeric failure. When nesting
hides the main path or makes branches hard to reason about, extract functions or
use early returns.

❌ **Four levels before the work starts**

```typescript
function processOrder(order: Order) {
  if (order.items.length > 0) {
    if (order.customer.verified) {
      if (order.total > 0) {
        if (order.payment.valid) {
          // main logic
        }
      }
    }
  }
}
```

✅ **Guards**

```typescript
function processOrder(order: Order) {
  if (order.items.length === 0) return;
  if (!order.customer.verified) return;
  if (order.total <= 0) return;
  if (!order.payment.valid) return;

  // main logic
}
```

✅ **Extraction**

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

---

## Choosing Between the Two

| Situation | Prefer |
| --- | --- |
| Each check means "stop here" | Guards |
| The function's whole answer is the decision | One boolean expression |
| The condition needs a name, or repeats | Extraction |
| The nested version returned different values per branch | Explicit guard returns |
