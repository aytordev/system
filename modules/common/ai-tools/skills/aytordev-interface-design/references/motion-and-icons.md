# Motion and Icons

Adapted from the pinned Krehel corpus; pins, license, and corrections:
`provenance.md`. Match the project's established motion language and icon set;
these principles govern restraint and consistency, not a required library.

## Motion

- Use transitions for interactive state changes (interruptible mid-flight);
  reserve keyframe animations for staged sequences that run once.
- Never `transition: all`; name the exact properties. Use `will-change` only
  for compositor properties (`transform`, `opacity`, `filter`) and only for
  observed first-frame stutter.
- Motion is never the only feedback channel: every animated state change also
  needs a static cue (color, icon, label).
- No entrance animation on high-frequency interactions; their attention cost
  repeats on every trigger.
- Honor `prefers-reduced-motion` (see `color-and-accessibility.md`): wrap
  motion so it is opt-in, replace movement with opacity crossfades under the
  preference, and drop parallax and autoplay entirely.
- Keep exits subtle and softer than enters; stagger only infrequent entrances
  where sequence communicates hierarchy.

## Icons

- One SVG per glyph, recolored with `currentColor`; hover, selected, and
  disabled states come from CSS color and opacity, never separate assets.
- Outline variants are the default; fill marks the active state.
- Match icon stroke weight to adjacent text weight; keep one stroke weight per
  icon set and never mix icon libraries on one surface.
- Directional icons mirror in RTL; digits and bidirectional text inside them
  keep their reading order.
- Icon-only controls need accessible names; mark decorative icons
  `aria-hidden` (see `color-and-accessibility.md`).
