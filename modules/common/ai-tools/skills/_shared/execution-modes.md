# Execution Mode Contract (shared across SDD commands and the orchestrator)

**Impact: CRITICAL**

This is the single source of truth for interactive/automatic pauses and for what
the orchestrator may do inline. It replaces every "always ask" or
"never do phase work inline" rule that contradicted the chosen execution mode.

## Two Execution Modes

Resolved once per session by the orchestrator on the first change command
(`/sdd-new`, `/sdd-ff`, `/sdd-continue`), then cached and passed to every phase.

- **`interactive`** (default): after each phase, present a concise summary and wait
  for the user to approve, stop, or give feedback before launching the next phase.
- **`automatic`**: run the planned phases back-to-back without the routine
  between-phase approval prompt; present a combined result at the end (or at the
  next mandatory pause below).

`automatic` suppresses **only** the routine "continue?" prompt. It never means
"ask nothing".

## Pauses That Both Modes MUST Honor

These are unresolved decisions, blockers, or safety gates — not phase approvals:

1. **Backend unresolved** — ask before choosing a backend or creating artifacts
   (see `persistence-contract.md`).
2. **Delivery/review workload guard** — when `sdd-tasks` forecasts >400 changed
   lines or sets `Decision needed before apply: Yes`, apply the cached
   `delivery_strategy`; `ask-on-risk` asks the user. Automatic mode does not
   override reviewer-burnout protection.
3. **Blocker or non-terminal result** — stop and report; never advance on an
   empty, malformed, interrupted, `cancelled`, nonterminal (`launch-ack`/
   `progress`), stale-evidence, or non-`success` `sdd-result/v1` result (see
   `return-envelope.md`).
4. **User stop or feedback** — honor it in either mode.

In `interactive`, `apply` additionally pauses between task batches so the user can
review progress. In `automatic`, batches still run sequentially but without the
approval prompt unless a pause above fires.

## Coordinator Inline Authority

The orchestrator's delegate-only rule applies to **phase work**, not bookkeeping.
The orchestrator MAY do inline:

- DAG/session state tracking and the session caches (backend, execution mode,
  delivery strategy, TDD resolution).
- Short reads to decide or verify (1–3 files).
- Atomic, mechanical writes it already knows how to make (e.g. session state).
- Shell for state inspection (`git`, `gh`).
- Engine readiness through the adapter (`aytordev-sdd status ...`).

The orchestrator MUST delegate: exploration, proposal, spec, design, tasks, apply,
verify, and archive — plus any multi-file write, test/build execution, or analysis
that inflates context. When in doubt, delegate.

## Authority Boundaries Are Unchanged

Execution mode and inline bookkeeping do not grant new authority. The orchestrator
still never commits, pushes, switches generations, or approves its own phase work,
and never overrides the user's requests, review practices, or explicit workflow
choice.
