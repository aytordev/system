---
name: characterisation-tests
description: "Trigger: modifying existing code that lacks tests and its current behaviour must be pinned before changing it. Documents what the code actually does, marks suspicious behaviour instead of fixing it, and retires the tests once intended-behaviour tests replace them."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Characterisation Tests

> A characterisation test characterizes the actual behaviour of a piece of code.
> There is no "it should do this" — the tests document what the system really does.

Characterisation tests have no moral authority. They do not assert correctness;
they detect *change*. When one breaks, a human decides whether the change was
intended. Golden-master and approval testing are the same concept under other
names.

`rules/` is bundled with this skill. Repository paths and runner configuration
refer to the target repository.

## Activation Contract

Use this skill when:

- Modifying existing code that has no tests, or inadequate ones.
- Specifications are missing, incomplete, or contradict the running system.
- The code is too complex to reason about by reading.
- You face the legacy dilemma: tests are needed to refactor safely, and the code
  resists testing.
- You must know what a function actually returns before changing it.

Do not use it for greenfield code, for behaviour you can specify from a
requirement, for the parts already covered, or as a permanent strategy.

## Hard Rules

1. **Never type an expected value you have not watched a run produce.** Write a
   placeholder, run, and paste what the runner printed. Deriving the value by
   reading the code, or by copying the function into a scratch script, pins your
   reading of the code instead of the code.
2. **Name them as characterisation tests** — in the test name, the file name, and
   a header comment. They are temporary scaffolding and must read that way.
3. **Mark suspicious behaviour, never fix it silently.** A test for old behaviour
   stays only while that behaviour is intentionally conserved.
4. **Scope to the change area plus one layer out.** Characterising the whole
   codebase is not the task.
5. **Coverage is not strength.** Pin likely mutant risks cheaply while
   characterising; leave an automated mutation run to the repository's chosen
   verification point.

## The Algorithm

1. Use the code in a test harness.
2. Write an assertion you know will fail, with a dummy value.
3. Run and let the failure report the actual behaviour.
4. Change the test to expect what the code produced.
5. Repeat, guided by what the code suggests.

Expected values come from exactly three places: the failing placeholder
assertion, a recorded snapshot, or a scratch test that imports the real module.
Nothing else.

## When to Stop

- Every branch your upcoming change touches is exercised.
- One layer out is covered — callers and callees of the change point.
- Likely mutant risks in the paths you will modify appear among the examples.

If you cannot be confident the tests would detect a mistake in the code you are
about to change, add more. If you can, stop.

## Finding Bugs

Every legacy codebase has them.

- **Deployed**: someone may depend on the "buggy" behaviour. Document it, mark the
  test suspicious, preserve it, and escalate before changing it.
- **Not yet deployed**: compatibility risk is lower, but non-deployment does not
  establish correctness. Resolve the intended behaviour from an authoritative
  requirement or user decision, then record the observed failure, fix it, and
  replace the old-behaviour characterisation with an intended-behaviour
  regression test.

## Lifecycle

Characterise → refactor under their protection → replace with intended-behaviour
tests → remove the characterisation file once the same behaviour is covered.

## References

- `rules/naming-and-lifecycle.md` — names, file suffix, header, suspicious markers.
- `rules/algorithm-and-tooling.md` — placeholders, snapshots, async, I/O seams.
- `references/provenance.md` — upstream source, revision, and licence notice.

For test-driving new behaviour, write the failing behaviour test first. For code
that resists testing at all, introduce one coherent seam rather than mocking
internals; the characterisation file is not the place to solve testability.
