---
title: Justify Every Type Assertion
impact: CRITICAL
impactDescription: Keeps the compiler honest about unchecked assumptions
tags: types, assertions, strict
---

## Justify Every Type Assertion

**Impact: CRITICAL**

`as Type` tells the compiler to stop checking. Sometimes that is unavoidable and
correct; most `as` usage is a bug deferred to runtime. The same applies to the
non-null assertion (`!`), angle-bracket casts, and double casts through
`unknown`.

**Incorrect (casting instead of narrowing):**

```typescript
const user = event.payload as User;
const name = user.profile!.name;
```

**Correct (narrow, or validate at the boundary):**

```typescript
if (!isUser(event.payload)) return;
const user = event.payload;
const name = user.profile?.name ?? 'anonymous';
```

### The two justified assertions

1. **A validating constructor or schema `transform`**, which checks the value
   before the cast and is the only place the brand or shape is conferred:

   ```typescript
   const toUserId = (raw: string): UserId => {
     if (raw.length === 0) throw new Error('UserId cannot be empty');
     return raw as UserId;
   };
   ```

2. **A verified narrowing the compiler cannot express**, such as a lookup table
   proven total by a test. Explain it in a comment next to the assertion.

### Upstream typing defects

When a library's declarations are wrong, prefer a narrow, documented suppression
over a cast that infects call sites:

```typescript
// Upstream types the callback as `any`; tracked in vendor issue 1234.
// @ts-expect-error upstream declaration defect, remove after the fix ships
subscribe(payload, handler);
```

Use `@ts-expect-error`, never `@ts-ignore`: the former fails when the defect is
fixed, so the suppression cannot rot silently. Suppress one line, not a file.

### Tests are not exempt

Apply the repository's type-safety policy to tests. When a test needs an invalid
value, build it through a deliberate test-only helper that returns
`unknown`/a cast in one visible place, rather than weakening `tsconfig.json` or
scattering `as any` through the suite.
