---
name: react-testing
description: "Trigger: testing React components, hooks, context, or forms. Renders components with vitest-browser-react or @testing-library/react, finds every element the way a person perceives it, never mocks a child component or asserts internals, and keeps the general UI evidence rules governing."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# React Testing

React component testing under the general UI rules: the claim decides the
harness, the user decides how elements are found, and the component's own
observable output decides what is asserted. `rules/` is bundled with this
skill; repository configuration overrides the generic examples.

## Activation Contract

Use this skill when:

- Testing React components, hooks, context providers, or forms.
- Choosing between `vitest-browser-react` and `@testing-library/react`.
- Reviewing React test code for shallow rendering, mocking, or `act` misuse.

Do not use it for non-React UI layers; the general front-end patterns
(queries, events, async, MSW, E2E evidence boundaries) govern any framework.

## Hard Rules

1. **Find every element the way a person perceives it** — never by
   `data-testid`, a CSS class, or a selector, and least of all because the
   component already carries one. A control is found by `getByRole` with its
   accessible name (`getByLabelText` for a field). An element with no role — a
   count line, a status message, a paragraph of copy, a bare `<span>` of text
   — is found by the words it shows: `getByText(/3 of 7 items/)`, then
   asserted on that same locator (`toBeVisible()`, `toHaveAttribute(...)`).
   Never fetch a handle by test id first just to assert its content. If
   nothing about the element is perceivable enough to query, that is a finding
   about the component: give it the role, label, or accessible name its
   purpose implies, and query that.
2. **Never `vi.mock` a component the app under test owns.** Replacing a child
   with a stand-in is shallow rendering by another name, and it is now the far
   more common form. Render the whole tree and assert only the parent's own
   observable facts — which items are on screen, the count line, the empty
   state — and pin none of the child's markup. Mock across a real boundary
   (network via MSW, clock, randomness), never inside your own component tree.
3. **No `act()` around renders or locator interactions.** Browser Mode handles
   timing via CDP events plus `expect.element()` retry; modern RTL auto-wraps
   `render`, `userEvent`, `waitFor`, and `findBy`. The exception is hook state
   updates via `renderHook`, which returns its own `act`.
4. **Test rendered output, not internals.** No `wrapper.state(...)`, no
   `wrapper.instance()`, no shallow render.
5. **Setup is isolated per test.** Shared mutable render state is the defect,
   not a lifecycle hook: an isolated `beforeEach` may create fresh state for
   each non-concurrent test; use a helper only when repeated or nested setup
   becomes clearer.
6. **Cleanup is either verified automatic for this harness or registered once
   in test setup.**
7. **MSW via `setupWorker`/`worker.use()` in Browser Mode** (jsdom uses
   `setupServer`/`server.use()`); never `vi.mock` or hand-write a fake of the
   app's own request module, on success or failure paths.
8. **All Browser Mode tests are idempotent** — no shared state between tests;
   and every hand-back names the harness and the nearest claim it does not
   prove.

## Execution Steps

1. **Choose the harness.** Prefer `vitest-browser-react` when the claim
   depends on real rendering, events, focus, CSS, accessibility, or browser
   APIs and the repository supports the harness or the added cost is
   justified. Keep `@testing-library/react`/jsdom when the stable lighter
   harness already proves the hook, provider, or component contract.
2. **Set up** the Browser Mode config with the React plugin
   (`rules/browser-mode-react.md`), applying the general policy: repository
   package manager, reviewed exact compatible versions, authorized binary
   downloads, repository-local binaries only.
3. **Write the test** with the patterns in `rules/browser-mode-react.md`
   (async `render`/`renderHook`, scoped `screen`, `wrapper` for context,
   forms, portals, suspense, error boundaries) or the legacy dialect in
   `references/testing-library-react-legacy.md`.
4. **Keep feedback fast and bounded.** React adds no separate Vitest graph
   guarantee: prefer the repository-owned watcher, use diff-selected watch
   only under the canonical version/configuration proof, and keep every
   affected app/package consumer eligible through the root graph. Exact files
   remain RED/debug-only. At PR readiness, stop watchers and apply the target
   repository's mutation policy plus the complete non-watch UI/project gate,
   including the full configured browser matrix.

## Output Contract

Report the harness that produced the evidence (Browser Mode in a real browser
or `@testing-library/react` in jsdom) and the nearest claim it does not prove:
a jsdom suite proves no real rendering, CSS, focus, or browser event dispatch;
a component suite proves no served app, routing, or real server.

## References

- `rules/browser-mode-react.md` — vitest-browser-react patterns: setup, components, hooks, context, forms, portals, RSC.
- `rules/component-integrity.md` — child-component mocking, shallow rendering, act, shared renders, cleanup.
- `references/testing-library-react-legacy.md` — the `@testing-library/react` + jsdom dialect.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When the general front-end testing, testing, or
TDD skills are not installed, apply their core rules directly: test behaviour
users see through accessible queries, wait with `findBy*`/`expect.element()`
rather than sleeps, mock APIs at the network with MSW, drive the work with a
failing test first, and build repeated fixture shapes from factories with
fresh state per test. Flow logic driving a component (for example a state
machine) is tested headlessly; a component test touches only the DOM and
never asserts machine state — if the component under test holds a
`submitting`/`isLoading` flag in `useState`, that is the signal the flow
escaped its machine. For performance changes to the same code, behaviour
tests stay unchanged and green.
