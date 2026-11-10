---
title: Choose the Harness That Owns the Claim
impact: CRITICAL
impactDescription: Prevents false confidence and duplicate suites
tags: front-end-testing, harness, philosophy
---

## Choose the Harness That Owns the Claim

**Impact: CRITICAL**

### Test behaviour users see

Coupling tests to implementation produces false negatives (break on refactor)
and false positives (bugs pass):

```typescript
// ❌ WRONG - Coupled to state implementation; breaks when state → signals → stores
it('should update internal state', () => {
  const component = new CounterComponent();
  component.setState({ count: 5 });
  expect(component.state.count).toBe(5);
});

// ❌ WRONG - Button exists but onClick is broken; test still passes
it('should render button', () => {
  render('<button data-testid="submit-btn">Submit</button>');
  expect(screen.getByTestId('submit-btn')).toBeInTheDocument();
});

// ✅ CORRECT - Drive the UI like a user; assert what the user sees
// type into labelled fields, click the submit button, assert the submit
// handler received the form data. Survives refactors, tests the contract,
// and catches real bugs (broken onClick, validation errors).
```

### One claim, one harness

Vitest Browser Mode tests a **component in isolation**; Playwright Test
against a running application tests **whatever the test's claim names** — a
user journey, the frontend's own network behaviour, cookie/CSRF posture,
redirects, rendering. Same browser engines, different subject and harness:
never assume guidance transfers between them.

Prove a claim with the lightest harness that can fail when the claim is false,
and stop there. Behaviour inside one mounted component — a bug fix, an error
path, a disabled button that must recover — is proved by the component-level
harness; adding an E2E spec that re-walks it buys no evidence, only a second
suite to maintain and a slower gate. Reach for Playwright when the claim
itself is the served application: navigation, several screens in sequence, the
real server, cookies, redirects. If you have already written the component
test, adding the journey needs a reason you can state.

### Prefer Browser Mode for browser-observable behaviour

Prefer Vitest Browser Mode when the claim depends on real rendering, CSS,
events, focus management, accessibility, or browser APIs and the repository
already supports it or the added harness cost is justified. Keep an existing
stable jsdom/happy-dom harness, or a lighter environment, when it proves pure
logic or component contracts without browser-specific behaviour.

| Aspect | jsdom/happy-dom | Browser Mode |
| --- | --- | --- |
| Environment | Simulated DOM in Node.js | Real browser (Chromium/Firefox/WebKit) |
| CSS | Not rendered | Real CSS rendering, layout, computed styles |
| Events | Synthetic JS events | CDP-based real browser events |
| APIs | Subset of Web APIs | Full browser API surface |
| Focus/a11y | Approximate | Real focus management, accessibility tree |
| Debugging | Console only | Full browser DevTools |

Setup: inspect the repository's package manager, lockfile, existing test
harness, and installed versions before changing dependencies or
configuration. If a new harness is justified and the user has authorized
setup, select exact mutually compatible versions from official
compatibility/peer-dependency evidence, install them with the repository
package manager, and invoke only repository-local binaries (no implicit
download). Inspect the `playwright install chromium` binary download before
authorizing it. If the reviewed installed version provides it, run the local
setup wizard (`<repo-pm> exec vitest init browser`) and inspect its planned
config writes first.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import { playwright } from '@vitest/browser-playwright'

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: playwright(),
      headless: true,
      instances: [{ browser: 'chromium' }],
    },
  },
})
```

### Multi-project setup (Node + Browser)

```typescript
export default defineConfig({
  test: {
    projects: [
      {
        test: {
          include: ['tests/unit/**/*.test.ts'],
          name: 'unit',
          environment: 'node',
        },
      },
      {
        test: {
          include: ['tests/browser/**/*.test.ts'],
          name: 'browser',
          browser: {
            enabled: true,
            provider: playwright(),
            instances: [{ browser: 'chromium' }],
          },
        },
      },
    ],
  },
})
```

### Browser Mode gotchas

- **`vi.spyOn` on imports**: ES module namespaces are sealed in real browsers.
  `vi.mock('./module', { spy: true })` works, but treat module mocking as
  temporary scaffolding — prefer parameter injection so the dependency is an
  explicit seam. It is never the answer for a module that makes network
  requests: mock that at the network with MSW, in every environment and on
  error paths as well as happy paths.
- **`alert()`/`confirm()`**: thread-blocking dialogs halt browser execution;
  mock them with `vi.spyOn(window, 'alert').mockImplementation(() => {})`.
- **`act()`**: not needed for component interactions via locators — CDP events
  plus `expect.element()` retry handle timing.
