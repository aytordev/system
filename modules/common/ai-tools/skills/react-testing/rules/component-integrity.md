---
title: Keep the Component Tree Real
impact: CRITICAL
impactDescription: Prevents shallow rendering, child mocking, and act misuse
tags: react-testing, mocking, act, cleanup
---

## Keep the Component Tree Real

**Impact: CRITICAL**

### No shallow rendering — and no mocking a child component

**Never `vi.mock` a component the app under test owns.** Replacing a child
with a stand-in is shallow rendering by another name, and it is now the far
more common form. When a request asks you to stand something in for a child
because its markup is somebody else's problem, honour the concern, not the
mechanism: render the whole tree and assert only the parent's own observable
facts — which items are on screen, the count line, the empty state — and pin
none of the child's markup. Mock across a real boundary (network via MSW,
clock, randomness), never inside your own component tree.

```tsx
// ❌ WRONG - Child replaced by a stand-in, or shallow rendered
vi.mock('./ItemRow', () => ({ ItemRow: ({ item }) => <li>{item.title}</li> }))
const wrapper = shallow(<MyComponent />);
// Child components not rendered - incomplete test

// ✅ CORRECT - Full rendering
const screen = await render(<MyComponent />)
// Full component tree rendered - realistic test
```

**Why:** Shallow rendering hides integration bugs between parent and child
components.

### Testing component internals

```tsx
// ❌ WRONG - Accessing component internals
const wrapper = shallow(<MyComponent />);
expect(wrapper.state('isOpen')).toBe(true); // Internal state
expect(wrapper.instance().handleClick).toBeDefined(); // Internal method

// ✅ CORRECT - Test rendered output
const screen = await render(<MyComponent />)
await expect.element(screen.getByRole('dialog')).toBeVisible() // What user sees
```

### Unnecessary act() wrapping

```tsx
// ❌ WRONG - Manual act() around renders and interactions
await act(async () => {
  await screen.getByRole('button').click()
})

// ✅ CORRECT - Locator events handle timing
await screen.getByRole('button').click()
```

**When you DO need `act()`:** hook state updates via `renderHook` (use the
`act` it returns). In `@testing-library/react`, RTL auto-wraps
`render`/`userEvent`/`waitFor`/`findBy` — see
`references/testing-library-react-legacy.md`.

### Shared renders and cleanup ownership

Shared mutable render state is the defect, not a lifecycle hook. An isolated
`beforeEach` may create fresh state for each non-concurrent test; use a helper
only when repeated or nested setup becomes clearer.

```tsx
// ❌ WRONG - Shared state across tests
let button;
beforeEach(() => {
  render('<button>Submit</button>');
  button = screen.getByRole('button');
});

// ✅ CORRECT - Factory function per test
const renderButton = () => {
  render('<button>Submit</button>');
  return { button: screen.getByRole('button') };
};
```

Testing Library cleanup is automatic only when the harness provides its
expected global `afterEach`; otherwise register an explicit
`afterEach(() => cleanup())` in test setup.

### All browser tests are idempotent

Every test must produce the same result regardless of execution order, how
many times it runs, or what other tests ran before it. Each test creates its
own state from scratch, cleans up any persistent state it creates, uses
identifiers with enough entropy for parallel runs, renders fresh instead of
assuming DOM state, and isolates shared server/database state.
