---
name: aytordev-interface-design
description: "Apply the consuming project's design system to screens and flows with justified proposals and read-only, evidence-based interface review. Use when designing or revising a screen, flow, or component, or when reviewing interface work for layout, typography, color, accessibility, motion, icons, or copy. Triggers on interface design, screen layout, design proposal, design review, accessibility conflict."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Interface design for the consuming project

Design interfaces by reusing the project's existing system, not by importing a
taste. Upstream design knowledge (see `references/provenance.md`) supplies
principles; the project's tokens, components, and conventions supply decisions.
Propose changes in the project's own idiom, and treat accessibility floors from
WAI/WCAG 2.2 as authority over both upstream advice and project taste.

## Operating contract

| Aspect | Contract |
| --- | --- |
| Inputs | The screen, flow, or component in scope; the project's styling system, tokens, and components; any stated product constraints. |
| Outputs | A justified design proposal, or an evidence-based review report; implementation edits only when separately requested. |
| Stop and ask | When missing context materially changes the result (target users, platform, supported viewports, brand constraints) or when a request requires inventing product requirements. State the specific question; do not guess. |
| Stop and report | When a task needs capabilities this skill does not describe (design-system token definition, `.pen` canvas operations, product-ops tooling). Name the concern; do not improvise. |

Load a reference only when its concern is in scope; every reference resolves
inside this folder and no sibling skill, host tool, framework, or platform is
required.

## Non-negotiables

1. **Reuse the system.** Express every proposal with the project's existing
   tokens, components, and styling approach. Never introduce a second styling
   system, fixed product values, or vendored assets for an isolated fix.
2. **WAI/WCAG 2.2 floors outrank taste.** Normal text needs 4.5:1 contrast
   (large text 18pt/24px, or 14pt bold at exactly 18 2/3px, needs 3:1);
   pointer targets need
   24x24 CSS px or a stated exception; content reflows at 320 CSS px width
   without zoom loss. Details: `references/color-and-accessibility.md`.
3. **Escalate conflicts; never hide them.** When a project convention or token
   conflicts with an accessibility floor, name the conflict, cite the
   requirement, and propose the smallest scoped correction inside the project's
   system. Never silently redesign the product and never silently retain a
   defect.
4. **Review is read-only.** A review request produces findings and a verdict;
   edits happen only when the user also asks to implement. See
   `references/evidence-based-review.md`.

## References

| Concern | Reference |
| --- | --- |
| Layout and typography | `references/layout-and-typography.md` |
| Color and accessibility | `references/color-and-accessibility.md` |
| Motion and icons | `references/motion-and-icons.md` |
| Interface writing | `references/interface-writing.md` |
| Evidence-based review | `references/evidence-based-review.md` |
| Sources, licenses, corrections | `references/provenance.md` |

## Acceptance examples

| Example | Expected behavior |
| --- | --- |
| Read-only review | Reviewing a screen yields located findings, verification notes, and a verdict without modifying files. |
| System reuse | A spacing or color proposal names the project's existing token or component it uses, or explains why none fits and proposes the addition separately. |
| Conflict escalation | A project color pair below 4.5:1 is reported with the requirement, the measured pair, and a scoped correction proposal; it is neither silently kept nor silently redesigned. |
| Isolated loading | The folder works alone: all reference links resolve inside the folder, with no sibling-skill, host-tool, or platform requirement. |

These examples describe the instruction contract. Static repository checks
prove packaging, publication, and folder completeness only; the behavioral
examples are not executed model-behavior tests, and no runtime compliance is
claimed for them.

## Provenance

Principles are adapted from the pinned MIT-licensed Jakub Krehel skills corpus,
with recorded corrections and omissions. Pins, license notices, and the
correction rationale live in `references/provenance.md`; the original 49-file
PDS-1 audit was not recovered and is not claimed.
