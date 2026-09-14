# SDD Closure Policy (C11) — shared across verify and archive

**Impact: CRITICAL**

This is the single source of truth for **what closing an SDD change means**
(ADR 0015, policy C11). Successful completion and canonical spec promotion
require **current, relevant verification for the candidate revision**. No
administrative path may fake that.

## Successful Closure

A change may complete (archive, or close in an Engram-only backend) only when
**all** of the following hold:

1. **Tasks complete** — every persisted task is checked; prose in an envelope
   never completes an unchecked task.
2. **Verification present and current** — a verify report whose engine envelope
   validates and whose `evidence_revision` equals the current candidate revision.
   Any source change since evidence was collected makes it stale.
3. **Verification relevant** — the evidence names the requirement/scenario or
   work unit it exercised; a hash alone does not prove relevance.
4. **Verdict passes** — the report verdict is `PASS` (or `PASS WITH WARNINGS`
   with no CRITICAL issues). A failed or CRITICAL report blocks closure.

The orchestrator and archive phase obtain (2)–(4) from the pinned engine through
the `aytordev-sdd` adapter:

```
aytordev-sdd closure <change> [--revision <sha256>]
```

The adapter owns the C11 gate. It reports the engine's readiness as
`aytordev-sdd.closure/v1` and exits `0` **only** for `disposition: verified`.
Every other exit is a non-success.

## Non-Success Dispositions

These are **distinct** from success and from each other. None of them may
present as verified, emit `status: success`, or promote canonical specs.

| Disposition | Meaning | Envelope mapping |
|-------------|---------|------------------|
| `unverified` | No valid, current, relevant, passing verification (missing, stale, failed, or CRITICAL). | `final` / `status: blocked` (kind stays terminal). |
| `paused` | Operator deliberately stopped mid-change; state is preserved and resumable. | `final` / `status: partial`. |
| `abandoned` | Operator deliberately abandons the change; canonical specs stay untouched. | `cancelled` (terminal, never advances), or `final` / `status: failed` with the reason named. |

A `paused` or `abandoned` change keeps its recorded backend and artifacts; it is
never deleted and never half-merged. Resuming it re-runs the missing phases; the
closure gate is evaluated again from current evidence.

## Canonical Spec Promotion

Canonical specs (`openspec/specs/{domain}/spec.md`) are the source of truth.
They are updated **only** by a verified closure, and only through the engine's
composer (`aytordev-sdd compose`). A non-success disposition must leave
canonical specs byte-identical to before. When validation fails, the prior
report and artifacts are preserved; nothing is partially promoted.

## Never Fabricate a PASS

- Never write `status: success` for `unverified`, `paused`, or `abandoned`.
- Never promote specs to make a change look complete.
- Never let an intermediate snapshot, prose, or a task checkbox stand in for
  executed evidence. A stale PASS is not a PASS.
- When the gate cannot be evaluated (engine unavailable, backend unreadable),
  report `blocked` with the reason; do not fall back to an optimistic outcome.
