---
title: Make the Browser Do the Work in E2E
impact: CRITICAL
impactDescription: Prevents HTTP shortcuts certifying journeys no user can complete
tags: front-end-testing, playwright, e2e, evidence
---

## Make the Browser Do the Work in E2E

**Impact: CRITICAL**

The one rule that governs E2E suites: **a browser or user-journey claim must
be proved by a browser initiator** — an accessible locator action or a
navigation — never by a direct HTTP call standing in for the user or the
frontend. `page.request.post('/api/...')` in a test named "user creates ..."
proves an HTTP contract, not a journey; it stays green when the button, cookie
policy, CSRF check, redirect, or rendering breaks.

An HTTP endpoint can be perfectly public and still be the wrong interface for
a browser claim. Load `references/playwright-e2e.md` before writing or
reviewing any E2E/journey suite — it carries the decision rule, the
evidence-boundary table, safe request observation, the direct-transport audit
procedure, and the auth/lifecycle evidence contract.

### Classify what each step really is

- A **user action** is initiated through an accessible locator and a real
  locator action (`click`, `fill`, keyboard input). This is the only initiator
  a "user does X" claim may use.
- **Automatic frontend work** (a probe on mount, a refresh after navigation,
  an SSE subscription) is *caused* by navigation, reload, mount, or a UI state
  transition — then **observed**. The test may listen to the request/response;
  it must not manufacture the request.
- A **direct HTTP call** is allowed only when the test's explicit subject is
  an HTTP contract, a readiness probe, a fixture/setup seam, a server-side
  post-condition check after honest browser actions, a diagnostic, or a
  deliberate external actor. Its test name and comments must state that
  narrower role — and what it does *not* prove.
- **Setup evidence cannot be borrowed.** Direct-API setup may create
  pre-existing state, but the browser claim begins only when the page is
  created/navigated, and the browser portion must independently prove its
  stated outcome.

### Observing requests without performing them

Attach the listener **before** the user action, match the method and the
*parsed* URL path precisely, drive the action through the UI, then assert both
the response and the stable user-visible state:

```ts
// ❌ WRONG: the test performs the frontend's job.
const response = await page.request.post('/api/sessions', { data })

// ❌ WRONG: broad substring predicate — can match stale or unrelated traffic.
const anything = page.waitForResponse((r) => r.url().includes('/api/'))

// ✅ CORRECT: the user acts; Playwright observes the request the frontend owns.
// No await on the next line — attach first, await after the action,
// or the observer races the response and can hang.
const created = page.waitForResponse((response) =>
  response.request().method() === 'POST' &&
  new URL(response.url()).pathname === '/api/sessions'
)
await page.getByRole('button', { name: 'Create' }).click()
expect((await created).status()).toBe(201)
await expect(page.getByRole('heading', { name: 'Session created' })).toBeVisible()
```

`waitForResponse` is an **observer, not proof by itself**. Ownership and user
impact are established by the accessible action that initiated the request and
by the rendered outcome. Web-first auto-retrying assertions are the default
readiness signal; reach for `waitForResponse` only when the network exchange
itself is part of the claim.

`page.request` shares the browser context's cookie jar, so its calls *look*
authenticated — but they originate directly from Node.js. They are not
initiated by frontend code, not intercepted by `page.route()`, not subject to
CORS or service workers, and carry no browser-generated Fetch Metadata from a
real user gesture. Shared cookies prove the jar works, not that the frontend,
the user, or the browser's security posture did anything.

### The direct-transport audit

To audit an existing suite, search and classify — including indirect wrappers
and their callers; grepping literal `fetch(` is insufficient:

- Playwright `page.request`, the `request` fixture, `APIRequestContext`, and
  any newly created request contexts.
