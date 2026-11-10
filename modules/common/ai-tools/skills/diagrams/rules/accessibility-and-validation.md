---
title: Make the Meaning Available Without the Renderer
impact: CRITICAL
impactDescription: Accessible diagrams and honest validation claims
tags: diagrams, accessibility, validation
---

## Make the Meaning Available Without the Renderer

**Impact: CRITICAL**

### Text alternatives

- Give the diagram a specific title and a concise text explanation of its main
  relationship or conclusion.
- Do not use colour as the only carrier of meaning.
- Keep labels legible; avoid decorative density.
- Provide a table or structured text alternative when exact values or complex
  relationships matter.

The step is complete when a reader can recover the essential meaning if
rendering, colour, or interaction is unavailable.

### Generated artifacts are not authority

Generated images and screenshots are review artifacts, not the maintained
authority. Keep editable source beside any rendered export and state how the
export is regenerated.

### Validate the real output

Validate with the repository's installed tool/version or the destination's
documented renderer. Rendering is stronger evidence than syntax inspection;
state which one was actually performed. Check:

- parse/render success and no clipped or overlapping labels;
- correct direction, cardinality, state transitions, legends, and units;
- links and referenced identifiers;
- text alternative and source-to-render regeneration;
- the diagram still answers its named question at the target viewport.

When no renderer is available, say so and keep to a portable supported subset.
Do not claim the diagram rendered from a syntax-only check. Automate
repeatable syntax and internal-reference checks where practical, with a
known-invalid positive control when introducing a new validator.

The step is complete when the actual artifact was rendered and inspected, or
the exact validation gap and portable fallback are explicit.
