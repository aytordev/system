---
name: render-code-shape
description: "Trigger: asking how something composes, tracing what a request actually touches, pseudocoding a change before implementing it, onboarding to an unfamiliar path, or producing the shape a plan and its tests will be checked against. Renders module boundaries, the types that cross them, signatures, and a cited call graph; every name is read from source and cited or marked NEW, and the render is read-only — the deliverable, never the edit."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Render Code Shape

Code has a **waterline**. Above it sits the **shape**: modules and their
boundaries, the types and values that cross those boundaries, the signatures,
and the order calls actually happen in. Below it sits syntax and the statements
inside a body.

Render the shape and collapse everything below the waterline to a single line of
intent. Only bodies are pseudo — every name, type, and path is read from the
source and cited by file and line, or marked `[NEW]`. This is why the render is
trustworthy in a way a remembered summary is not.

**Read-only.** The render is the deliverable, not the edit. Producing a render
never authorizes changing production code, tests, or configuration. Implement
only if the request separately authorizes it, and then under the governing
workflow: failing-test-first for behavior change, behaviour-preserving
refactoring or reduction discipline for behavior-preserving work.

**A render is not a verdict.** It states what is visible in the render. Deciding
whether a boundary is well-drawn, where files should live, or which architecture
investments rank highest are separate decisions with their own owners; name the
owner instead of making the call here.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The question is "how does this compose?" or "what does this request touch?".
- A change is being shaped before it is implemented.
- A plan and its tests need a shape to be checked against.
- An unfamiliar path is being learned.

Do not use it to judge the shape, edit code, or replace a plan: a `[NEW]` render
is an input to a slice plan, never a substitute for one, and never a substitute
for the failing behavior test the implementation requires.

## Hard Rules

1. **Every name, type, and path is read from source and cited by file and line,
   or marked `[NEW]`.** A signature recalled from training data, inferred from a
   name, or carried over from an older revision is a fabrication even when it
   happens to be right — the citation is what makes the difference checkable.
2. **Prefer the narrowest frame that answers the question asked.** A render that
   expands to the whole repository answers nothing.
3. **Every path terminates** on a boundary crossing, a pure leaf, the frame
   edge, or a function already recorded — nowhere else.
4. **Only bodies are pseudo.** Statements, control-flow detail, and framework
   boilerplate stay below the waterline.
5. **Draw every wiring that differs from production** — any composition root
   that substitutes a dependency, such as tests, local dev, or a feature flag.
6. **Close with facts, not judgments.** Observations point at elements of the
   render; decisions route to their owner.
7. **Stay read-only.** Editing code during the render, or treating an approved
   render as approval to implement, violates the contract.

## Execution Steps

1. **FRAME** — name the entry points, the frame edge (the packages, services,
   and libraries that count as outside), and each wiring to render; classify
   each entry point `existing` or `[NEW]` (`rules/citation-contract.md`).
2. **READ** — follow every call from each entry point, opening each file; record
   file, line, signature as written, effects, and calls
   (`rules/citation-contract.md`).
3. **RENDER THE SHAPE** — types crossing boundaries, the module boundary table
   (what each module *hides*), and signatures grouped by module, each body
   collapsed to one line of intent (`rules/render-format.md`).
4. **RENDER THE CALL GRAPH** — one indented tree per wiring, every edge naming
   the values crossing it, every non-plain edge annotated
   (`rules/render-format.md`).
5. **RETURN** — lead with frame and wirings, then shape, then graphs, then the
   visible facts and the unread territory (`rules/findings-and-boundaries.md`).

Write in the project's own language and naming — the glossary term, not a
synonym. When the render is a plan for work about to be done, save it beside the
project's slice plan so `[NEW]` status stays visible to later reviewers.

## Output Contract

The render is the deliverable: entry points, frame edge, wirings, types,
boundary table, signatures, and per-wiring call graphs, closed with facts
already visible in the render (dependency cycles, a dependency pointing against
the module layering, argument counts, functions reached from many callers,
boundary crossings on the primary path, paths no wiring covers) and what stayed
unread. Every citation resolves; every gap names what would close it.

## References

- `rules/citation-contract.md` — read-only, citations, fabrication guard, framing, path termination.
- `rules/render-format.md` — the waterline cut, shape parts, call graph and annotations.
- `rules/findings-and-boundaries.md` — facts-not-verdicts, decision routing, anti-patterns, completion check.
- `references/upstream-notes.md` — the upstream adaptation notes for this skill's lineage.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When they are not installed, apply the rule
directly: boundary quality and cycle findings are design decisions, file
placement is a source-tree decision, ranked architecture investment is an
architecture-decision process, untestable dependencies need a minimal enabling
seam and characterized behaviour before change, and a render that is clearer
drawn than listed may become a diagram — each routed to the project's
corresponding process rather than decided inside this render.
