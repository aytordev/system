---
title: Gather the Provider Evidence
impact: HIGH
impactDescription: Prevents guessing from the last log line
tags: ci, evidence, github-actions
---

## Gather the Provider Evidence

**Impact: HIGH**

Identify the CI provider from the repository configuration, then pull the
failure output with that provider's tool, CLI, or UI. Do not translate another
provider's commands by guesswork.

Record the run, job, attempt, commit SHA, and timestamps. Every later comparison
must refer to the same execution.

### GitHub Actions

```bash
gh run list --branch <branch> --limit 5        # find the failing run
gh run view <run-id> --log-failed              # only the failed steps' logs
gh run view <run-id> --job <job-id> --log      # one job's full log
gh run download <run-id>                       # artifacts: coverage, reports, screenshots
```

### Compare with the last green run

The diff between the failing run and the last green run on the same branch — in
commits, dependency lockfiles, and pipeline files — is the primary suspect list.
A lockfile that moved without a commit review is a frequent cause.

### Reruns and debug logging are mutations

A rerun may repeat deploys, migrations, notifications, or other effects. Inspect
the workflow and the failed job for side effects first, then rerun only with
explicit authority. When authorized, rerun the failed jobs:

```bash
gh run rerun <run-id> --failed
gh run rerun <run-id> --debug     # step-level logging
```

Remove any temporary debug variable afterwards. A debug flag left in place
changes the next run's behaviour and cost.

### Read the whole error

- Read the complete output, not the last line.
- Check preceding warnings; they often carry the real cause.
- Use the stack trace to locate the actual failure point.
- Look for earlier failures that cascade into the visible error.

### Structured telemetry counts as evidence

If the system under test emits structured telemetry (events, traces, exporter
output from test runs), pull it alongside the logs. Correlating a failing step
with a trace usually localizes the cause faster than log reading.
