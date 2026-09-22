# Color and Accessibility

Adapted from the pinned Krehel corpus with WAI/WCAG 2.2 as the authority;
pins, license, and corrections: `provenance.md`.

## Color

- Reuse the project's semantic tokens and notation; do not introduce a second
  color representation (for example a new OKLCH ramp) for an isolated fix.
  Notation migration is a design-system decision, not a screen edit.
- Prefer one meaning per color: a token used outside its role is a finding.
  When an existing semantic role covers the use, reuse that role; propose a
  new role token only when none fits, and never borrow by value.
- Action hierarchy: where the project's components support the pattern, prefer
  a single primary action with a colored surface and neutral secondaries;
  follow the consuming project's component variants rather than fixed
  coloring. Recheck every foreground/background pair in light and dark
  appearances.

## Accessibility floors (WAI/WCAG 2.2)

- **Contrast (SC 1.4.3)**: normal text at least 4.5:1 against its rendered
  background; large-scale text (at least 18pt/24px, or 14pt bold, which is
  exactly 18 2/3px) at least 3:1. Ratios are thresholds and are not rounded:
  4.499:1 fails.
- **Target size (SC 2.5.8)**: pointer targets at least 24x24 CSS pixels,
  except for WAI's five named exceptions (spacing, equivalent control, inline,
  user-agent control, essential). Larger touch targets remain a usability
  goal, not an AA requirement.
- **Reflow (SC 1.4.10)**: content works at a width equivalent to 320 CSS
  pixels (400% zoom at 1280px) without two-dimensional scrolling, except for
  content that needs it for usage or meaning.
- **Native elements first**: real `<button>` and `<a href>` over ARIA
  re-creations; no ARIA is better than bad ARIA.
- **Visible focus**: style `:focus-visible`; never `outline: none` without a
  verified replacement that passes against every adjacent color.
- **Full keyboard paths**: every pointer interaction has a keyboard route;
  only `tabindex="0"` and `-1`; modals trap and restore focus.
- **Names and labels**: every control has an accessible name; placeholders are
  never labels; decorative elements are `aria-hidden`.
- **Errors announce**: `aria-invalid` plus inline error text plus focus on the
  first invalid field; keep submit enabled until the request starts.
- **Never color alone**: status carries a redundant cue.
- **Motion preference**: honor `prefers-reduced-motion`; autoplay is pausable.
- **Alt text by purpose**; headings and landmarks form a coherent outline.

## Conflict handling

When a project token or convention misses a floor above: state the conflict,
cite the requirement, report the measured pair or target, and propose the
smallest scoped correction expressed in the project's own system. Implement
only when authorized. Do not silently redesign the product, and do not
silently preserve the defect.

## Corrections applied to upstream

- Upstream color guidance reports APCA thresholds first; this skill reports
  WCAG 2.2 ratios first because WAI is the authority here.
- Upstream stated the target-size rule without its exceptions; the five WAI
  exceptions above are part of the requirement.
