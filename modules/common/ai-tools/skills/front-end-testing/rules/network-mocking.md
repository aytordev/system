---
title: Mock the Network, Not the Module
impact: CRITICAL
impactDescription: Keeps request logic under test across environments and failure paths
tags: front-end-testing, msw, mocking
---

## Mock the Network, Not the Module

**Impact: CRITICAL**

Use MSW, not `fetch`/`axios` mocks — it intercepts at the network level, so
the same handlers work in tests, Storybook, and development:

```typescript
// ❌ WRONG - Mocking fetch implementation
vi.spyOn(global, 'fetch').mockResolvedValue({
  json: async () => ({ users: [...] }),
}); // Tight coupling, won't work in Storybook

// ✅ CORRECT - MSW intercepts at network level
http.get('/api/users', () => {
  return HttpResponse.json({ users: [...] });
});
```

### The rule covers the app's own request module, not just `fetch`

Most apps wrap the transport in one module (an api/client/service file, a
generated SDK). Replacing *that* module — `vi.mock('./api')`, or handing the
subject a hand-written fake client — is the same anti-pattern one layer up: it
deletes the real URL building, serialization, status handling and error
mapping from the test, and proves nothing about the request the app actually
makes. Mock the *response*, never the module that asks for it.

This holds on failure paths too: to make a request fail, time out, or fail
once and then succeed, add a per-test handler (`server.use()` /
`worker.use()` with `HttpResponse.error()` or a non-2xx status) — never
`mockRejectedValueOnce` on a module of yours.

### Environment determines the API

| Environment | API | Import |
| --- | --- | --- |
| Vitest Browser Mode (real browser) | `setupWorker` | `msw/browser` |
| Node / jsdom / happy-dom | `setupServer` | `msw/node` |

Mixing these up is a common failure mode: `setupServer` patches Node's request
modules and does nothing inside a real browser. Using `setupServer` in Browser
Mode silently does nothing — tests run in a real browser.

- **Browser Mode**: `setupWorker` from `msw/browser`; start the worker in a
  setup file; per-test overrides via `worker.use()`.
- **Node/jsdom**: `setupServer` from `msw/node`; per-test overrides via
  `server.use()`.

Both setups consume the same shared handlers, start with
`onUnhandledRequest: 'error'` to fail fast on unhandled requests, reset
handlers after each test, and stop/close after all tests. Full setup,
including the Service Worker script generation and the per-test override
pattern, is in `references/msw.md`.
