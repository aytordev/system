---
name: page-structure
impact: CRITICAL
impactDescription: Required sections and style conventions
---

# Page Structure and Style Conventions

**Impact: CRITICAL**

A storyboard is a pattern, not a template. Every storyboard has the following
sections **in this order**; the content inside each is specific to the scope.

1. **Breadcrumb** — back-link to the parent index (mocks manifest, planning
   index, or equivalent).
2. **Header** — a small pill with the scope code in an uppercase-tracking
   style; a display title describing the scope; a one-sentence subhead naming
   the purpose; and a paragraph explaining the scope plus a link row to the
   item readme, design brief, and any relevant ADR.
3. **Flow diagram** — ASCII boxes and arrows in a `<pre>` element showing the
   user's journey. Colour-code inline: one colour for existing-mocked nodes,
   a distinct action colour for gaps, and a muted colour for adjacent context.
   Mark gaps with a scannable inline glyph such as a "GAP" label.
4. **Existing mocks (side-by-side)** — heading with a status badge; a
   responsive grid (typically three columns on desktop, one on mobile); one
   cell per mock containing a badge and filename header, the mock name, a
   1–2 sentence description, a sandboxed iframe at fixed height (780px works
   well for primary mocks, 640px for adjacent), or the labelled static
   fallback, an "open in new tab" link with `rel="noopener noreferrer"`, and
   an **audit checklist card** listing the design disciplines that will
   actually run on this mock plus any scope-specific questions
   ("discoverability of edit affordance?", "loading state mocked?").
5. **Transition / state gaps** — when something should be mocked but is not
   obvious (a post-action toast, a success confirmation), flag it as an
   "unclear" section with a bullet list of brainstorm questions. Better to
   surface ambiguity than let it slip.
6. **Gaps to fill** — heading with a "produce next" badge; a responsive grid,
   one cell per gap; visually distinct background or border using the
   project's action tint; each cell with badge and filename, display name,
   description, and **brainstorm questions** covering entry point(s), shape
   (sheet / dialog / page), field list, edge and error states, integration
   with existing patterns, destructive-action semantics, and cancel
   behaviour.
7. **Upstream / adjacent (for context)** — smaller iframes in a three-column
   grid, each labelled "not this scope, here for context", used for surfaces
   the user jumps into from or out of this scope.
8. **Proposed sequence** — ordered list from storyboard to code-lands:
   review and approve/flag; answer gap questions; produce gap mocks through
   the local design pipeline; apply fixes the audit flagged; save the
   reviewed mocks and audit note through the repository's authorized delivery
   workflow.
9. **Footer** — meta line: scope code, last-updated date, pair-read links.

## Style conformance

Use the project's existing design tokens and layout tooling — **do not invent
new ones**. If the project uses Tailwind, reuse its configured utilities; do
not emit Tailwind classes into a project that does not compile them. If no
local convention exists, use a small framework-neutral inline-CSS fallback:
map action, text, background, exists, gap, and uncertain roles to local
semantic tokens, defining only the minimum accessible colours the page needs.

- **Fonts:** reuse local body and heading stacks; never add a font dependency
  solely for the storyboard.
- **Badges:** use the project's semantic status colours, always with
  text/glyph labels so colour is never the only signal.
- **Iframe frame:** fixed height, border, rounded corners, light shadow,
  same visual weight across the grid.
- **Container:** use the local page-shell/container pattern; a fallback can
  use `max-width`, `margin-inline: auto`, and responsive padding.

Match the local codebase's existing mock or index-page style — copy the
`<style>` block from a sibling mock rather than re-inventing it.

## Anti-patterns

- Presenting a static mock as live evidence: label it non-interactive; it
  cannot prove scrolling, transitions, focus, or runtime states.
- A gap card whose brainstorm questions are "TODO": a gap without answered
  questions is a gap without the skill's value.
- Inventing bespoke design tokens: the storyboard must feel native to the
  project.
- A navigation tree instead of one scrollable page.
- `<div class="whitespace-pre">` for ASCII diagrams.
- Producing new mocks before the storyboard is reviewed: drafting first
  pre-commits to answers that may be wrong.
