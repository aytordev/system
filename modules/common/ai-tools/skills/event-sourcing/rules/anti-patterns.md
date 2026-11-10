# Anti-Patterns Catalogue

Each anti-pattern with its fix. Catch these in design review and in code
review; an adopted anti-pattern is a failed hand-off, not a style difference.

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| **Event sourcing everywhere** | Applying it beyond the contexts whose history is part of the domain. Most contexts are CRUD. | One or two bounded contexts; leave the rest CRUD (`references/when-to-use-event-sourcing.md`). |
| **CRUD / state-obsessed events** | `Created`/`Updated`/`Deleted` mirroring table writes capture *that data changed*, not *what happened*. | Model business facts — `MoneyDeposited`, not `BalanceUpdated` (`rules/modelling-events.md`). |
| **Clickbait / thin events** | An event carrying only an id forces subscribers to call back. | Put the fact in the event. |
| **The event store as an integration bus** | Letting other contexts subscribe to your internal events: *"your persistence becomes your public API"* (Libutzki). | Publish separate, versioned external events (`rules/modelling-events.md`). |
| **Giant / unbounded streams** | One ever-growing stream destroys replay cost and versioning windows. | Short streams + closing the books (`references/production-concerns.md`). |
| **No versioning strategy** | v1 events with no plan to read them from v2 code. Events are immutable and permanent. | Tolerant reader + upcasters from day one (`references/event-versioning.md`). |
| **Putting expected command rejection in `evolve`** | Rules for whether a *proposed* command is allowed belong in `decide`. | `evolve` handles every compatible persisted transition, but surfaces an explicit corruption/compatibility error for an impossible known state/event pair instead of silently ignoring history. |
| **Re-deciding in `evolve`** | Command policy in replay. | `evolve` applies valid facts without business rejection. |
| **Editing or deleting events to "fix" bugs** | Destroys replay trust: *"The moment you allow a single edit, everything becomes suspect"* (Young). | Compensating events. |
| **Snapshot as source of truth** | A snapshot you cannot rebuild from events has lost the log's guarantee. | Snapshots are a rebuildable cache. |
| **Chasing exactly-once delivery** | Two Generals / FLP: impossible. | At-least-once + idempotent, deduplicated processing. |
| **Querying the event store for reads** | The log only answers get-by-id. | Purpose-built projections. |
| **Ignoring eventual consistency** | UIs that assume async read models are instant. | Design for lag (`references/projections-and-read-models.md`). |
| **Skipping optimistic concurrency** | Concurrent commands silently violate invariants. | Always append with expected version and reload-re-decide on conflict. |
| **Mutable events** | "Fixing" a bug by editing past events. | The fix is a new compensating event. |
| **Fat events / God streams** | Huge blobs, or one stream for everything. | Both destroy the consistency-boundary and replay-cost model. |
| **Replay firing external side effects** | *"External systems don't know the difference between real processing and replays"* (Fowler). | Side effects live in handlers/process managers that are excluded from replay and are idempotent or deduplicated; never in `evolve` or a projection rebuild. |
| **No PII strategy** | An append-only log collides with erasure rights. | Decide crypto-shredding / forgettable payload / retention before events hold personal data (`references/production-concerns.md`). |
