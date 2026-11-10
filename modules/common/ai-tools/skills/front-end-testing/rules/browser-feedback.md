---
title: Keep Browser Feedback Fast and Bounded
impact: HIGH
impactDescription: Prevents hand-picked green scopes and leaked watchers
tags: front-end-testing, feedback, idempotency
---

## Keep Browser Feedback Fast and Bounded

**Impact: HIGH**

### Affected scope for browser tests

- RED/debug browser runs use the narrowest file/project/grep selection that
  proves the result — a Playwright file, `--grep`, `--last-failed`, or
  hand-picked project filter only to prove RED or debug a known failure.
- GREEN/REFACTOR use the complete affected scope derived by the runner,
  workspace orchestrator, or repository mapping — never hand-picked test
  files. Playwright Test's native `--only-changed[=<real-base>]` selects
  changed test files and tests that import changed files, but Playwright
  documents this as a heuristic; browser journeys often exercise application
  code at runtime rather than importing it, and dynamic/non-import
  dependencies can remain invisible.
- Browser dependencies are often outside the import graph. Widen for routing,
  global styling, browser setup, templates, generated assets, type-only
  relationships, browser-mode orchestration, and Docker-backed services.
  Preserve repository `watchTriggerPatterns`, `forceRerunTriggers`, and root
  monorepo project/task graphs. The Node/SSR clean-start proof does not prove
  Browser Mode; verify its installed version/configuration independently, and
  do not assume `--changed --watch` reloads VCS impact after startup.
- For changes the graph cannot see, use the repository-mapped affected
  journey/project set, including every consumer of shared fixtures, auth
  state, setup, routing, styling, and UI packages; widen when uncertain. When
  no reliable graph exists, use the owning-suite-plus-known-consumers
  fallback.
- With a one-shot runner, rerun the affected command after creating a test.
  Newly created tests must join the active watcher or the one-shot rerun.
  Never count an empty affected set, Vitest `--passWithNoTests`, or Playwright
  `--pass-with-no-tests` as evidence — confirm at least one expected test
  executed.

### Idempotency

All Playwright-style tests **must** be idempotent: same result regardless of
execution order, repetition, or what ran before. Browser Mode can run tests in
parallel across multiple browser instances; non-idempotent tests produce flaky
failures that are nearly impossible to debug.

- Each test creates its own state from scratch — never depend on another
  test's side effects.
- Clean up persistent state (database rows, localStorage, cookies) created
  during the test.
- Use identifiers with enough entropy for parallel runs (for example
  `crypto.randomUUID()`); timestamps alone can collide.
- Never assume the DOM is in a particular state at the start of a test —
  render fresh.
- If tests share a server or database, use isolation strategies (transactions,
  test-specific data).

```typescript
// ❌ WRONG - Tests depend on shared state
it('creates a user', async () => {
  await page.getByRole('button', { name: /create/i }).click()
  // Creates user "Alice" in the database
})

it('lists users', async () => {
  // Assumes "Alice" exists from previous test!
  await expect.element(page.getByText('Alice')).toBeVisible()
})

// ✅ CORRECT - Each test is self-contained
it('creates and displays a user', async () => {
  const uniqueName = `User-${crypto.randomUUID()}`
  try {
    await page.getByLabelText(/name/i).fill(uniqueName)
    await page.getByRole('button', { name: /create/i }).click()
    await expect.element(page.getByText(uniqueName)).toBeVisible()
  } finally {
    await testData.deleteUserByName(uniqueName) // repository-owned idempotent cleanup fixture
  }
})
```

### Watcher lifecycle and the gate

- One watcher, in a dedicated reusable terminal or session, reused for the
  loop; stop it before gates or handoff. When automation spawns one, timeout
  and signal cleanup must terminate the whole watcher process group and remove
  temporary directories.
- Watch mode is an inner-loop accelerator, never PR evidence.
- At PR readiness, stop watchers and apply the target repository's mutation
  policy plus the complete non-watch test gate against the final tree. That
  gate includes the full required UI matrix across every configured
  browser/project; targeted Chromium-only, `--grep`, or UI-only evidence is
  insufficient.
- Blanket retries are not a fix. Configured suite retries that mark retried
  passes `flaky` — ideally with `failOnFlakyTests` gating CI — are a
  visibility tool; the fix lives in the app or the test's evidence model,
  never in retrying until green.
