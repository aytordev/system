---
title: Verify Findings and Assemble the Report
impact: CRITICAL
impactDescription: Adversarial verification keeps the report trustworthy
tags: panel-review, verification, report
---

## Verify Findings and Assemble the Report

**Impact: CRITICAL**

### Findings shape

Every lens returns the same structured shape so dedup and synthesis are
mechanical: lens name; findings each with an id, title, severity
(`critical`/`major`/`minor`/`nit`, nits capped at 3), file, line, evidence,
why it matters, suggestion, confidence, and a pre-existing flag; plus `clean`
(areas inspected and sound) and `not_assessable` (what the lens could not
judge from this diff). When the host cannot enforce a schema, require the
final message to be only the JSON object, retry a malformed node once, then
report it under lens failures.

### Dedup and verification

Dedup by file, line, and claim; multi-lens agreement on one finding is signal
— note it in the report. Verify every surviving finding with an independent
agent mandated to REFUTE it against the actual code:

- Does it reproduce at that `file:line`?
- Is it genuinely this lens's rule, not taste?
- Is it introduced by this diff rather than pre-existing?

Verdicts are `confirmed`, `refuted`, or `unverifiable` — default to `refuted`
when the evidence does not hold up and `unverifiable` when it cannot be
checked either way; never guess. For contested or high-stakes findings, use
multiple verifier votes and resolve by majority, with a tie counting as
`unverifiable`. Sequential degraded mode — one agent at a time — is a labelled
last resort, named as degraded in the report.

### Cost and scale

Lens nodes dominate cost and scale with roster size; keep the default roster
at 3–6 lenses. With a huge diff, send each lens only its relevant hunks plus
the file list — and say so in the brief so `not_assessable` stays honest. If a
token budget is set, size the roster and verifier votes within the remaining
budget rather than failing mid-run.

### Report assembly

The orchestrator (not a node) assembles:

```markdown
## Review: <target> — <one-line claim>

**Roster:** <lenses run> · **Scale:** <N nodes, M findings verified> ·
**Runtime:** <agent fan-out | sequential (degraded)>

| Lens | Verdict | Confirmed findings |
| --- | --- | --- |
| readiness *(PR-bound targets only)* | pass/fail/warn | n |
| <lens> | pass/fail/warn | n |

**Recommendation:** APPROVE / REQUEST CHANGES / NEEDS DISCUSSION

### Confirmed findings (ranked)
**[lens] title** — `file:line`
Problem · Why it matters · Suggested fix

### Conflicts between lenses      (only when present, both arguments)
### Unverifiable claims           (reported, never silently dropped)
### Clean                         (what was inspected and found sound)
### Not covered                   (lenses not run, scopes not assessable, node failures)
```

Rank confirmed findings by severity, then multi-lens agreement, then
confidence. Fold `refuted` findings away silently but count them in the scale
line. Cross-lens conflicts — findings whose suggestions contradict each other
(same file, incompatible directions) — are detected during assembly and
presented with both arguments, never silently resolved.

### Posting discipline

Only with an explicit user request and a PR target: write the report to a
scratch file and post it with `gh pr comment <number> --body-file <file>` (or
`gh pr review --comment/--request-changes --body-file <file>`), headed with
the roster named. Never interpolate the report body through shell arguments;
never post without the explicit request; never use `--approve` on the user's
behalf.
