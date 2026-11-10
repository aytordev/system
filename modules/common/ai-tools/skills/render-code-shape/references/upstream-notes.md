# Render Code Shape Source Notes

This skill is an attributed adaptation, not a verbatim copy. These notes preserve the upstream lineage and explain the decisions that differ from it.

## Upstream source

- Author: Adam Bulmer (`mintuz`)
- Repository: <https://github.com/mintuz/skills>
- Pinned revision reviewed: [`976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324`](https://github.com/mintuz/skills/tree/976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324)
- Original bundle: [`src/core/skills/pseudocode/`](https://github.com/mintuz/skills/tree/976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324/src/core/skills/pseudocode)
- License: MIT, Copyright (c) 2025 Adam Bulmer. The complete notice, including the rider scoping it to the adapted portions, is preserved in `provenance.md` beside this file.

The upstream `SKILL.md` links no additional documents and ships no companion files at this revision; the repository license was inspected directly.

## Retained concepts

- The **waterline** metaphor: the shape sits above it, syntax and statement-level bodies below.
- Only bodies are pseudo — every name, type, and path is read from source and cited, or marked `[NEW]`.
- The five-step workflow: frame the render, read the parts, render the shape, render the call graph, return the render.
- **Wirings** — production plus any composition root that substitutes a dependency (tests, local dev, feature flags) — each drawn separately.
- The four path-termination conditions: a boundary crossing, a pure leaf, the frame edge, or an already-recorded function.
- The above/below-the-waterline cut table, including "an effect that leaves the process" as the boundary test.
- The three-part shape render: types crossing boundaries, a module boundary table stating what each module hides, and signatures grouped by module.
- The indented call-graph format, the `→ Receiver.method(arg: Type) : Return` edge notation, and the annotation vocabulary (`[if …]`, `[each …]`, `[async]`, `[error …]`, `[boundary: …]`, `[NEW]`).
- `→ Name (above)` in place of a second expansion of an already-drawn function.
- Closing with observable facts rather than judgements, and naming what stayed unread.
- Saving the render when it is a plan for work about to be done.
- Read-only operation: the render is the deliverable, not the edit.

## Adaptation decisions carried into this package

- Renamed `pseudocode` to `render-code-shape`: "pseudocode" reads as throwaway sketching and under-triggers on the questions this skill actually answers ("how does this compose?", "what does this request touch?"). The description still names pseudocode explicitly so the original vocabulary keeps discovering it.
- Strengthened the read-only boundary: producing a render never authorizes changing production code, tests, or configuration, and implementation proceeds only under the governing behavior-change or behavior-preserving workflow.
- Added explicit non-ownership of judgement, routing each kind of finding to the decision process that owns it instead of deciding inside the render.
- Added a fabrication guard to the read step: a signature recalled from training data, inferred from a name, or carried over from an older revision is a fabrication even when it happens to be correct, because the citation is what makes it checkable.
- Added a proportionality rule to framing — prefer the narrowest frame that answers the question asked — since an unbounded render answers nothing.
- Bound naming to the project's own glossary rather than "the project's own language" generally.
- Related the `[NEW]` render to the delivery workflow: it is an input to a slice plan, never a substitute for it, and it is saved beside the plan so `[NEW]` status stays visible to later reviewers.
- Added an explicit anti-pattern catalog and a completion check.
