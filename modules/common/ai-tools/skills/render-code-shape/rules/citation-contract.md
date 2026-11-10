---
title: Cite or Mark NEW — Never Render From Memory
impact: CRITICAL
impactDescription: The citation is the whole contract
tags: render-code-shape, citation, read-only, framing
---

## Cite or Mark NEW — Never Render From Memory

**Impact: CRITICAL**

### Read-only

Producing a render never authorizes changing production code, tests, or
configuration. Implement only if the request separately authorizes it, and then
under the governing workflow: failing-test-first for behavior change;
behaviour-preserving refactoring or reduction discipline for
behavior-preserving work. Rendering a `[NEW]` shape and then implementing it
straight through skips the failing behavior test the workflow requires.

### Frame the render

Name the **entry points** to trace from and the **frame edge** — the packages,
services, and libraries that count as outside. Name each **wiring** to render:
production, plus any composition root that substitutes a dependency, such as
tests, local dev, or a feature flag.

Classify each entry point `existing` or `[NEW]`. For a `[NEW]` render, resolve
the requirement it must satisfy and the existing code it attaches to.

Prefer the narrowest frame that answers the question asked. A render that
expands to the whole repository answers nothing.

**Complete when:** the entry points, the frame edge, every wiring, and the
existing/`[NEW]` split are each explicit.

### Read the parts

Follow every call from each entry point, opening each file on the path. For
every function reached, record its file and line, its signature as written, the
effects it causes, and the calls it makes.

Expand a path until it reaches a boundary crossing, a pure leaf, the frame edge,
or a function already recorded. A path ends nowhere else.

For a `[NEW]` render, read the surrounding modules the change attaches to with
the same rigour; parts that do not exist yet are derived from the requirement
and marked.

Read the source. A signature recalled from training data, inferred from a name,
or carried over from an older revision is a fabrication even when it happens to
be right — and the citation is what makes the difference checkable.

**Complete when:** every path terminates on one of those four conditions, and
every name that will appear in the render is either recorded with a file and
line or marked `[NEW]`.
