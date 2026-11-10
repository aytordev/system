---
title: Validate at Trust Boundaries Only
impact: HIGH
impactDescription: Adds runtime safety where data is untrusted, without schema sprawl
tags: schemas, validation, boundaries
---

## Validate at Trust Boundaries Only

**Impact: HIGH**

A runtime schema is required when untrusted data crosses a boundary and the
program must validate its shape or constraints before using it. Internal
invariants do not require a schema by default.

### Signals that a schema is required

- HTTP requests and responses, queue messages, file and environment parsing,
  third-party API responses entering the process.
- A data contract exchanged between independently deployed systems.
- Contract-shaped test fixtures where reusing an existing production schema adds
  useful evidence.

```typescript
const UserSchema = z.object({
  id: z.uuid(),
  email: z.email(),
});
type User = z.infer<typeof UserSchema>;

const user = UserSchema.parse(apiResponse);
```

### When a schema is noise

- Pure internal types (utilities, state machines, reducers).
- Result and option types, which carry no validation.
- TypeScript utility types (`Partial<T>`, `Pick<T>`, `Record<K, V>`).
- Behavior contracts (interfaces) — structural, never validated.
- Component props, unless they arrive from a URL or an API.

```typescript
type Result<T, E> =
  | { readonly success: true; readonly data: T }
  | { readonly success: false; readonly error: E };

interface UserService {
  createUser(user: User): void;
}
```

An invariant created and consumed inside one trusted process is owned better by
a smart constructor, a branded type, or a domain value object.

### Validate, then pass plain derived types

Parse at the boundary, hand internal functions the derived type, and keep the
schema out of internal signatures. A second parse deep inside the call stack
means either the boundary is missing or the type is not being trusted.

### Library choice

Prefer libraries implementing
[Standard Schema](https://standardschema.dev) (Zod 4+, Valibot, ArkType) so
validation tooling stays interchangeable. Follow the repository's existing
choice; introducing a second schema library for one endpoint is drift.

### Where the schema lives

One schema per owned contract, version, and bounded context — see
`types-single-owner`. Export the schema and its derived type from the same
module so nobody is tempted to restate the shape.
