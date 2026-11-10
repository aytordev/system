---
title: Choose the Runtime and Diagnose Runs
impact: HIGH
impactDescription: Runtime preference order and the decisions a workflow script encodes
tags: graph-engineering, execution, runtimes
---

## Choose the Runtime and Diagnose Runs

**Impact: HIGH**

Three runtimes, in order of preference. Detect what the session offers and say
which one you're using. All three use the capability tiers in
`rules/capability-tiers.md`; a runtime that cannot apply an option records that
limitation.

### Runtime 1: a native multi-agent workflow mechanism

Prefer the host's native graph executor whenever available — it gives
deterministic control flow, schema-enforced agent outputs with automatic
retries on mismatch, phase-grouped progress, resumability, and budget
awareness. The decisions a correct workflow script encodes:

- A pure-literal metadata block; phase titles there must match the phase calls
  exactly.
- Plain deterministic code: no nondeterministic time or random values, which
  would break resume; stamp timestamps after the run returns or pass them
  through run arguments as real JSON values, never a stringified blob.
- A failing node thunk resolves to null — always filter failed nodes out and
  report the failure count. On surprises, read the run's journal before
  diagnosing.
- Default pipelines over parallel barriers; the dedup barrier is one of the few
  justified ones.
- Respect the session's workflow size guideline; scale rosters per
  `rules/topologies.md`, and use the budget mechanism when the user set a token
  target.
- Iterate by editing the persisted script and resuming from the run; unchanged
  agent calls replay from cache.
- A workflow mechanism that was invoked because the user invoked a skill
  implying it counts as opt-in; a task merely *benefiting* from a graph does
  not.

What the runtime does not enforce — the orchestrator owns these or nobody does:

- **Integration.** An agent returning is not a `needs` edge releasing. Only
  verified-and-integrated-into-the-base releases a dependency; an approval, a
  green check, or an open PR does not.
- **Exclusion.** Two agents launched in parallel will happily write the same
  path. Serialize writers deliberately — a serial loop with a progress line so
  it doesn't read as a stall — unless all four concurrency conditions in
  `rules/topologies.md` hold.
- **Approval.** A running script cannot pause for the user. Get approval before
  dispatch, and split long write graphs at checkpoints: **one workflow per
  checkpoint, not one per run.** Integrate, re-plan, and re-render inline
  between runs, so a bad cut costs one checkpoint rather than the whole graph.
  Expect the first pass at a checkpoint to fail — follow-up nodes are the
  normal output of verification, not a surprise.

For long runs, check usage headroom before each checkpoint. When near a limit:
drain running nodes rather than killing them mid-write (accept partial
handoffs), persist the ledger, and resume later — re-deriving state from the
repository, never from memory.

### Runtime 2: parallel sub-agent launches

No native workflow mechanism, but an agent mechanism exists: launch all
independent nodes **in a single message** so they run concurrently, each with a
complete brief (skill preamble + scope + schema stated in prose). Pass the
resolved tier's model, effort, and budget when the tool supports them. Collect
a requested/applied/usage ledger entry for every node; if the tool cannot
override a field, use the fresh non-top-tier fallback from
`rules/capability-tiers.md` and surface `uncontrolled-default`.

Differences you must compensate for by hand:

- **No schema enforcement.** State the contract in the brief and instruct:
  "your final message must be only this JSON". Treat malformed output as a node
  failure to report — retry once, don't silently repair.
- **No phases or resume.** Track roster → findings → verdicts yourself; if the
  session dies, the run is gone.
- **Don't poll.** Background nodes notify on completion; never fabricate a
  pending node's result.

### Runtime 3: sequential degraded mode

No sub-agent mechanism at all: run the graph as a **sequence in your own
context** — load one skill, work the scope through that lens, write the lens's
findings to a scratch file, then load the next. After all lenses, do a
self-verification pass per finding (weakest link: same context that found it),
then synthesize.

This loses parallelism and context isolation. Label the output accordingly
("sequential single-context run — lenses share one context; verification is not
independent") so nobody mistakes it for a true graph run.

### Diagnosing runs

- A node returning nothing ≠ a clean scope. Distinguish node failure (report
  it) from a genuine empty result (`clean` says what was inspected).
- With a journalled runtime, read the journal of actual node returns before
  assuming.
- If most of a roster fails the same way, the brief is broken (bad path, wrong
  skill name, oversized scope) — fix the brief and rerun the failed nodes, not
  the whole graph.
