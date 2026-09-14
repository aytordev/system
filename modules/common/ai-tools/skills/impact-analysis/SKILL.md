---
name: impact-analysis
description: "Find what a change could break beyond the diff, then prove the material compatibility assumption with a focused check that runs real code. Review-only; returns findings to the caller."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Impact Analysis

Find what a change breaks somewhere else — beyond the diff — and prove the one
fact its safety depends on with a real, focused check. Listing callers is not
the job; proving the breakage or the safety is.

## Entry Conditions

Use this skill when:

- The request is "what could this break", "blast radius", or reviewing a small
  diff whose safety is not obvious.
- A change crosses a component, option, wire, or data contract and the caller
  wants compatibility evidence before shipping.
- An SDD phase such as `sdd-design`, `sdd-apply`, or `sdd-verify` must prove a
  material compatibility assumption across consumers.

Do not enter when:

- The request is a general adversarial review; use `judgment-day`.
- The request is to implement or correct code; that belongs to the caller.
- The change is fully contained and an existing check already proves it.

## Authority and Probes

- Review-only work returns findings; do not edit source, persistent tests, or
  external state without explicit authority.
- Reuse an existing safe check when it proves the fact.
- Put throwaway probes in an isolated scratch directory and remove only your
  own scratch.
- If safe isolation is unavailable, report the evidence limit instead of
  running a mutation-capable probe.
- The caller retains lifecycle and write authority; this method expands neither.

## Impact Contract

1. Read the change: the diff, the symbols it adds, changes, and deletes, and
   the behavior difference the diff does not spell out.
2. Find the one material fact the change is safe because of. Spend effort there
   instead of listing maybes.
3. Follow consumers the diff misses: library source and its pinned version,
   wire formats, persisted data, feature flags, and code several hops
   downstream. Cite a real `file:line`; treat a search that finds nothing as a
   result.
4. Rate each surviving risk by likelihood and cost, and list checked-and-cleared
   items separately.
5. Prove the material assumption with an existing safe check or an isolated
   probe that runs the real code and fails loudly if the assumption is wrong.
   State where on the evidence ladder the proof stopped, and say `unproven`
   rather than rounding up.
6. Return the scope, findings, proof, and remaining limits.

See [references/consumer-tracing.md](references/consumer-tracing.md) for the
evidence ladder and the handback shape.

## Return to Caller

- Return findings and isolated probe evidence; do not fix, refactor, or commit.
- When invoked from SDD or another lifecycle, hand the findings back and let the
  caller decide. The caller owns implementation, correction, review, and
  handoff.
- When the caller is an SDD phase, shape the handoff with the shared
  [return envelope](../_shared/return-envelope.md) fields; load that protocol
  before returning.
- For independent review the caller may use `judgment-day`. Keep review
  separate from correction, and never take over the lifecycle.

## Provenance

Behavior-level adaptation of khanelinix `blast-radius` at commit
`8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd`. That upstream declares an MIT
license (frontmatter `license` plus a bundled `LICENSE`, Copyright (c) 2026
Lauren Tan). This package is independently authored: no upstream text is
copied or closely paraphrased, so no upstream notice is reproduced.
