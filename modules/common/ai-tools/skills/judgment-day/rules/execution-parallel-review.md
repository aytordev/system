---
title: Parallel Blind Review
impact: CRITICAL
impactDescription: Core mechanism — two independent perspectives
tags: execution, parallel, judges
---

## Parallel Blind Review (Pattern 1)

**Impact: CRITICAL**

Launch **TWO** judges in parallel — never sequential. The mechanism is the
client's native parallel primitive, not a `delegate` instruction:

- **OpenCode**: two `Task` calls in a single assistant turn, with
  `subagent_type: sdd-review` (a `read-only` role: `edit: deny`, `bash: deny`)
  and `background: false`. Both calls must be emitted together so the client
  runs the subagents concurrently; each Task gets its own child session.
- **Pi**: one `judgment-day` command from the T05 workflow adapter, which
  dispatches two bounded child workers with distinct native session ids.

Each judge receives the **same target and the same pinned revision**, but works
independently:

- **Neither judge knows about the other** and receives none of its findings —
  no cross-contamination.
- Both get identical review criteria and the identical injected skill paths.
- NEVER do the review yourself as the orchestrator — your job is coordination
  only.

### Target revision

Pin the target before launching: resolve the review target to a concrete
revision (a commit SHA, tag, or PR head) and pass that exact revision to both
judges. Both judges review the same revision; a judge must not fetch a newer
one. Record the revision in the verdict so the correction lane can prove what
was reviewed.

### Read-only boundary

Judges are reviewers, not fixers. On OpenCode the `sdd-review` role enforces
this (`edit`/`bash` denied). On Pi the configured third-party permission gate
is unverified, so the adapter passes a read-only write policy but enforcement
is not guaranteed — treat Pi judge write attempts as a policy violation to
report, not a blocked action.

### Bounded failure and cancellation

Both judges must finish before synthesis. If one judge fails, times out, or is
cancelled:

- Keep waiting for the other judge; never synthesize from a single verdict.
- Record the failed judge as an explicit error/cancelled result.
- If the whole run is cancelled, cancel both judges and report `ESCALATED` —
  do not report APPROVED.

### Judge Return Format

Each judge returns a structured list of findings:

```
Each finding:
- Severity: CRITICAL | WARNING (real) | WARNING (theoretical) | SUGGESTION
- File: path/to/file.ext (line N if applicable)
- Description: What is wrong and why
- Suggested fix: one-line intent (not code)

If NO issues: VERDICT: CLEAN — No issues found.
```
