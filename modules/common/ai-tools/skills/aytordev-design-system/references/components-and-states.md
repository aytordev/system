# Components: anatomy, variants, and states

Read this when the task audits, extends, or documents the component library, or
when a component decision needs a new variant or state.

## Read a component before changing it

Inspect the component's anatomy in the project's own terms (source files,
stories, tests, or design-tool definitions):

1. **Structure**: its parts and slots — what the component accepts, what is
   configurable per instance, what is fixed.
2. **Variants**: the named axes it already ships (`variant`, `size`, `tone`)
   and which combinations are intentional versus accidental.
3. **States**: the interaction states it implements per axis — at minimum
   consider `default`, `hover`, `focus`, `pressed`, `disabled`, `loading`,
   `error`, `empty`, `skeleton`, and `success`; few components need all of
   them, and each state must be verified against the component, not assumed.
4. **Contracts**: its accessibility properties (roles, labels, focus behavior)
   and which semantic roles it consumes.

Record the anatomy as found before proposing changes; a proposal that cannot
name the current anatomy is a guess.

## State coverage rules

- **State coverage follows the component's contract, not a fixed checklist.**
  Report a missing state as a finding only where the component's actual
  interactive behavior or contract implies it, ranked by user impact (focus
  and error first), without silently redesigning; a static component may
  legitimately ship only its default state.
- **Disabled stays legible — usability, not conformance.** WCAG exempts text
  and non-text contrast for inactive components (SC 1.4.3, 1.4.11), so a
  muted disabled treatment is not a conformance defect; recommend keeping
  disabled text or boundaries perceivable as a usability improvement, not a
  floor. The exemption never waives contrast for active controls, and never
  justifies marking an operable control as disabled to sidestep it.
- **Focus is never removed without a replacement.** `outline: none` or an
  invisible ring is a defect to escalate, not a style choice to inherit.
- **State changes keep layout stable.** Loading or error variants that change
  a component's dimensions force reflow; prefer dimension-preserving recipes.
- **Error is never color alone.** Errors pair color with an icon, text, or
  pattern; a red border alone fails WCAG 1.4.1.

## WCAG 2.2 floor applicability

The floors named in the skill entry apply only as their criteria define; do
not report an exemption as a conformance defect:

- **Text contrast (SC 1.4.3)**: 4.5:1 for normal text; 3:1 for large text —
  at least 18pt (24px), or bold at 14pt (exactly 18 2/3px). Text that is part
  of an inactive user interface component has no contrast requirement.
  Source: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- **Non-text contrast (SC 1.4.11)**: 3:1 applies to visual information
  required to identify active UI components and states, not to every
  boundary; a control identifiable through its content needs no contrasting
  hit-area border. Inactive components are exempt.
  Source: https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html
- **Target size (SC 2.5.8)**: 24x24 CSS px, with five named exceptions:
  spacing, inline, equivalent, user agent control, essential.
  Source: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- **Reflow (SC 1.4.10)**: 320 CSS px without two-dimensional scrolling,
  excepting content that requires two-dimensional layout for usage or
  meaning (e.g. data tables, maps, diagrams, video, toolbars kept in view).
  Source: https://www.w3.org/WAI/WCAG22/Understanding/reflow.html

An exemption never waives the same floor for active controls, and never
excuses marking an operable control as disabled to avoid it.

## Per-component accessibility commitments

When the project documents components, give each one a commitments record: the
states it ships, its keyboard and screen-reader behavior, and the WCAG
requirements it must meet. When a documented commitment conflicts with a WCAG
2.2 floor, escalate the conflict (cite the requirement, propose the smallest
correction); when the project has no documented target, propose one before
adding components rather than inventing requirements.
