---
title: Test by Domain Concept
impact: HIGH
impactDescription: Behavior-named tests at the broadest stable boundary
tags: ddd, testing, fakes
---

## Test by Domain Concept

**Impact: HIGH**

### Title tests with business behaviour, not implementation files

Title `describe` and `it` blocks with the business behaviour in glossary
terms, never with the name of the function under test:

```typescript
// ❌ Titled after helpers — proves nothing a domain expert would recognise
describe('addDays', () => { it('rolls over a month boundary', ...) });

// ✅ Titled after the rule
describe('Pledging to an Occasion', () => { it('is refused once funding is closed', ...) });
describe('Committed total for an Occasion', () => { it('excludes gift ideas that are only proposed', ...) });
```

A date or arithmetic helper gets no `describe` of its own; it is proved
through the rule that uses it. One test file per implementation file is the
smell that produces helper-named tests — group tests by the concept they
exercise instead.

```text
<selected-context-or-feature>/
  occasions/
    create-occasion.test.ts       # Behavior: creating occasions
    add-gift-idea.test.ts         # Behavior: managing gift ideas
    occasion-budget.test.ts       # Behavior: budget constraints
```

### Choose the primary behavioral boundary

Use the broadest stable public behavior the selected architecture actually
exposes — do not manufacture a use case or port solely to satisfy a test
template:

| Project shape | Primary boundary |
|---------------|------------------|
| Domain-only model or library | Aggregate operation, domain service, or Decider |
| Application with use cases | Use case/application service with collaboration substitutes |
| DDD plus hexagonal architecture | Driving port with outside test interactors replacing driven actors |
| Event-sourced domain | Decider and projection public APIs using given/when/then behavior |

When a real use case coordinates repositories or integrations, test it with
in-memory fakes or focused stubs so domain entities, services, value objects,
and orchestration run together. One such test exercises orchestration, the
business rule, the entity invariant, and the repository contract
(nothing saved on failure) at once.

```typescript
describe('pledge contribution', () => {
  it('rejects a pledge from an ineligible contributor', async () => {
    const persistence = createFakePledgePersistence([testOccasion]);
    const eligibilityGateway = createFakeContributorEligibilityGateway([
      getTestContributorEligibility({ contributorId: testContributor.id, mayPledge: false }),
    ]);

    const result = await handlePledge(persistence, eligibilityGateway, {
      pledgeId: createPledgeId('pledge-1'),
      occasionId: testOccasion.id,
      contributorId: testContributor.id,
      amount: createMoney(5_000, 'GBP'),
    });

    expect(result).toEqual({ success: false, reason: 'contributor-ineligible' });
    expect(persistence.savedEntities).toHaveLength(0);
    expect(persistence.outboxEvents).toHaveLength(0);
  });
});
```

Pure domain functions CAN be tested directly — they are the public API of the
domain. This is legitimate behavioral testing when the test describes a
business rule. Focused tests for complex pure business rules complement
application tests when both exist; they may be the complete primary suite for
a provider-free domain package.

### Fakes over interaction mocks

Prefer **in-memory fakes** that maintain state over mocks that verify call
sequences:

| Double | Purpose | Use for |
|--------|---------|---------|
| **Fake** | In-memory implementation with real logic | Repositories — stores/retrieves data in a Map |
| **Stub** | Returns configured responses | Payment gateways — success/failure scenarios |
| **Spy** | Records what happened for inspection | Email services — collect sent messages |
| **Mock** | Avoid | Creates brittle tests coupled to implementation |

```typescript
// ✅ Fake — maintains state, implements the real interface
const createFakeRepo = (initial: readonly User[] = []): UserRepository => {
  const store = new Map(initial.map(u => [u.id, u]));
  return {
    findById: async (id) => store.get(id),
    save: async (user) => { store.set(user.id, user); },
  };
};

// ❌ Mock — verifies calls, not behavior
vi.mock('../repositories/user-repository');
```

Fakes implement the real interface: if the interface changes, the fake breaks
at compile time. Fakes test behavior ("was the data saved correctly?"); mocks
test implementation ("was `.save()` called with these arguments?"). Fakes use
mutable internal state — a deliberate testing-only exception; fakes are test
infrastructure, not domain code.

### Test factories use domain language

```typescript
const getTestOccasion = (overrides?: Partial<Occasion>): Occasion =>
  OccasionSchema.parse({
    id: createOccasionId('occasion-1'),
    name: "Mum's Birthday",
    giftIdeas: [],
    budget: createMoney(10_000, 'GBP'),
    totalPledged: createMoney(0, 'GBP'),
    isFundingClosed: false,
    ...overrides,
  });
```
