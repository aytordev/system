---
name: bug-diagnosis
description: "Establish why observed behavior fails, with evidence that distinguishes a supported cause from the alternatives. Read-only by default; never owns a fix."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Bug Diagnosis

Establish *why* observed behavior fails, with evidence that distinguishes the
supported cause from the alternatives. This is a bounded method, not a
lifecycle: it never owns a fix.

## Entry Conditions

Use this skill when:

- The request is to explain a failure: broken, failing, throwing, flaky, or
  incorrect behavior.
- A supported cause is needed before a change is worth making.
- The caller — a user or an SDD phase such as `sdd-explore` or `sdd-apply` —
  wants diagnosis without granting write authority.

Do not enter when:

- The question is about performance (latency, CPU, throughput, I/O,
  contention); that needs a measurement method, not this one.
- The caller asked only for a fix and no diagnosis is required. The fix belongs
  to the caller's lifecycle.
- The behavior is already understood and only review is requested.

## Read-Only Boundary

- Diagnosis-only work makes no persistent source change: no edits, no new
  tracked files, no history rewrites, no external state changes.
- Redact secrets from commands, output, logs, traces, and fixtures.
- Run throwaway harnesses only in an isolated temporary directory and remove
  your own scratch before handoff.
- If temporary instrumentation is authorized, tag it with one unique
  `[DEBUG-<id>]` marker and remove it before handoff.

## Diagnosis Contract

1. State the exact symptom: the observable, reproducible wrong result, not a
   guessed cause.
2. Build one fast feedback command that detects that exact symptom and record
   its red result. If no red-capable loop exists, report each attempted route
   and ask for the smallest missing access or artifact instead of speculating.
3. Minimize the reproduction one element at a time until every remaining
   element is load-bearing.
4. Rank three to five falsifiable hypotheses, each with one observable
   prediction that separates it from the others.
5. Run one-variable probes against those predictions; prefer a debugger or REPL
   over broad logging.
6. Report the supported cause, the rejected hypotheses, the evidence for each,
   and the residual uncertainty.

See [references/diagnosis-loop.md](references/diagnosis-loop.md) for the loop
and the reporting shape.

## Return to Caller

- After a diagnosis-only request, stop at the evidence report and do not begin
  a fix.
- When invoked from SDD or another lifecycle, return the exact symptom, the
  minimized reproduction, the supported cause, rejected hypotheses, evidence,
  and residual uncertainty to the caller. The caller owns implementation,
  regression tests, review, and handoff.
- When the caller is an SDD phase, shape the handoff with the shared
  [return envelope](../_shared/return-envelope.md) fields; load that protocol
  before returning.
- Never take over the lifecycle: this method does not implement, refactor,
  commit, or approve.

## Provenance

Behavior-level adaptation of khanelinix `diagnosing-bugs` at commit
`8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd`. That upstream declares an MIT
license (frontmatter `license` plus a bundled `LICENSE`, Copyright (c) 2026
Matt Pocock). This package is independently authored: no upstream text is
copied or closely paraphrased, so no upstream notice is reproduced.
