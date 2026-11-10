---
title: Type Untrusted Input as Unknown
impact: CRITICAL
impactDescription: Prevents unvalidated data from entering internal logic
tags: types, boundaries, strict
---

## Type Untrusted Input as Unknown

**Impact: CRITICAL**

Anything that crosses a process boundary starts as `unknown`, never as a shape
the program hopes for. `unknown` forces narrowing before use; annotating the
payload with an interface only tells the compiler a story.

**Incorrect (the annotation is a promise, not a check):**

```typescript
export async function postUser(request: Request): Promise<User> {
  const body = (await request.json()) as User;
  return createUser(body);
}
```

**Correct (narrow before use):**

```typescript
export async function postUser(request: Request): Promise<User> {
  const body: unknown = await request.json();
  const parsed = CreateUserRequestSchema.parse(body);
  return createUser(parsed);
}
```

### Contained `any`

An external declaration with no usable types, or a shim for an untyped
dependency, may need `any`. Keep it narrow, keep it at the edge, and say why:

```typescript
// The vendor SDK ships no declarations; this is the only untyped surface.
// biome-ignore lint/suspicious/noExplicitAny: untyped vendor SDK boundary
type VendorClient = any;
```

Rules for the exception:

- Never let `any` reach a domain type or a function's public signature.
- Never widen to `any` to silence an error that a union, a guard, or a real type
  could express.
- If the value is unused, prefer the project's ignore mechanism over `any`.

### Implicit leaks

`JSON.parse`, `Object.fromEntries`, index access on a record, `catch (error)`,
and `structuredClone` all return values whose type is a promise too. Apply the
same rule: `unknown` plus validation.

### Why not trust internal code

The boundary rule is not about distrusting colleagues. It is about the single
place where the program's assumptions become checkable. Once a value is
validated, internal functions should trust their inputs and stay readable.