- Node/global `fetch`, axios and other HTTP clients, and helper functions that
  wrap any of them (trace each wrapper's definition to every caller).
- `page.evaluate(() => fetch(...))` or equivalent in-page request
  construction.
- Manual security/browser headers — `Sec-Fetch-*`, `Origin`, CSRF tokens,
  cookies — used to impersonate a browser.
- CLI/subprocess helpers that initiate HTTP, and tests that consume the
  fixture state they created.
- Browser-owned traffic — navigation, `EventSource`, WebSocket, ordinary
  frontend requests — distinguishing **observation** (legitimate) from
  **initiation** (the finding).

Also review test names, comments, CI step labels, and docs for **evidence
overclaims** — prose that promises browser proof a direct call delivered.
Record every finding as a ledger row: file and test/callers, endpoint/action,
real initiator in production, layers bypassed, exact claim the test currently
makes, disposition (replace / retain with narrower scope / remove), and the
residual coverage gap. The full procedure is in
`references/playwright-e2e.md`.

### Anti-patterns: false browser/security confidence

- `page.request`/`APIRequestContext` performing sign-in, create, join, edit,
  or any action the test describes as a browser/user journey.
- `page.evaluate(fetch)` to trigger frontend-owned work — an in-page transport
  is still not the frontend's code path.
- Manually forging `Sec-Fetch-Site`, `Sec-Fetch-Mode`, `Origin`, CSRF tokens,
  cookies, or other browser-generated evidence so a browser-only endpoint
  accepts a non-browser client. That is fabricating the very evidence the
  endpoint exists to demand. Use a real browser/frontend initiator, reuse
  state from a separately honest upstream proof, or withdraw/narrow the claim
  and document the gap. Do **not** respond by weakening the endpoint.
  (Legitimate API headers on a real, documented non-browser API contract are
  fine — that is a different subject.)
- Injecting authorization/session state and then claiming provider redirects,
  cookie issuance, logout, or frontend coordination worked.
- `dispatchEvent` or DOM evaluation for ordinary user actions when a real
  accessible locator action exists.
- Arbitrary sleeps (`waitForTimeout`), `waitForLoadState('networkidle')`
  (officially discouraged — rely on web assertions to assess readiness), or
  repeated polling that merely hides lifecycle races.

### Auth and lifecycle evidence

- Provider sign-in is proved through the provider's UI, redirects, and
  callback — not a direct login endpoint.
- Application-session cookies are proved through the browser's own cookie
  transport plus a **fresh navigation/reload** — not by asserting a
  `Set-Cookie` header arrived.
- Logout must survive a fresh frontend initialization and show the
  unauthenticated UI.
- Observe auth requests without exposing authorization codes, tokens, cookies,
  or credentials in logs, traces, screenshots, URLs, storage, or history.
- Run every supported auth/storage profile through the full journey — a flow
  proved on one profile is unproved on the others.
- Cached auth state (`storageState`, saved by a setup project and loaded via
  project dependencies) is a fixture seam: it legitimately skips *re-proving*
  sign-in in unrelated tests only when the sign-in journey itself is proved by
  its own honest test. API-based login setup yields **zero evidence the login
  UI works** — keep at least one real UI sign-in test whenever sign-in is a
  claimed behaviour. Never commit saved auth state; use one account per
  parallel worker when tests mutate shared server state.
- For lifecycle/race-sensitive flows, repeat the **full browser journey** when
  practical rather than adding retries or sleeps. For time-dependent
  behaviour, prefer the clock API (`page.clock.install()`, `fastForward`) over
  real waiting.
- Bound real cold-start readiness with evidence-based timeouts and
  deterministic failure diagnostics (trace viewer with `trace:
  'on-first-retry'`, or `'retain-on-failure'` when runner retries are
  disabled; `--repeat-each` for reproduction) — and keep the journey itself
  free of manual in-test retry loops.

OAuth/OIDC protocol design and session-cookie/CSRF policy design are separate
concerns with their own guidance; the evidence contract above is what a test
suite must satisfy regardless of which design the application uses.
