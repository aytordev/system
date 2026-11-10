---
title: Value Objects, Entities, and Honest Errors
impact: CRITICAL
impactDescription: The DDD building blocks in TypeScript
tags: ddd, value-objects, entities, branded-types, errors
---

## Value Objects, Entities, and Honest Errors

**Impact: CRITICAL**

### Value objects

Immutable, identity-less, compared by their attributes (not by reference). Two
`Money` values with the same minor units and currency are equal.

```typescript
type Currency = 'GBP' | 'USD' | 'EUR';
type Money = { readonly minorUnits: number; readonly currency: Currency };

const createMoney = (minorUnits: number, currency: Currency): Money => {
  if (!Number.isSafeInteger(minorUnits)) throw new Error('Money minor units must be a safe integer');
  if (minorUnits < 0) throw new Error('Money cannot be negative');
  return { minorUnits, currency };
};
// Factory throws = invariant violation (a bug in calling code).
// Schemas catch invalid user input at trust boundaries BEFORE the factory is
// called. If the factory throws, something bypassed the schema.
```

Store and calculate money in integer minor units, never binary floating-point
major units. A boundary that accepts decimal text must use the currency's
exponent and an explicit policy for excess precision (reject it, or round
half-even); never convert with `Math.round(rawNumber * 100)`.

For value objects crossing trust boundaries (API input, form data), use Zod
schemas; for domain-internal value objects, plain types + factory functions
suffice.

**Zod-to-branded-type bridging** — parse raw input into branded domain types
at trust boundaries:

```typescript
const PledgeInputSchema = z.object({
  occasionId: z.string().min(1).transform(createOccasionId),
  contributorId: z.string().min(1).transform(createContributorId),
  amount: z.object({ minorUnits: z.number().int().safe().positive(), currency: CurrencySchema }),
});
```

Reconstitution from persistence uses the same factory functions as creation.
The factory validates, so invalid persisted data is caught on read rather than
silently corrupting the domain.

### Branded types

- **Give every entity its own branded ID** (`OccasionId`, `GiftIdeaId`) so the
  compiler rejects cross-entity ID mixups.
- **Brand once, through one validating factory per branded type** — raw
  strings become branded values only after validation. The single `as` inside
  that factory is the only assertion the brand gets: validate, then brand. A
  value derived from a branded value is re-branded by calling the factory
  again, never by writing another `as`.
- Use branded types for entity IDs and single-value value objects
  (`EmailAddress`).

```typescript
type OccasionId = string & { readonly __brand: 'OccasionId' };

const createOccasionId = (raw: string): OccasionId => {
  if (!raw.trim()) throw new Error('OccasionId cannot be empty');
  return raw as OccasionId; // justified: factory validates, then brands
};
```

### Entities

Have identity and a lifecycle. Always valid after construction or state
transition — validate on construction and on every transition; never allow an
entity to exist in an invalid state, even temporarily.

```typescript
type Occasion = {
  readonly id: OccasionId;
  readonly name: string;
  readonly giftIdeas: ReadonlyArray<GiftIdea>;
  readonly budget: Money;
  readonly totalPledged: Money;
  readonly isFundingClosed: boolean;
};

// Immutable update — returns new valid state
const renameOccasion = (occasion: Occasion, newName: string): Occasion => ({
  ...occasion,
  name: newName,
});
```

### Make illegal states unrepresentable

Model entity **lifecycles** as discriminated unions where each variant carries
only the data valid for that state — never boolean flags plus optional fields,
which allow contradictory combinations:

```typescript
type Order =
  | { readonly status: 'draft'; readonly items: ReadonlyArray<OrderItem> }
  | { readonly status: 'placed'; readonly items: ReadonlyArray<OrderItem>; readonly placedAt: Date }
  | { readonly status: 'shipped'; readonly items: ReadonlyArray<OrderItem>; readonly placedAt: Date; readonly shippedAt: Date; readonly trackingNumber: string };
```

**Always handle all lifecycle variants exhaustively** — the `never` type
ensures the compiler catches unhandled states when you add a new variant.

### Specifications

Complex business rules for filtering, eligibility, or validation are expressed
as predicate functions in the domain layer. Specifications are pure — they
return `boolean`, have no side effects, and are named with `is`, `can`, or
`has` prefixes.

```typescript
const isGiftReady = (occasion: Occasion): boolean =>
  occasion.totalPledged.minorUnits >= occasion.budget.minorUnits &&
  occasion.giftIdeas.some(idea => idea.status === 'selected');
```

### Error modeling

Use discriminated union result types for expected business outcomes; reserve
exceptions for programmer mistakes and infrastructure failures.

```typescript
type PledgeDecision =
  | { readonly success: true; readonly occasion: Occasion; readonly events: readonly PledgeRecorded[] }
  | { readonly success: false; readonly reason: 'contributor-ineligible' | 'non-positive-amount' | 'currency-mismatch' | 'exceeds-budget' | 'funding-closed' };

type PledgeResult =
  | PledgeDecision
  | { readonly success: false; readonly reason: 'not-found' | 'concurrent-change' }; // application outcomes
```

**The test:** could a user's action legitimately cause this outcome? If yes →
result type. If no (it would mean a bug) → exception. Errors propagate through
layers: domain returns business reasons; the use case adds application
outcomes; the driving adapter translates reasons into its own vocabulary.

### Repositories

Repositories provide collection-like access to aggregates. Put the **interface
with the innermost policy that consumes it** and the concrete implementation
with infrastructure or integration code; in an explicitly hexagonal system the
port is normally application-owned, implemented by a driven adapter.
Repositories use `interface` (not `type`) because they define behavior
contracts, and their methods use domain language.

**Repositories handle writes and single-aggregate reads.** For reads that need
to JOIN across aggregates (dashboards, detail pages), repositories are the
wrong tool — use query functions that JOIN freely instead (CQRS-lite). For
simple domains where reads map cleanly to a single aggregate, don't separate
prematurely.
