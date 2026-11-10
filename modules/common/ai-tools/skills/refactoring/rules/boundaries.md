---
title: Know the Boundaries
impact: HIGH
impactDescription: Stops refactoring from becoming a feature change
tags: refactoring, scope, commits
---

## Know the Boundaries

**Impact: HIGH**

### When not to refactor

- The current structure is not impeding the work at hand.
- The change is speculative generality for requirements that do not exist yet.
- It would change behaviour — that is a feature, not a refactoring.
- It is premature optimization.
- The code is good enough for the current phase.
- The only reason to move code is "so we can unit test it".

**Remember:** refactoring improves structure without changing behaviour.

### New behaviour needs evidence

Do not add behaviour without a failing test or another repository-authorized
acceptance proof that demands it. A behaviour-preserving refactor may change
lines without a new failing test only while proportionate preservation evidence
stays green.

Speculative additions to refuse:

- "Just in case" logic.
- Features not yet needed.
- Abstractions written only for imagined future flexibility.
- New error behaviour with no accepted contract.

```typescript
// WRONG - speculative error handling; no test demands this
if (items.length === 0) {
  throw new Error('Empty cart');
}

// CORRECT - write the test that demands the guard, then add the guard
```

### Existing untested code is not proven dead

Before removing a branch, characterize its observable behaviour, inspect every
caller and reachability path, and resolve the behaviour authority. Delete it only
when the evidence shows it is unreachable or the accepted contract explicitly
retires it, then keep the preservation checks green.

### Commits

Only when the user approves a refactoring commit:

```text
refactor: extract scenario validation logic
refactor: simplify error handling flow
refactor: rename ambiguous parameter names
```

Format: `refactor: <what changed>`. Never mix a refactoring commit with a feature
commit.

### Checklist

- [ ] Existing behaviour tests pass; no test edit hides a behaviour change.
- [ ] Focused and affected tests stayed green during the refactor.
- [ ] The complete non-watch gate passes before review.
- [ ] Accumulated result verified once (mutation evidence or explicit `N/A`).
- [ ] No unplanned consumer-facing API added.
- [ ] Code is more readable than before.
- [ ] Commits were explicitly approved and kept separate from features.
- [ ] A recoverable baseline existed; a baseline commit only if approved.
- [ ] No speculative code added.
- [ ] Behaviour unchanged within the confidence of the passing evidence.
