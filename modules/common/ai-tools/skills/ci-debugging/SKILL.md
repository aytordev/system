---
name: ci-debugging
description: "Trigger: a CI pipeline, workflow, or build job fails, tests pass locally but fail in CI, or a pipeline is red, flaky, or timing out. Diagnoses with evidence-first investigation, faithful local reproduction, and CI-versus-local environment deltas."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# CI Debugging

Every CI failure is real until proven otherwise. Never assume flakiness.

This skill owns pipeline-specific evidence and environment deltas. A local or
runtime failure outside CI follows the same discipline with the local runtime's
evidence. `rules/` is bundled with this skill; repository paths refer to the
target repository.

## Activation Contract

Use this skill when:

- A CI pipeline, workflow, or build job fails.
- Tests pass locally and fail in CI.
- A pipeline is flaky, times out, or is red for no explained reason.
- The user says "CI is failing", "the build is broken", or "works on my machine".

## Hard Rules

1. **Evidence before hypotheses.** Pull the actual failure output from the
   provider before forming a cause. Preserve run, job, attempt, commit SHA, and
   timestamps so later comparisons refer to the same execution.
2. **One falsifiable hypothesis at a time**, ranked by the evidence. Do not
   invent causes to fill a list.
3. **Reproduce the exact command locally** when a faithful environment exists.
   If it passes locally, treat the environment delta as evidence, not as proof
   of flakiness.
4. **Reruns mutate external state.** A rerun may repeat deploys, migrations, or
   notifications. Rerun only with explicit authority after inspecting the
   workflow and failed job for side effects.
5. **Diagnosis is not authorization.** A diagnosis-only request ends with the
   root cause, evidence, affected jobs, uncertainty, and recommended fix. It does
   not authorize workflow, dependency, test, or configuration changes.

## Execution Steps

1. **Identify the provider** from repository configuration.
2. **Collect the evidence**: failing run, failed steps, full job log, artifacts.
3. **Diff against the last green run** on the same branch. The commits, lockfile,
   and pipeline-file changes between those two runs are the primary suspects.
4. **Reproduce** the exact failing command in the closest faithful environment.
5. **Localize** the cause: code, dependency resolution, environment, parallelism,
   resources, network, or file-system semantics.
6. **Report or fix**, per the authority the user gave. For a fix, say why it
   addresses the root cause, run the exact failing command, and add the smallest
   durable regression guard that fits.

## Output Contract

Report: the run/job identity, the evidence that supports the cause, the affected
jobs, what remains uncertain, and either the recommended fix (diagnosis-only) or
the verified fix with its guard. Never report "flaky" without the controlled
inputs and the difference you observed.

## References

- `rules/evidence-gathering.md` — provider data, commands, and rerun authority.
- `rules/environment-delta.md` — local reproduction and the CI-versus-local table.
- `rules/verification-and-flakiness.md` — full-error reading, fix proof, flakiness.
- `references/provenance.md` — upstream source, revision, and licence notice.

If a structured-telemetry, TDD, or characterisation-testing companion skill is
not installed, apply the rule directly: read the traces the system already emits,
write the failing behaviour test before the fix, and capture legacy behaviour
before changing it.
