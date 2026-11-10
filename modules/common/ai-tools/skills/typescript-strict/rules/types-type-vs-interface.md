---
title: Choose Type or Interface by Semantics
impact: CRITICAL
impactDescription: Prevents arbitrary declaration-form churn
tags: types, declarations
---

## Choose Type or Interface by Semantics

**Impact: CRITICAL**

A repository convention wins. Without one, choose the form that expresses what
the declaration is for, not the one that happens to be shorter.

### `type` — unions, tuples, mapped types, closed aliases

```typescript
export type User = {
  readonly id: string;
  readonly email: string;
  readonly name: string;
  readonly roles: ReadonlyArray<string>;
};

export type OrderState = 'draft' | 'placed' | 'shipped';
export type Coordinate = readonly [latitude: number, longitude: number];
export type Flags<T> = { readonly [K in keyof T]: boolean };
```

Type aliases can name unions, intersections, tuples, primitives, mapped types,
and object shapes. They cannot be reopened through declaration merging, which is
exactly what makes them suitable for a set that must stay closed.

### `interface` — extendable object contracts

```typescript
export interface UserRepository {
  findById(id: string): Promise<User | undefined>;
  save(user: User): Promise<void>;
}

export class PostgresUserRepository implements UserRepository {
  // ...
}
```

Interfaces describe object shapes, work with `implements`, extend with conflict
checking, and support declaration merging. They suit behavior contracts and
deliberately open extension points. They are not forbidden for data shapes.

### Decision table

| Question | Answer |
| --- | --- |
| Is it a union, tuple, mapped type, or primitive alias? | `type` |
| Must it stay closed? | `type` |
| Is it a behavior contract consumers may implement? | `interface` |
| Does a library need declaration merging to augment it? | `interface` |
| Is it a plain data shape and the repository has no convention? | Either; keep it consistent within the module |

### Do not mix both for one shape

Declaring `interface User` and `type User` variants in the same codebase is how
two owners of one contract appear. Pick one and derive everything else from it.
