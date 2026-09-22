# Provenance, Licenses, and Corrections

This skill adapts upstream design-system knowledge rather than vendoring it.
The original 49-file PDS-1 audit was not recovered; nothing here claims it.

## Adapted source (required notice)

The method is adapted from the `pencil-skill` design-system material by Travis
Polland (Nisus74), MIT License, pinned at commit
`28ec61cefe3000a59bdac6b98b83168dbacca9c8`
(https://github.com/Nisus74/pencil-skill). Adapted files:
`skills/pencil-design/design-system/README.md`,
`skills/pencil-design/design-system/CUSTOMISING.md`,
`skills/pencil-design/design-system/accessibility.md`,
`skills/pencil-design/design-system/file-architecture.md`,
`skills/pencil-design/references/component-anatomy.md`,
`skills/pencil-design/references/states.md`. Re-fetched at the pin in
September 2026 via read-only HTTP GET.

Adapted at the concept level only: progressive, decision-shaped documentation;
the token primitives-versus-roles model; component anatomy inspection
(structure, slots, variants); the interaction-state vocabulary and
state-coverage rules; per-component accessibility commitments; and the
source-of-truth/status-taxonomy idea, generalized away from `.pen` files.

> MIT License
>
> Copyright (c) 2026 Travis Polland
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

## Authoritative references

- WAI/WCAG 2.2 Contrast Minimum, Target Size (Minimum), Reflow
  (https://www.w3.org/WAI/WCAG22/Understanding/); WCAG 1.4.1 Use of Color.

## Corrections and omissions

- **WCAG-first contrast** replaces the upstream APCA-first thresholds; WAI
  floors (4.5:1 normal text, 3:1 large text) are treated as authority.
- **Design-tool operations removed**: all Pencil-specific procedure (MCP tool
  calls, `batch_get`/`batch_design`, `.pen` file formats, canvas regions) is
  omitted; anatomy and states are expressed tool-agnostically.
- **Style catalogues not adapted**: upstream style families, palette recipes,
  and font-pairing menus are taste inventories; this skill records no brand
  values and no aesthetic mandates.
- **Product template scaffold not adapted**: upstream's project-file checklist
  becomes optional, project-shaped documentation; no fixed file set is imposed.
- **Accessibility targets not invented**: upstream's default compliance-level
  commitment is replaced by stop-and-ask when the project has none.
- **Omitted**: keyboard-shortcut specifics, empty-state copy recipes, and
  screen-level fault-state copy; product voice stays in the consuming project.

## Relationship to sibling skills

The Jakub Krehel corpus (adapted by the interface-design skill) was not adapted
here. This skill is standalone: no sibling skill, host tool, or shared resource
is required.
