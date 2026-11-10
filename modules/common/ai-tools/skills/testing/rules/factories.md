---
title: Build Fixtures from Factories
impact: HIGH
impactDescription: Removes order-dependent tests and schema drift in fixtures
tags: testing, factories, fixtures
---

## Build Fixtures from Factories

**Impact: HIGH**

The trigger is mechanical, not a matter of taste: if more than one test in a file
constructs the same object shape — including the same shape inside `it.each` rows,
or spread from another object to change one field — that shape gets a factory, and
the differing fields become overrides. Genuinely single-use scalars stay inline.

### Rules

1. Return objects valid for the scenario; intentional invalidity is explicit in
   the name and type.
2. Use typed overrides when the language supports them.
3. **Reuse the module's own schema** when it exports one. A type-annotated
   literal is checked against a type, not against the boundary the code validates
   at, so it misses exactly the drift a fixture should catch.
4. Fresh state per test. Lifecycle hooks are acceptable only with isolated setup
   and reliable cleanup; a shared `let` rebuilt in `beforeEach` is the same
   anti-pattern wearing a hook. When you touch a file that uses shared state,
   replace that setup as part of the same change.

```typescript
import { UserSchema } from '@/schemas';

const getMockUser = (overrides?: Partial<User>): User =>
  UserSchema.parse({
    id: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
    role: 'user',
    isActive: true,
    ...overrides,
  });
```

### Composition

Compose factories for nested values instead of rebuilding them:

```typescript
const getMockOrder = (overrides?: Partial<Order>): Order =>
  OrderSchema.parse({
    id: 'order-1',
    items: [getMockItem()],
    customer: getMockCustomer(),
    payment: getMockPayment(),
    ...overrides,
  });
```

### Anti-patterns

```typescript
// WRONG: one mutable object shared by the suite
const user: User = { id: 'user-123', name: 'Test User' };
it('test 1', () => { user.name = 'Modified'; });
it('test 2', () => { expect(user.name).toBe('Test User'); }); // order-dependent

// WRONG: incomplete object that only satisfies the compiler by accident
const getMockUser = () => ({ id: 'user-123' });

// WRONG: redefining a schema the production module already exports
const UserSchema = z.object({ /* copy of the real one */ });
```

For overrides where only a few fields matter, constrain them:
`Partial<Pick<T, 'field1' | 'field2'>>` — a bare `Pick` keeps every picked field
required.
