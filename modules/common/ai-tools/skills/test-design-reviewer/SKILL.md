---
name: test-design-reviewer
description: "Trigger: assessing a test file or suite for quality, reviewing whether tests are understandable, maintainable, repeatable, atomic, necessary, granular, fast, and test-first. Rates each property with file-level evidence and returns only actionable findings."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Test Design Reviewer

Review tests as executable specifications and safety evidence. Read the tests
before the implementation so their public story can stand on its own, then
inspect the production boundary and repository constraints needed to judge the
claims accurately.

`rules/` is bundled with this skill. Repository paths and runner configuration
refer to the target repository.

## Activation Contract

Use this skill when:

- Assessing a test file or a suite for quality.
- Deciding whether tests are understandable, maintainable, repeatable, atomic,
  necessary, granular, fast, and test-first.
- A review needs evidence-backed findings rather than a style opinion.

Do not use it to rewrite the production code a test targets, or to invent tests
the suite is missing outside the reviewed scope.

## Hard Rules

1. **Read the tests before the implementation.** Record what a failure would
   mean; then check the production boundary.
2. **Rate every property** `Strong`, `Mixed`, `Weak`, or `Not assessed`, with an
   exact file location and the observed evidence.
3. **No aggregate score.** Unequal risks and contexts make a weighted number
   falsely precise.
4. **Never invent findings.** Report "no findings" when the suite holds up.
   Do not demand one assertion per test, one test per file, or unit tests where a
   higher-level contract is the honest boundary.
5. **Separate test defects from production-design seams and local preferences.**
   A missing seam is design evidence, not a bad test.

## The Eight Properties

| Property | Inspect | Strong evidence |
| --- | --- | --- |
| Understandable | Names, arrange/act/assert flow, domain vocabulary | The behaviour and the failure are clear without reconstructing internals |
| Maintainable | Coupling, duplication, fixtures, public boundaries | Behaviour-preserving refactors do not force unrelated test rewrites |
| Repeatable | Time, randomness, concurrency, network, shared resources | Repeated and parallel runs use controlled inputs and clean up |
| Atomic | Shared state, ordering, cleanup, failure isolation | A test runs alone and its failure identifies one behaviour |
| Necessary | Distinct risk or contract protected | Removing it would remove meaningful evidence |
| Granular | Scope of behaviour and diagnostic quality | Assertions describe one coherent outcome; related assertions may stay together |
| Fast | Measured feedback time at the appropriate layer | The suite is fast enough for its intended loop |
| First | Evidence of test-first development | A captured RED run, trace, or history shows the test failed for the expected reason before the behaviour changed |

Three ratings are frequently `Not assessed`, and that is correct:

- **First** when only the final tree is available — static test shape cannot prove
  chronology.
- **Fast** without execution evidence or trustworthy timing.
- Any property whose evidence the review did not gather.

## Execution Steps

1. Establish the claimed behaviour, test layer, repository policy, and risk.
2. Read the tests alone; record what a failure would mean.
3. Inspect the public production boundary, fixtures, and configured runner.
4. Run focused tests or timing only when authorized and useful; say exactly what
   ran.
5. Rate all eight with evidence.
6. Rank actionable findings by severity and impact, each with the smallest
   credible fix.

## Output Contract

Return the property table, the ranked findings, and an explicit validation-gaps
list. Mark unassessed properties rather than guessing, and close with the
smallest next action when findings exist.

## References

- `rules/review-output.md` — rating discipline, findings shape, validation gaps.
- `references/provenance.md` — upstream source, revision, attribution, and licence.

The eight properties are Dave Farley's, not this skill's invention. When a
test-effectiveness question needs evidence beyond review, use the project's
mutation tooling instead of inferring from test shape.
