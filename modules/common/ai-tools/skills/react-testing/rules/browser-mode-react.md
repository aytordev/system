---
title: Test React Components in Browser Mode
impact: HIGH
impactDescription: Gives the vitest-browser-react dialect for every component subject
tags: react-testing, browser-mode, hooks, forms
---

## Test React Components in Browser Mode

**Impact: HIGH**

Prefer `vitest-browser-react` when the claim depends on real rendering,
events, focus, CSS, accessibility, or browser APIs and the repository supports
the harness or the added cost is justified. Keep an existing stable
`@testing-library/react`/jsdom harness, or a lighter environment, when it
already proves pure hook, provider, or component logic.

### Setup

Extend the general Browser Mode config with the React plugin and
`vitest-browser-react`. Apply the repository-package-manager, exact-version,
authorization, and local-binary setup policy:

```bash
<repo-pm> add --save-dev vitest@<reviewed-version> @vitest/browser-playwright@<reviewed-version> vitest-browser-react@<reviewed-version> @vitejs/plugin-react@<reviewed-version>
```

```typescript
// vitest.config.ts — general Browser Mode config, plus:
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    browser: { /* unchanged */ },
  },
})
```

### Key differences from `@testing-library/react`

- `render()` and `renderHook()` are async — use `await`.
- `render` returns a `screen` scoped to the rendered component.
- Use `expect.element()` for auto-retrying assertions.
- No `act()` wrapper needed for component interactions via locators — CDP
  events plus retry handle timing. `renderHook` state updates still need
  `act` (returned by `renderHook`, see below).
- Auto-cleanup happens before each test (not after), so components stay
  visible for debugging.

### Component testing

```tsx
import { render } from 'vitest-browser-react'
import { expect, test } from 'vitest'

test('should display user name when provided', async () => {
  const screen = await render(<UserProfile name="Alice" email="alice@example.com" />)

  await expect.element(screen.getByText(/alice/i)).toBeVisible()
  await expect.element(screen.getByText(/alice@example.com/i)).toBeVisible()
})
```

### Testing props and callbacks

```tsx
test('should call onSubmit when form submitted', async () => {
  const handleSubmit = vi.fn()
  const screen = await render(<LoginForm onSubmit={handleSubmit} />)

  await screen.getByLabelText(/email/i).fill('test@example.com')
  await screen.getByRole('button', { name: /submit/i }).click()

  expect(handleSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
  })
})
```

### Testing conditional rendering (with MSW)

Browser Mode tests run in a real browser, so use MSW's `setupWorker`
(`msw/browser`) — not `setupServer`. Start the worker in a setup file and
override per test with `worker.use()`:

```tsx
import { http, HttpResponse } from 'msw'
import { worker } from '../vitest.browser.setup'

test('should show error message when login fails', async () => {
  worker.use(
    http.post('/api/login', () => {
      return HttpResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    })
  )

  const screen = await render(<LoginForm />)

  await screen.getByLabelText(/email/i).fill('wrong@example.com')
  await screen.getByRole('button', { name: /submit/i }).click()

  await expect.element(screen.getByText(/invalid credentials/i)).toBeVisible()
})
```

### Testing hooks with renderHook

`renderHook()` is async and returns `act` alongside `result` — use that `act`
for hook state updates:

```tsx
import { renderHook } from 'vitest-browser-react'

test('should toggle value', async () => {
  const { result, act } = await renderHook(() => useToggle(false))

  expect(result.current.value).toBe(false)

  await act(() => {
    result.current.toggle()
  })

  expect(result.current.value).toBe(true)
})
```

### Testing context providers

```tsx
test('should show user menu when authenticated', async () => {
  const screen = await render(
    <AuthProvider initialUser={{ name: 'Alice', role: 'admin' }}>
      <Dashboard />
    </AuthProvider>
  )

  await expect.element(screen.getByRole('button', { name: /user menu/i })).toBeVisible()
})
```

For hooks that need context:
```tsx
const { result } = await renderHook(() => useAuth(), {
  wrapper: ({ children }) => (
    <AuthProvider>{children}</AuthProvider>
  ),
})
```

### Testing forms

```tsx
test('should submit form with user input', async () => {
  const handleSubmit = vi.fn()
  const screen = await render(<RegistrationForm onSubmit={handleSubmit} />)

  await screen.getByLabelText(/name/i).fill('Alice')
  await screen.getByLabelText(/email/i).fill('alice@example.com')
  await screen.getByLabelText(/password/i).fill('password123')
  await screen.getByRole('button', { name: /sign up/i }).click()

  expect(handleSubmit).toHaveBeenCalledWith({
    name: 'Alice',
    email: 'alice@example.com',
    password: 'password123',
  })
})

test('should show validation errors for invalid input', async () => {
  const screen = await render(<RegistrationForm />)

  // Submit empty form
  await screen.getByRole('button', { name: /sign up/i }).click()

  // Validation errors appear
  await expect.element(screen.getByText(/name is required/i)).toBeVisible()
  await expect.element(screen.getByText(/email is required/i)).toBeVisible()
  await expect.element(screen.getByText(/password is required/i)).toBeVisible()
})
```

### Testing loading states

```tsx
test('should show loading then data', async () => {
  const screen = await render(<UserList />)

  await expect.element(screen.getByText(/loading/i)).toBeVisible()

  await expect.element(screen.getByText(/alice/i)).toBeVisible()
  await expect.element(screen.getByText(/loading/i)).not.toBeInTheDocument()
})
```

### Testing error boundaries

```tsx
test('should catch errors with error boundary', async () => {
  // Suppress console.error noise for this test
  const spy = vi.spyOn(console, 'error').mockImplementation(() => {})

  try {
    const screen = await render(
      <ErrorBoundary fallback={<div>Something went wrong</div>}>
        <ThrowsError />
      </ErrorBoundary>
    )

    await expect.element(screen.getByText(/something went wrong/i)).toBeVisible()
  } finally {
    spy.mockRestore()
  }
})
```

### Testing portals

```tsx
import { page } from 'vitest/browser'

test('should render modal in portal', async () => {
  const screen = await render(<Modal isOpen={true}>Modal content</Modal>)

  // Portal renders outside the component root; query the page instead
  await expect.element(page.getByText(/modal content/i)).toBeVisible()
})
```

The returned `screen` is scoped to the rendered component — for portal
content, use the document-wide `page` from `vitest/browser`.

### Testing Suspense

```tsx
test('should show fallback then content', async () => {
  const screen = await render(
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
    </Suspense>
  )

  await expect.element(screen.getByText(/loading/i)).toBeVisible()
  await expect.element(screen.getByText(/lazy content/i)).toBeVisible()
})
```

### React Server Components

RSCs can't be tested in Browser Mode component tests — they execute on the
server, not in the browser. Test them with e2e tests (Playwright against a
running app) or unit tests of logic extracted from the component. Client
components (`'use client'`) test normally with `vitest-browser-react`.
