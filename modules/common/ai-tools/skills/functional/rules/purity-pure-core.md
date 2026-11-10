---
title: Keep the Core Pure and the Edges Thin
impact: HIGH
impactDescription: Makes logic testable without mocks and effects auditable
tags: purity, effects, boundaries
---

## Keep the Core Pure and the Edges Thin

**Impact: HIGH**

A pure function has no side effects and always returns the same output for the
same input:

1. **No side effects** — does not mutate external state, modify arguments, or
   perform I/O.
2. **Deterministic** — no dependency on `Date.now()`, `Math.random()`, or
   ambient configuration.
3. **Referentially transparent** — the call can be replaced by its return value.

Pure functions are testable without setup, composable, predictable, and
cacheable.

### Isolate what must be impure

```typescript
// Pure core
function calculateTotalWeightGrams(parcels: ReadonlyArray<Parcel>): number {
  return parcels.reduce((sum, parcel) => sum + parcel.weightGrams, 0);
}

// Impure shell, at the edge that owns the effect
async function saveShipment(shipment: Shipment): Promise<void> {
  const totalWeightGrams = calculateTotalWeightGrams(shipment.parcels);
  await database.save({ ...shipment, totalWeightGrams });
}
```

**Pattern:** keep concrete I/O at the project's chosen boundaries. Application
orchestration may compose effectful capabilities; core domain decisions stay
pure. Follow the existing architecture rather than introducing ports and
adapters solely to isolate effects.

### Make impurity explicit in the signature

- Pass the clock, the random source, or the id generator as a parameter, or read
  it once at the edge and pass the value down.
- Return what changed instead of writing into a caller-owned parameter.
- Never hide a write, a network call, or a cache mutation behind a name that
  reads like a query.

### Self-documenting code first

Name things for the domain, extract functions instead of narrating steps, and
keep comments only where they carry information the code cannot:

- JSDoc for public APIs that generate documentation.
- Constraints the code cannot express: an upstream bug workaround, an ordering
  required by an external system, a why-this-and-not-that decision.

**Incorrect (comment narrates unclear code):**

```typescript
// get user and check active and permission
function check(u: any) {
  if (u) {
    if (u.a) {
      if (u.p) return true;
    }
  }
  return false;
}
```

**Correct (the code states the rule):**

```typescript
function canUserAccessResource(user: User | undefined): boolean {
  return user !== undefined && user.isActive && user.hasPermission;
}
```

Check `undefined` explicitly in the boolean form: optional chaining
(`user?.isActive && ...`) yields `boolean | undefined` and does not compile under
strict mode.
