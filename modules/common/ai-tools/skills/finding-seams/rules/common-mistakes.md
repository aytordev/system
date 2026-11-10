---
title: Avoid the Classic Seam Mistakes
impact: MEDIUM
impactDescription: Keeps seams narrow, honest, and temporary where intended
tags: finding-seams, mistakes, sensing
---

## Avoid the Classic Seam Mistakes

**Impact: MEDIUM**

### Common mistakes

| Mistake | Fix |
|---------|-----|
| Using `vi.mock()` as permanent architecture | Module mocks bypass type safety and create implicit coupling. Migrate to parameter injection as soon as you have tests. |
| Leading with class-based patterns (subclass, DI containers) | In TypeScript FP, function parameters provide natural seams. Classes and DI containers are rarely needed. |
| Mocking everything instead of finding real seams | Mock only at the seam boundary; test real logic |
| Creating seams that leak implementation details | Seam interfaces should describe *what*, not *how* |
| Forgetting the enabling point | Every seam needs a place to choose behavior; if there's no enabling point, it's not a seam |
| Breaking too many dependencies at once | Break one dependency at a time; get a test passing; then break the next |

### Two reasons to break dependencies

Every seam technique serves either purpose:

| Purpose | Goal | Example |
|---------|------|---------|
| **Separation** | Run code in isolation without real collaborators | Pass `() => 2` instead of calling the transit-time service |
| **Sensing** | Observe what code does (args passed, functions called) | Collect calls in an array, assert against them |

When writing your first characterisation tests, you typically need
**separation** first (get the code running in a test), then add **sensing** to
verify specific behaviors.

### Sensing without mocks

When you need to observe what a dependency was called with, use a closure that
accumulates calls internally and returns a snapshot when queried, instead of a
mocking framework:

```typescript
type NotifyCall = { readonly to: string; readonly body: string };

const createSensingNotifier = () => {
  const recorded: NotifyCall[] = [];
  return {
    notify: (to: string, body: string): void => { recorded.push({ to, body }); },
    calls: (): ReadonlyArray<NotifyCall> => [...recorded],
  };
};

// Test
const sensing = createSensingNotifier();
processOrder(testOrder, { notify: sensing.notify });
expect(sensing.calls()).toEqual([
  { to: 'customer@example.com', body: expect.stringContaining('Order confirmed') },
]);
```

A sensing stand-in is still a hand-written fake — it belongs at the seam, not
in place of one.
