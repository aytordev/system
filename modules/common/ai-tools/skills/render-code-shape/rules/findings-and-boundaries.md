---
title: Return Facts, Route Decisions
impact: HIGH
impactDescription: Keeps the render honest and its boundaries respected
tags: render-code-shape, findings, anti-patterns
---

## Return Facts, Route Decisions

**Impact: HIGH**

### Return the render

Lead with the entry points, the frame edge, and the wirings drawn. Then give the
types, the boundary table, the signatures, and the call graphs.

Close with what the shape shows, stated as facts already visible in the render
rather than as judgements: dependency cycles, a dependency pointing against the
module layering, argument counts, functions reached from many callers, boundary
crossings on the primary path, and paths no wiring covers. Name what stayed
unread and why.

Where a fact is a decision waiting to happen, name the owner of the decision
rather than making it here — a cycle or a leaking boundary is a design decision;
a path with no test wiring needs characterization or a minimal enabling seam; an
untraceable dependency is a placement decision.

When the render is a plan for work about to be done, save it under the
project's plans location beside the slice plan so the implementation can be
checked against it, and so a later reviewer can see which parts were `[NEW]` at
the time.

**Complete when:** every citation resolves, every observation points at an
element of the render, and every gap names what would close it.

### Anti-Patterns

- Rendering from memory or from a summary of the code instead of opening the
  files — the citation is the whole contract.
- Carrying a signature over from an older revision, or inferring one from a
  name, without reading it.
- Expanding every path to a leaf, producing a render nobody reads, when the
  question needed one entry point.
- Slipping below the waterline: statements, control-flow detail, and framework
  boilerplate reproduced as prose.
- Silently mixing `[NEW]` and existing names, so the reader cannot tell what is
  proposed from what is there.
- Drawing only the production wiring when a test or feature-flag composition
  root substitutes a dependency that changes the graph.
- Closing with judgments — "this is over-abstracted", "this should be split" —
  instead of the facts the render actually shows.
- Editing code during the render, or treating an approved render as approval to
  implement.
- Rendering a `[NEW]` shape and then implementing it straight through, skipping
  the failing behavior test the implementation workflow requires.

### Completion Check

- Does every name, type, and path in the render resolve to a file and line in
  the current tree, or carry `[NEW]`?
- Is the frame edge explicit, and is every wiring that substitutes a dependency
  drawn beside production?
- Does every path terminate on a boundary, a pure leaf, the frame edge, or an
  already-drawn function?
- Does every module row say what it *hides*, not just what it exposes?
- Is every non-plain call-graph edge annotated, and does every edge name the
  values crossing it?
- Are the closing observations facts visible in the render, with decisions
  routed to their owner?
- Did the render stay read-only, and is unread territory named rather than
  quietly omitted?
