---
name: testing
description: "Trigger: writing tests, creating test factories, structuring test files, or deciding what to test for behaviour. Tests through the subject's public interface, reuses production schemas in fixtures, and names the evidence layer each claim actually proves."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Testing Patterns

Test behaviour, not implementation. Coverage helps find unexercised code; the
repository owns any threshold, and a percentage never replaces a meaningful
assertion.

`rules/` is bundled with this skill. Repository scripts and configuration override
the generic examples.

## Activation Contract

Use this skill when:

- Writing tests for new or changed behaviour.
- Creating or refactoring test factories and fixtures.
- Structuring test files or deciding what deserves a test.
- Judging whether a green suite actually proves the behaviour.

Do not use it for browser- or component-specific testing; that claim needs the
browser layer's own evidence (see Output Contract).

## Hard Rules

1. **Test through the subject's public interface**, at the layer named by the
   claim. "Public" means the interface that owns the evidence, not necessarily the
   HTTP API.
2. **Never mock the function under test**, and never assert on private methods or
   internal state.
3. **No 1:1 mapping between implementation files and test files.** Organize around
   stable behaviour or contracts.
4. **Reuse the production schema in factories** where the module exports one;
   never redefine a schema in a test file.
5. **Fresh state per test.** A shared mutable fixture is an order-dependent
   failure waiting to happen.
6. **Name the narrowest evidence proved.** Test names, comments, and CI labels
   must not claim a higher layer than the test actually exercised.

## Execution Steps

1. **Name the claim** and the layer that owns it (domain operation, HTTP contract,
   component DOM, browser journey).
2. **Choose iteration scope**: exact selector only for RED or debugging; the
   runner-derived affected scope for GREEN.
3. **Plan against mutation**: list every comparison against a constant and every
   normalising call in the code you are about to cover; pin each with an input
   whose answer changes if the rule flips or the call disappears.
4. **Build fixtures** from factories that return scenario-valid objects and mark
   intentional invalidity.
5. **Assert the outcome**, ideally the whole result value, rather than a chain of
   member checks.

## Output Contract

State which layer each test proves and which behaviour is still unpinned. When the
claim is browser behaviour, a doorway, a spinner, or a user journey, the evidence
must come from the browser layer — an endpoint call proves the HTTP contract and
nothing about the UI path.

## References

- `rules/test-through-interface.md` — the interface table and the extraction trap.
- `rules/factories.md` — factory rules, schema reuse, composition.
- `rules/mutation-aware-planning.md` — the two lists that catch survivors early.
- `rules/coverage-theater.md` — patterns that execute code without proving it.
- `rules/execution-scope.md` — affected scope, watch mode, and the final gate.
- `references/provenance.md` — upstream source, revision, and licence notice.

Mutation analysis and test-design review are separate activities with their own
tools. When those are unavailable, apply their core questions directly: would a
plausible change to the rule survive my tests, and does this test fail for one
reason only?
