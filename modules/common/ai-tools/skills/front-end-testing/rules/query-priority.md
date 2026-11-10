---
title: Query the Way a Person Perceives the Page
impact: CRITICAL
impactDescription: Keeps tests user-facing and exposes accessibility gaps
tags: front-end-testing, queries, accessibility
---

## Query the Way a Person Perceives the Page

**Impact: CRITICAL**

### Query priority (accessibility-first)

1. **`getByRole`** — highest priority: ARIA role + accessible name; mirrors
   the screen reader experience; forces semantic HTML.
2. **`getByLabelText`** — form fields, via the associated `<label>`.
3. **`getByPlaceholder`** — fallback when no label exists (a placeholder
   should not replace one). Testing Library's name is `getByPlaceholderText`.
4. **`getByText`** — non-interactive content users read.
5. **`getByDisplayValue`** — inputs with pre-filled values (Testing Library
   only; Browser Mode has no such locator — use `getByRole` plus a value
   assertion).
6. **`getByAltText`** — images.
7. **`getByTitle`** — rare, when nothing else fits.
8. **`getByTestId`** — last resort only; not user-facing.

Vitest Browser Mode locators mirror Testing Library queries — no separate
`@testing-library/dom` import needed:

```typescript
import { page } from 'vitest/browser'

page.getByRole('button', { name: /submit/i })
page.getByText(/welcome/i)
page.getByLabelText(/email/i)
```

### Query variants

- **`getBy*`** — element must exist (throws if not found). Use when asserting
  existence.
- **`queryBy*`** — returns null if not found. Use when asserting
  **non-existence**.
- **`findBy*`** — async, waits for the element to appear.

Browser Mode locators are lazy and retried by `expect.element()`, so the
get/query/find split mostly disappears — use `.not.toBeInTheDocument()` via
`expect.element` for absence.

### Common mistakes

```typescript
// ❌ WRONG - querySelector (DOM implementation detail)
const button = container.querySelector('.submit-button');
// ❌ WRONG - testId when a role is available (not how users find the button)
screen.getByTestId('submit-button');
// ❌ WRONG - role without accessible name (which button? pages have many)
screen.getByRole('button');
// ✅ CORRECT - role + accessible name (how screen readers find it)
screen.getByRole('button', { name: /submit/i });

// ❌ WRONG - getBy to assert non-existence (awkward throw-based check)
expect(() => screen.getByText(/error/i)).toThrow();
// ✅ CORRECT - queryBy returns null
expect(screen.queryByText(/error/i)).not.toBeInTheDocument();

// Less specific: finds matching text without proving the element's role
screen.getByText(/welcome,\s+john doe/i);
// Preferred when this is a heading: query the accessible role and name
screen.getByRole('heading', { name: /welcome,\s+john doe/i });
```

### Why accessible queries

1. Tests mirror real usage — queries like screen readers do.
2. Tests improve app accessibility — they force accessible markup.
3. Refactor-friendly — coupled to user experience, not implementation.

If an accessible query fails, investigate the accessible name and role first.
The failure may reveal an accessibility issue, but it can also mean the query
or test setup is wrong.

### Ambiguity is the same signal

A query that matches **more than one** element is a signal, not a licence to
change query style. Resolve the ambiguity accessibly: a more specific role
plus accessible name, the user-visible text of the outcome itself,
`filter({ hasText: /…/i })`, or a container found by an accessible query
(`getByRole('region', { name: /…/i })`, `within(screen.getByRole('form', {
name: /…/i }))`). If nothing accessible distinguishes them, the page is
missing an accessible name — add it.

Never escape an ambiguous match by scoping to a class or id
(`page.locator('#panel').getByRole(...)`,
`within(container.querySelector('.panel'))`): that re-couples the test to
markup no user can perceive and buries the accessibility gap that caused the
ambiguity.

### Semantic HTML over ARIA

```html
<!-- ❌ WRONG - Custom element + ARIA -->
<div role="button" onclick="handleClick()" tabindex="0">Submit</div>

<!-- ✅ CORRECT - Semantic HTML: built-in keyboard nav, focus, screen reader support -->
<button onclick="handleClick()">Submit</button>
```

Add ARIA only where semantic HTML is unavailable (for example
`role="dialog"` on a custom modal), never redundantly on semantic elements.
