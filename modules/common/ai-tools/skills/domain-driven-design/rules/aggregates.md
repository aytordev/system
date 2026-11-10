---
title: Aggregates Protect Invariants
impact: CRITICAL
impactDescription: Consistency boundaries, not containment hierarchies
tags: ddd, aggregates, invariants, concurrency
---

## Aggregates Protect Invariants

**Impact: CRITICAL**

### Design from invariants, not relationships

The most common mistake is starting from entity relationships ("Route has
many Locations") and building a hierarchy that mirrors the structure —
organized entities, accessor methods, no genuine business behavior.

**The litmus test for aggregate membership:**

1. What commands change state in this area of the domain?
2. What must remain true immediately after each state change? (These are your
   invariants.)
3. What data is required to enforce those invariants? (Only this belongs in
   the aggregate.)

If the answer to #2 is only structural rules (one-to-many, one-to-one),
database constraints enforce these more simply than aggregate code. Reserve
aggregates for behavioral invariants — rules about what's allowed, limits,
conditions, and business decisions.

**Signs of a relationship-driven aggregate:** methods only add, remove, or
attach children; no method ever returns a failure result; removing the
aggregate and using direct repository access would change nothing about system
correctness.

**Complementary heuristic — lifecycle identity:** aggregates are "born" and
"die" (registration, expiration, cancellation). If you can identify what
creates and destroys a thing, you've likely found the boundary; the birth
event often reveals the root entity, and the data needed for invariants
between birth and death reveals what belongs inside.

```typescript
// ✅ INVARIANT-DRIVEN — VendingMachine is its own aggregate
//    because alarms are the behavioral responsibility
const triggerAlarm = (machine: VendingMachine, alarm: NewAlarm): TriggerAlarmResult => {
  const activeAlarms = machine.alarms.filter(a => a.status === 'active');
  if (activeAlarms.length >= machine.maxConcurrentAlarms) {
    return { success: false, reason: 'max-alarms-reached' };
  }
  return { success: true, machine: { ...machine, alarms: [...machine.alarms, alarm] } };
};
```

### Sizing and root rules

- **Ask:** "Does modifying X require checking Y's state to maintain an
  invariant?" Yes → same aggregate; no → separate aggregates, referenced by
  ID. Start combined, split when you feel the pain.
- **One aggregate root per transaction.** External access only through the
  root; the root enforces all invariants; delete cascades from the root; IDs
  are globally unique for roots.
- **Aggregates serve commands, not queries.** For every piece of data in an
  aggregate, ask "Does any command need this to enforce an invariant?" If it
  only exists to satisfy a read, it belongs in a read model, not the
  aggregate.

**One aggregate write plus an outbox event** when temporary inconsistency is
acceptable; **a process manager** when cross-message state, ordering,
correlation, timeouts, or deduplication are business-significant. Never model
one business operation as sequential saves to two aggregates and call it
eventual consistency: failure of the second save leaves a partial result with
no durable instruction to finish or compensate — redraw the boundary instead.

**Data locality:** all of an aggregate's internals must be co-located in the
same data store, so it can be read, changed, and persisted atomically.

**Cross-aggregate rules are eventually consistent by default.** Immediate
consistency is a scarce resource — spend it only within aggregates where
invariants truly demand it.

### Enforcing boundaries in TypeScript

1. **Accept child IDs, not child objects.** Passing a child entity from
   outside leaks aggregate internals into the caller.
2. **Create child entities through the root**, so the root enforces creation
   invariants (max items, uniqueness, ordering).
3. **Expose `ReadonlyArray` for child collections** — callers can inspect
   children but cannot add, remove, or reorder them without root methods.

Together: callers can see child entities (via `ReadonlyArray`), identify them
(via IDs), and request operations on them (via root methods) — but can never
construct, mutate, or remove them directly.

### Optimistic locking

When multiple users can modify the same aggregate concurrently, add a version
field; the repository checks the version on save and returns `'saved' |
'conflict'`. The application maps the expected compare-and-save outcome to its
explicit `concurrent-change` result; the driving adapter may render it as HTTP
409. Connection loss and other unexpected infrastructure failures still throw.
If retrying is part of the use case, reload, re-run the domain decision, and
retry the save a bounded number of times rather than catching an exception and
blindly repeating it.

Add optimistic locking when multiple users edit the same aggregate, the
aggregate is long-lived, or concurrent modifications would violate invariants.
Skip it when the storage operation already provides an equivalent atomic
compare-and-set, fresh creation has no competing writer, or appended facts are
demonstrably commutative and unconstrained.
