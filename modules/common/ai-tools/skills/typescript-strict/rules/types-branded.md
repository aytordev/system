---
title: Brand Primitives That Are Interchangeable
impact: CRITICAL
impactDescription: Stops same-typed values from being passed in each other's place
tags: types, branding, constructors
---

## Brand Primitives That Are Interchangeable

**Impact: CRITICAL**

Brand a primitive when two values of the same underlying type can be passed in
each other's place and the compiler would not notice: two kinds of identifier,
an amount and a rate, a raw and a normalised string. Validating each one at the
boundary is not enough on its own — if the parsed values are still `string`
afterwards, a swapped pair compiles everywhere downstream.

```typescript
type UserId = string & { readonly brand: unique symbol };
type PaymentMinorUnits = number & { readonly brand: unique symbol };
type Currency = 'GBP' | 'USD' | 'EUR';

type PaymentMoney = {
  readonly minorUnits: PaymentMinorUnits;
  readonly currency: Currency;
};

const processPayment = (userId: UserId, amount: PaymentMoney): void => {
  // implementation
};
```

### Confer the brand only where the value is validated

```typescript
const toUserId = (raw: string): UserId => {
  if (raw.length === 0) throw new Error('UserId cannot be empty');
  return raw as UserId;
};

const toPaymentMinorUnits = (raw: number): PaymentMinorUnits => {
  if (!Number.isSafeInteger(raw) || raw <= 0) {
    throw new Error('Payment minor units must be a positive safe integer');
  }
  return raw as PaymentMinorUnits;
};

const toPaymentMoney = (minorUnits: number, currency: Currency): PaymentMoney => ({
  minorUnits: toPaymentMinorUnits(minorUnits),
  currency,
});

// ❌ raw values no longer compile
processPayment('user-123', 100);

// ✅ values carry proof of validation
processPayment(toUserId('user-123'), toPaymentMoney(2_500, 'GBP'));
```

### Never scatter the cast

`as UserId` belongs inside the constructor, or inside a schema `transform` and
nowhere else. Every other occurrence is a validation bypass that silently
reintroduces the bug the brand exists to prevent.

### Brand what the compiler would otherwise confuse

Good candidates: identifiers of different entities, minor units and basis
points, tenant and account keys, ISO strings that differ by format, sanitised
and raw input. Bad candidates: a single value with no sibling of the same type
— the brand only adds ceremony.

### Amounts and precision

Prefer integer minor units over major-unit floats. The constructor above rejects
`NaN`, infinities, and binary-float fractions. If a boundary accepts decimal
major-unit text instead, parse it with the currency's minor-unit exponent and a
named rounding policy, or reject excess precision. Never use
`Math.round(rawNumber * 100)`.
