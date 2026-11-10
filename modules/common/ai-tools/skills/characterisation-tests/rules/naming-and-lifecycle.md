---
title: Make Characterisation Tests Recognisable
impact: HIGH
impactDescription: Prevents temporary scaffolding from becoming permanent authority
tags: characterisation, naming, lifecycle
---

## Make Characterisation Tests Recognisable

**Impact: HIGH**

A reader — human or agent — must see at a glance that these tests document actual
behaviour, do not assert correctness, and are temporary.

### Test names

```typescript
// Clear: characterisation
describe('calculateBonus characterisation', () => {
  it('characterises premium-member bonus for under 5 years', () => {});
});

// Ambiguous: reads like a behaviour-driven test
describe('calculateBonus', () => {
  it('should apply a premium-member bonus', () => {});
});
```

### File names

```text
scoring.characterisation.test.ts    <- temporary, may mirror one file 1:1
member-bonus.test.ts                <- permanent, follows behaviour
```

The temporary file may mirror the implementation file one-to-one, because it is
pinning that file's current behaviour and will be deleted. Permanent tests follow
behaviour, not file boundaries.

### Header comment

Each characterisation file opens with why it exists and when it goes:

```typescript
/**
 * CHARACTERISATION TESTS -- documenting actual behaviour, NOT asserting correctness.
 *
 * These tests pin the current behaviour of calculateBonus so it can be
 * refactored safely. Replace them with behaviour-driven tests as the code is
 * understood and restructured.
 */
```

This is one of the few places where a comment is essential: the tests document
*what* the code does, the header documents *why the tests exist and when to
remove them*.

### Suspicious behaviour

```typescript
it('characterises negative activity -- SUSPICIOUS: returns a negative bonus', () => {
  // May be a bug: negative activity produces a negative bonus.
  // Documented as-is; escalate before changing.
  expect(calculateBonus(-5, 'premium', 3)).toBe(-0.75);
});
```

The marker is the mechanism that keeps a bug from being silently enshrined as
correct.

### Retirement

1. **Characterise** — pin current behaviour as a safety net.
2. **Refactor** — restructure while the characterisation tests detect change.
3. **Replace** — write tests that assert *intended* behaviour.
4. **Remove** — delete the characterisation file once that behaviour is covered.
