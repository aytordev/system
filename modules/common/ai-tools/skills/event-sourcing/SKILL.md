---
name: event-sourcing
description: "Trigger: implementing a Decider write model, an event store, projections and read models, event versioning, or snapshots — persisting state as an append-only log of past-tense events and rebuilding it by folding them. Assumes the project or bounded context has deliberately opted in to event sourcing; climb no higher than the complexity ladder requires, and do NOT reach for it on CRUD, or when an audit log or the outbox pattern already suffices."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Event Sourcing

Event sourcing stores every change to application state as an immutable,
append-only sequence of **past-tense domain events**. The current state is
never stored directly — it is a **left fold** of the events:
`state = events.reduce(evolve, initialState)`. The event log is the source of
truth; every other representation (aggregate state, read models, search
indexes) is a derived, disposable projection you can rebuild by replaying
events.

This skill applies only to projects — or the specific bounded contexts within
them — that have deliberately opted in to event sourcing. **It is the top of
the complexity ladder, not a default.** Read `references/when-to-use-event-sourcing.md`
first; most features should stop at explicit returns, an audit table, or the
outbox pattern.

The pure write model this skill persists is the **Decider**
(`decide`/`evolve`/`initialState`): a pure function set with no
infrastructure imports. Where a domain-driven-design skill is installed it
introduces that pattern; treat it as optional — the rules here restate what
event sourcing needs of it.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Implementing or reviewing a Decider write model, an event store port,
  projections/read models, event versioning, or snapshots.
- A bounded context's **history is part of the domain** — audit trail as a
  first-class requirement, temporal queries, genuinely event-driven language,
  or multiple independently-evolving read models over the same facts.

Do not use it for CRUD domains, plain audit logs (append a history table), or
cross-aggregate side effects (use the outbox pattern — that is event-*driven*,
not event-*sourced*).

## Hard Rules

1. **Events are the source of truth.** Immutable, append-only, past tense,
   business-named. Never `UPDATE` or `DELETE` an event; correct with a
   compensating event, like an accountant's reversing entry.
2. **State is a left fold of events.** No stored current state; rehydration is
   `events.reduce(evolve, initialState)`.
3. **The stream is the consistency boundary.** One aggregate instance maps to
   one stream; invariants are enforced within it; appends use **optimistic
   concurrency** (`expectedVersion`) — never a cross-stream transaction.
   Never skip the expected version: without it, two concurrent withdrawals can
   both pass the balance check and overdraw the account.
4. **`decide` holds all the business rules; `evolve` holds none.** `decide` is
   pure, validates the command, and returns accept-with-events or
   reject-with-reason. `evolve` exhaustively applies every valid stored event;
   a known event in an impossible state is corrupt history and must surface a
   corruption error, not a silent no-op. Never re-decide in `evolve`.
5. **`decide` is deterministic.** No `Date.now()`, random, or I/O — time and
   identifiers enter through the command, so replay is reproducible and tests
   are deterministic.
6. **The event store is a driven port.** The domain has zero infrastructure
   imports; the adapter implements append-only writes, per-stream ordering,
   and optimistic concurrency. Stored events are untrusted data: validate them
   with a schema on read (**tolerant reader**) before `evolve` sees them.
7. **A versioning strategy exists before the first event ships.** All schema
   change happens at read time; a new version must be derivable from the old,
   or it is a new event.
8. **Read models are disposable projections.** Idempotent (at-least-once
   delivery is a given), checkpointed, rebuildable from event zero, with the
   UI designed for eventual consistency.

## Execution Steps

1. **DECIDE TO ADOPT** — apply the decision framework in
   `references/when-to-use-event-sourcing.md`; rule out cheaper rungs first
   (explicit returns → in-process events → outbox → event sourcing), scoped
   to the one bounded context that earns it.
2. **MODEL EVENTS** — past-tense business names, self-contained facts,
   discriminated unions, envelope with correlation/causation ids
   (`rules/modelling-events.md`).
3. **WRITE THE DECIDER** — `Decision` result type, exhaustive `never`-guarded
   switches, corruption on impossible transitions
   (`rules/decider-and-rehydration.md`).
4. **DEFINE THE STORE PORT** — typed to the aggregate's event family; adapter
   with atomic compare-and-swap (`references/event-store.md`).
5. **PROJECT READ MODELS** — folds over envelopes, checkpoints, idempotency,
   read-your-writes mitigations (`references/projections-and-read-models.md`).
6. **VERSION DELIBERATELY** — tolerant reader + upcasters from day one
   (`references/event-versioning.md`).
7. **TEST THROUGH THE PUBLIC API** — events in, events out; no mocks for the
   pure core, an in-memory store fake for the handler
   (`references/testing-event-sourced-systems.md`).
8. **COVER PRODUCTION CONCERNS** — snapshots, short streams, sagas, GDPR
   crypto-shredding, operability (`references/production-concerns.md`).

## Output Contract

Report the adopted scope (which bounded context, which rung of the ladder and
why), the transaction invariants (stream-per-aggregate, expected version,
validation order: validate → upcast → evolve), the versioning strategy in
place before the first event ships, and the test evidence for decider,
projection idempotency, and conflict paths. Name what was deliberately left on
a cheaper rung. An anti-pattern adopted silently (CRUD events, no versioning
plan, snapshot as source of truth) is a failed hand-off.

## References

- `rules/modelling-events.md` — discovering and naming events, granularity, internal/external split.
- `rules/decider-and-rehydration.md` — the Decision type, purity, command handler loop, composition.
- `rules/anti-patterns.md` — the full catalogue with fixes.
- `references/when-to-use-event-sourcing.md` — decision framework, complexity ladder, what event sourcing is not.
- `references/event-store.md` — port, Postgres schema, envelope, serialization, tooling landscape.
- `references/projections-and-read-models.md` — folds, lifecycles, checkpoints, eventual consistency.
- `references/event-versioning.md` — tolerant readers, upcasting, copy-transform.
- `references/testing-event-sourced-systems.md` — testing deciders, projections, upcasters.
- `references/production-concerns.md` — snapshots, GDPR, delivery guarantees, operability.
- `references/source-notes.md` — primary sources and rationale.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. Where a domain-driven-design, hexagonal-
architecture, typescript-strict, functional, testing, or mutation-testing
skill is not installed, apply the rule directly: keep the write model a pure
Decider, keep the store a driven port with the domain free of infrastructure
imports, validate schema-first at the trust boundary, keep time and ids
explicit, test through the public API with factories, and avoid identity
values when judging mutation evidence.
