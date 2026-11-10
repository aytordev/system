---
name: front-end-testing
description: "Trigger: testing any front-end application, writing UI or end-to-end tests, querying DOM elements, simulating user interactions, or choosing the lightest harness that proves a browser-observable claim. Tests the behaviour users see across Vitest Browser Mode, Playwright E2E evidence boundaries, and DOM Testing Library, and names the harness each hand-back's evidence stops at."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Front-End Testing

Test the behaviour users see, not implementation details. Your UI has two
users: end-users interacting through the DOM, and developers refactoring the
implementation. "The more your tests resemble the way your software is used,
the more confidence they can give you."

`rules/` is bundled with this skill. Repository scripts and configuration
override the generic examples.

## Activation Contract

Use this skill when:

- Testing any front-end application, in a real browser or a simulated DOM.
- Writing or auditing UI or end-to-end test suites.
- Choosing queries, simulating user interactions, or waiting on async UI.
- Mocking APIs for component or journey tests.
- Deciding which harness can prove a given claim.

Do not use it for framework-specific component dialects beyond the general
patterns here; React specifics are the react-testing companion's subject, and
the general rules below still govern them.

## Hard Rules

1. **Test behaviour users see.** Drive the UI the way a user would and assert
   what the user sees; never assert internal state, private methods, or CSS
   classes as hooks.
2. **One claim, one harness.** Prove a claim with the lightest harness that can
   fail when the claim is false: jsdom/Testing Library for component
   contracts, Vitest Browser Mode for browser-observable behaviour, Playwright
   E2E only when the claim is the served application.
3. **A browser or user-journey claim must be proved by a browser initiator** —
   an accessible locator action or a navigation — never by a direct HTTP call
   standing in for the user or the frontend.
4. **Mock the network at the network.** Use MSW; never stub `fetch`/`axios` or
   `vi.mock` the app's own request module, on success or failure paths.
5. **Every element is found the way a person perceives it** — `getByRole` with
   an accessible name first; `getByTestId` is a last resort.
6. **All browser/Playwright tests are idempotent**: each test creates its own
   state and cleans it up; parallel runs must not collide.
7. **Every hand-back names the harness and where its evidence stops.** A jsdom
   suite proves no real rendering, CSS, focus, or browser event dispatch; a
   component suite proves no served app, routing, or real server; one journey
   proves no path it never walks.
8. **Watch mode is never PR evidence.** GREEN/REFACTOR use the complete
   affected scope; the gate is a complete non-watch run against the final
   tree, including the full required browser/project matrix.

## Execution Steps

1. **Name the claim** and pick the harness that owns its evidence
   (`rules/harness-and-claims.md`).
2. **Set up** a new harness only with the repository package manager, reviewed
   exact compatible versions, and authorized binary downloads; keep a stable
   lighter harness when it already proves the contract.
3. **Query accessibly** (`rules/query-priority.md`), interact through
   `userEvent` (CDP-based in Browser Mode), and assert with
   `await expect.element(...)` in Browser Mode or `findBy*`/`waitFor` in
   jsdom (`references/async-patterns.md`).
4. **Mock APIs with MSW** at the environment-matching layer
   (`rules/network-mocking.md`, `references/msw.md`).
5. **For E2E/journey suites**, classify every step's initiator and audit the
   suite for direct-transport shortcuts (`rules/evidence-boundaries.md`,
   `references/playwright-e2e.md`).
6. **Keep feedback fast and bounded** and finish with the full non-watch gate
   (`rules/browser-feedback.md`).
7. **Work in a legacy jsdom/`@testing-library/dom` codebase?** Apply the
   legacy dialect (`references/dom-testing-library-legacy.md`): `screen`
   queries, `userEvent` over `fireEvent`, jest-dom matchers, cleanup
   ownership.

## Output Contract

Every report of finished UI test work — reply, PR body, CI step label — states
the runner and environment that produced the evidence (Playwright against the
served app, Vitest in jsdom, Browser Mode in a real browser) and, in the same
breath, the nearest thing it does not prove. "All tests pass" with the
boundary left unsaid reads as a stronger claim than the tests support.

## References

- `rules/harness-and-claims.md` — behaviour-over-implementation, harness choice, one claim one harness.
- `rules/browser-feedback.md` — affected scope, watcher lifecycle, idempotency.
- `rules/query-priority.md` — accessibility-first queries, ambiguity, semantic HTML.
- `rules/network-mocking.md` — the MSW rule and environment selection.
- `rules/evidence-boundaries.md` — Playwright E2E initiators, the direct-transport audit, auth/lifecycle evidence.
- `references/async-patterns.md` — `findBy`/`waitFor`/`waitForElementToBeRemoved` patterns and anti-patterns.
- `references/dom-testing-library-legacy.md` — jsdom/Testing Library dialect details.
- `references/msw.md` — full `setupWorker` and `setupServer` setup with per-test overrides.
- `references/playwright-e2e.md` — the complete E2E evidence contract.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When a TDD or general testing skill is not
installed, apply their rules directly: drive the work with a failing test
first, run the narrowest selector for RED and the runner-derived affected
scope for GREEN, and build repeated fixture shapes from factories with fresh
state per test. Where a dependency blocks a clean test, prefer parameter
injection so the dependency becomes an explicit seam; module mocking is
temporary scaffolding, never the design. React-specific component, hook, and
context patterns are the react-testing companion's subject; the rules here
still govern them.
