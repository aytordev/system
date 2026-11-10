---
title: Domain Services and Domain Events
impact: HIGH
impactDescription: Cross-aggregate logic and coordination
tags: ddd, domain-services, domain-events, decider
---

## Domain Services and Domain Events

**Impact: HIGH**

### Domain services

When business logic doesn't belong to a single entity, it belongs in a
**domain service** — a stateless function in the domain layer that combines
domain values or read-only policy facts.

| | Domain Service | Use Case |
|--|----------------|----------|
| Contains business logic? | Yes | No — orchestration only |
| Logical role | Domain policy | Application policy — coordinates domain operations and collaborations |
| Depends on | Domain types only by default | Domain services and normally application-owned repository/integration ports |
| Example | `pledgeContribution(occasion, eligibility, pledge)` | `handlePledge(persistence, eligibilityGateway, dto)` — loads, calls domain service, saves one aggregate plus its outbox event |

Name domain operations and use cases after the business operation
(`pledgeContribution`, `placeOrder`), never after technical patterns
(`ContributionService`, `PlaceOrderUseCase`). You can tell a use case from a
domain function by its signature: a use case takes application-owned
collaboration contracts; a domain service takes only domain types.

A domain service does not make multi-aggregate writes atomic: redraw the
aggregate when one invariant requires synchronous change, or coordinate one
aggregate write plus a durable event in the application layer.

Pure domain services are the default. A domain-owned driven port is a rare,
explicit exception only when the model itself — not application orchestration —
owns the conversation; the consuming service is then effectful but still
provider-free: isolate its pure decision logic and test the port interaction
with a fake. Do not use this exception for repositories or gateways needed
only by application orchestration.

### Domain events

Domain events represent something meaningful that happened in the domain,
named in past tense using business language: `OrderPlaced`,
`ContributionPledged`, `BudgetExceeded`.

**They earn their complexity when:** side effects cross aggregate boundaries;
other bounded contexts need to react to changes; you need an audit trail or
event-driven workflows. **Avoid them when:** logic is within a single
aggregate; side effects are within the same transaction; explicit return
values suffice. For most projects, start without domain events and add them
when the domain demands coordination.

**Domain events vs integration events:** domain events stay within a bounded
context (in-process, domain types); integration events cross contexts or
services (message bus, serializable DTOs with a shared schema).

### The Decider pattern (functional approach)

Three pure functions separate business decisions from state changes:

1. **`decide`**: command + current state → an explicit acceptance or rejection
   with events.
2. **`evolve`**: state + event → new state (pure state transformation).
   `OrderState` is a discriminated union of lifecycle phases, so each case
   builds the full target variant. Known events in impossible states surface
   corrupt persisted history rather than becoming silent no-ops.
3. **`initialState`**: the starting state.

```typescript
const decide = (command: OrderCommand, state: OrderState, now: Date): OrderDecision => {
  switch (command.type) {
    case 'place': {
      if (state.status !== 'draft') return { accepted: false, reason: 'order-not-draft' };
      return { accepted: true, events: [{ type: 'OrderPlaced', items: state.items, placedAt: now }] };
    }
    // ...
    default: { const _: never = command; return _; }
  }
};
```

Events returned from `decide` are plain data — test them like any other return
value. No mocks, no event bus setup, no subscriber verification.

### Dispatching events

| Mechanism | Durability / delivery | Use when |
|-----------|------------|------------|
| Explicit returns (no events) | N/A | Side effects within same aggregate |
| In-process dispatch | Best-effort / non-durable | Stateless, non-critical reactions in one service |
| Outbox pattern | At-least-once | Cross-service, must not lose events |
| Full event sourcing | Complete history | Audit trail, temporal queries, replay — its own opted-in architecture decision, never a default escalation |

The outbox saves events alongside the aggregate in one transaction (a
conflict writes neither aggregate nor outbox row), and a background worker
publishes to the broker. At-least-once delivery means consumers must be
idempotent.

### Process managers (long-running workflows)

When a business process spans messages or aggregates over time and must
remember business-significant workflow state, use a process manager — a pure
function (state + event → new state + commands) that owns valid cross-message
phase transitions, applies each event once and only in the phase that can
consume it, acknowledges `duplicate`, and retries or dead-letters
`out-of-order`. Persist the new process state and emitted commands atomically
(normally with an outbox); never acknowledge an event whose prerequisite has
not arrived. Use one when failure at step N requires compensation, the
workflow has business-meaningful intermediate states, or correctness depends
on cross-message ordering, correlation, timeouts, or deduplication; don't use
one when the workflow completes in a single request.
