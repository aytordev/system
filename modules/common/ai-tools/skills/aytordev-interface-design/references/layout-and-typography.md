# Layout and Typography

Adapted from the pinned Krehel corpus; pins, license, and corrections:
`provenance.md`. Numeric values are starting points for projects without an
established density or spacing system; the project's own tokens win.

## Layout

- **Group with space, not lines.** Prefer negative space, then background
  shapes, then separators as a last resort. Keep gaps between groups at least
  2x the gaps within a group.
- **Keep controls visually distinct from static content**, and give static
  elements no control styling.
- **Align to shared edges.** A few consistent edges and one spacing step per
  hierarchy level read as structure; stray edges read as noise.
- **Use logical properties** (`margin-inline-start`, `inset-inline-start`,
  `text-align: start`) for direction-dependent layout so the design mirrors in
  RTL automatically; reserve physical sides for genuinely physical geometry.
- **Order by importance**: top and leading edge first; leading/trailing, not
  left/right.
- **Progressive disclosure needs a visible affordance**: a peeking item,
  disclosure control, or truncation cue for every hidden thing.
- **Content bleeds, controls float**: media reaches viewport edges; text and
  controls stay inside layout margins and safe areas.
- **Breakpoints come from the content**, not device presets; prefer container
  queries for component adaptation. Test the smallest and largest sizes first.
- **Plan for growth and clipping**: no fixed widths or heights on text
  containers; never park critical actions where resize or scroll clips them.

## Typography

- Serve `.woff2` on the web; prefer high-level properties (`font-weight`,
  `font-variant-numeric: tabular-nums`) over raw feature tags so non-variable
  fallbacks keep working.
- Few fonts, sizes, and weights; pair typefaces for contrast. Weights under
  300 are display-only.
- Use a small type scale with semantic names; heading sizes descend with
  heading level.
- Line-height by role: headings around 1.1; body 1.5-1.6; anything wrapping to
  three or more lines at least 1.4; prefer unitless values.
- **Cap the measure** of long-form text around 60-75 characters per line.
  `ch` is the advance measure of the `0` glyph in the element's font (MDN),
  not an average character count, so verify the rendered width per font
  instead of assuming one `ch` equals one generic character.
- Wrap deliberately: `text-wrap: balance` for short headings, `pretty` for
  descriptions, neither for long-form paragraphs.
- Apply `font-variant-numeric: tabular-nums` to values that change.
- Truncation hides content; keep the full value reachable when it matters.
- Store copy in natural case and control presentation with `text-transform`;
  use smart punctuation in prose.
- Keep input text at 16px on mobile viewports to avoid iOS focus zoom; never
  block zoom with `maximum-scale=1` or `user-scalable=no`.
