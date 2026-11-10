---
title: Find Seams and Match Technique to Smell
impact: HIGH
impactDescription: Prevents seams everywhere or nowhere
tags: finding-seams, selection, technique
---

## Find Seams and Match Technique to Smell

**Impact: HIGH**

### How to find seams

Look for these in the code you need to test:

1. **Function parameters** — any parameter that could accept a different
   implementation
2. **Default parameter values** — `(resolve = fetchFromApi)` is already a seam
3. **Module imports** — anything imported can potentially be mocked (but
   prefer parameter injection)
4. **Configuration** — env vars, config files, feature flags
5. **React props and context** — components receive dependencies as props;
   context providers can be swapped in tests
6. **Hard-coded `new` or direct calls** — every direct dependency is a place
   where a seam *could* exist but doesn't yet

### Seam granularity

Not every function call needs a seam. Too many seams make code harder to
read; too few make it untestable.

**Create a seam when the dependency:**

- Reaches outside the process (network, filesystem, database, clock,
  randomness)
- Is slow, non-deterministic, or has side effects
- Belongs to a different bounded context or domain

**Don't create a seam for:**

- Pure utility functions (`map`, `filter`, string formatting, math)
- Functions in the same module that have no external effects
- Standard library operations that are fast and deterministic

**Rule of thumb:** If you can call it in a test without any setup or teardown,
it doesn't need a seam.

### Code smell → technique

| You see this in the code | Technique | Example |
|--------------------------|-----------|---------|
| `new Foo()` inside a function | Parameterize function | Pass the dependency as a parameter with a default |
| `process.env.X` read directly | Wrap global call | `(getEnv = () => process.env.X)` |
| `import { thing } from './heavy-lib'` used directly | Extract type + parameterize | Define a narrow `type`, pass as parameter |
| Multiple hard-coded deps in one function | Higher-order function factory | `createFn(deps) => (args) => result` |
| `SingletonClass.getInstance()` | Wrap global call | `(getSingleton = () => SingletonClass.getInstance())` |
| `Date.now()` / `Math.random()` | Wrap global call | `(now = Date.now)` as parameter |
| Class constructs its own collaborators | Parameterize constructor (OOP) | Accept via constructor, see `references/oop-patterns.md` |
| Can't change function signature yet | Module indirection (scaffolding) | Thin wrapper module + `vi.mock()`, migrate later |

### When to prefer each type

| Criterion | Function Parameter | Configuration | Module Mock | Object (OOP) |
|-----------|-------------------|---------------|-------------|-------------|
| Type safety | Full | Full | None | Full |
| Explicitness | Most explicit | Explicit | Implicit | Explicit |
| Test isolation | Natural | Natural | Requires cleanup | Natural |
| Production changes | May need refactoring | Usually exists | None | May need refactoring |
| Permanence | Permanent | Permanent | **Temporary only** | Permanent |
| Best for | **Default choice** | Infrastructure | Quick scaffolding | Legacy class code |
