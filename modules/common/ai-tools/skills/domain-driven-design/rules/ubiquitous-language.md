---
title: The Glossary Is the Naming Authority
impact: CRITICAL
impactDescription: Ubiquitous language enforcement
tags: ddd, glossary, ubiquitous-language
---

## The Glossary Is the Naming Authority

**Impact: CRITICAL**

DDD projects must maintain a repository-declared glossary that defines agreed
domain terms. It is the naming authority for its bounded context. The glossary
evolves as the model evolves — when the team discovers a better name or splits
a concept, decide and record the change before code follows.

### The glossary file

For projects with multiple bounded contexts, organize by context. The same
term may have different definitions in different contexts — this is correct,
not a bug.

```markdown
## Gifting Context

| Term | Definition | Examples |
|------|-----------|----------|
| Occasion | A gift-giving event (birthday, holiday) | "Mum's Birthday", "Christmas 2026" |
| Gift Idea | A potential gift for an occasion | "Cookbook", "Scarf" |
| Contribution | Money pledged toward a gift | "£25 from Dad" |

## Notifications Context

| Term | Definition | Examples |
|------|-----------|----------|
| Occasion | An upcoming event that may trigger reminders | (same events, different concern) |
| Recipient | The person being gifted — target of reminder scheduling | "Mum" |
```

### Enforcement rules

- Use the canonical spelling and capitalization whenever naming a declared
  concept — including when the request, ticket, or user used a rejected alias.
  The request's wording is input to translate, not a naming authority: a
  request that says "reservation" where the glossary declares `Booking` and
  rejects Reservation is `Booking` in the code, `Reservation` never appears as
  a type, field, or function name, and the reply says which words were
  translated.
- Treat an absent term as a candidate requiring agreement, not as
  automatically approved or forbidden.
- Rejected or deprecated aliases must point to the owning bounded context and
  canonical replacement.
- Apply glossary checks to `type` and `interface` names, function names, and
  test descriptions within the check's declared scope.
- Treat a green language-lint command as evidence for its targeted ratchet
  only, never as proof that every prose passage and identifier uses the
  ubiquitous language correctly.

```typescript
// ✅ Uses domain language
type GiftIdea = {
  readonly id: GiftIdeaId;
  readonly description: string;
  readonly occasion: OccasionId;
  readonly estimatedCost: Money;
  readonly status: 'proposed' | 'selected' | 'purchased';
};

// ❌ Technical jargon
type Item = { readonly id: string; readonly text: string; readonly parentId: string; };
```

### Anti-patterns

- **Generic technical names**: `Item`, `Entity`, `Record`, `Data`, `Info`
  instead of domain terms. Always use the glossary.
- **Resisting model evolution**: refusing to rename types, split aggregates,
  or restructure bounded contexts as understanding deepens. If a refactoring
  reveals that "Occasion" should really be "GiftEvent" and "SavingsGoal", do
  it. The glossary changes, the types change, the tests guide the migration.
  Evans calls these "breakthroughs".
