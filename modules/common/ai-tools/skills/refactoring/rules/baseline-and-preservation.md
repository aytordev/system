---
title: Keep a Recoverable Baseline
impact: CRITICAL
impactDescription: Guarantees a refactor can be reverted
tags: refactoring, baseline, verification
---

## Keep a Recoverable Baseline

**Impact: CRITICAL**

A working, recoverable baseline is what makes a refactor safe: it allows
reverting, supports experimentation, and separates structure changes from feature
changes in history.

### Workflow

1. **BASELINE** — the applicable tests pass, or the conserved behaviour and
   guarantees have proportionate evidence.
2. **CHECKPOINT** — record the baseline and its preservation evidence. Create a
   baseline commit only when the user explicitly approves it.
3. **REFACTOR** — improve structure in small steps under the project's
   fast-feedback policy. From a clean baseline, prefer the repository's own
   watch-mode entry point; if it is unproven for this configuration, repeat the
   affected one-shot run instead.
4. **VERIFY** — focused and affected tests, plus proportionate evidence, stay
   green after each step.
5. **CHECKPOINT** — present the verified change with the labelled assessment and
   the `Decision:` line. Commit only after explicit approval.
6. **PR GATE** — once the phase is ready for review, verify the accumulated
   result once: mutation evidence where meaningful, or an explicit `N/A` with
   proportionate alternate evidence. Address valuable survivors there.

### Cadence, not ceremony

- After each edit: the focused test that covers the touched behaviour.
- After each step: the affected modules' tests.
- Once before review: the repository's complete non-watch gate.

Rerunning the full suite after every edit buys nothing the focused run did not
already prove, and slows the loop that keeps the refactor safe.

### When the baseline cannot be recovered

If the only way to make the baseline recoverable is a commit the user has not
approved, stop. Asking is cheaper than an unrecoverable half-refactor.
