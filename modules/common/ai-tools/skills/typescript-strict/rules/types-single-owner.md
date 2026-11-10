---
title: Keep One Owner per Value Set
impact: CRITICAL
impactDescription: Prevents a derived set from drifting away from its duplicate
tags: types, schemas, derived
---

## Keep One Owner per Value Set

**Impact: CRITICAL**

Before writing a literal union, an enum list, or a `===`/`||` chain over fixed
values, search the codebase for that set. If a type, an `as const` list, or a
schema already declares it, derive from that single owner instead of spelling it
a second time.

**Incorrect (two owners of one set; they drift on the first new value):**

```typescript
export type OrderState = 'draft' | 'placed' | 'shipped';
export const OrderStateSchema = z.enum(['draft', 'placed', 'shipped']);
```

**Correct (one owner; the type and the schema both derive from it):**

```typescript
export const ORDER_STATES = ['draft', 'placed', 'shipped'] as const;
export type OrderState = (typeof ORDER_STATES)[number];
export const OrderStateSchema = z.enum(ORDER_STATES);
export const isOrderState = (value: unknown): value is OrderState =>
  typeof value === 'string' && ORDER_STATES.some((state) => state === value);
```

### Widening beats duplicating

If the set is already declared as a hand-written union and a runtime schema now
needs it, widen the existing declaration into the derived form above. Do not
leave a second copy of the members behind in the schema, in a validation
branch, in a dropdown, or in a test fixture.

### The boundary is a contract, not a field match

Define a schema once per owned contract, version, and bounded context, then
import it within that boundary. Two independently deployed services, or two
bounded contexts, may legitimately own separate schemas even when their fields
match today: coupling them by convenience makes one release block the other.
Validate and translate at each trust boundary, and add a contract test where
drift would be expensive.

### Inside one boundary this is a search, not a judgement call

- A compile-time type and a runtime schema for the same set: one `as const` list
  owns the members.
- A validation list and a UI option list for the same set: derive the options
  from the owner.
- A `switch` over every member: keep it exhaustive and let the compiler flag a
  missing case rather than adding a `default` that hides it.

### Schema-derived types

```typescript
export const CreateUserRequestSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
});
export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
```

When the schema genuinely owns the contract, derive the type from it and import
both from the same module. Do not hand-write the type beside it.
