# Provenance, Licenses, and Corrections

This skill adapts upstream design knowledge rather than vendoring it. The
original 49-file PDS-1 audit was not recovered; nothing here claims it.

## Adapted source (required notice)

Principles are adapted from the Jakub Krehel skills corpus, MIT License,
pinned at commit `d01493b0a7b976a74bfcedc80c783d60c7995910`
(https://github.com/jakubkrehel/skills). Adapted files: `skills/better-layout`,
`skills/better-typography`, `skills/better-colors`,
`skills/better-accessibility`, `skills/better-writing`, `skills/better-ui`,
`skills/better-interface`, `skills/interface-review`. Re-fetched at pin in
September 2026.

> MIT License
>
> Copyright (c) 2026 Jakub Krehel
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

## Fetched, evaluated, not adapted

The Nisus74 `pencil-skill` corpus, MIT License (c) 2026 Travis Polland, pinned
at `28ec61cefe3000a59bdac6b98b83168dbacca9c8`, was re-fetched and evaluated.
Its content is Pencil-canvas tool procedure (MCP operations, `.pen` handling),
not interface-design principles, so nothing was adapted here; its license is
carried by the work that later adapts it.

## Authoritative references

- WAI/WCAG 2.2 Contrast Minimum, Target Size (Minimum), Reflow
  (https://www.w3.org/WAI/WCAG22/Understanding/).
- MDN CSS `font-smooth` (non-standard) and CSS `length` units (`ch`).

## Corrections and omissions

- **macOS font smoothing removed**: upstream mandated root-level
  `-webkit-font-smoothing`/`-moz-osx-font-smoothing`. MDN classifies these as
  non-standard; this skill treats smoothing as an optional, platform-specific
  project decision and mandates nothing.
- **`ch` corrected**: upstream presented `65ch` as measuring characters
  directly; per MDN, `ch` is the advance measure of the `0` glyph, so rendered
  width must be verified per font.
- **WCAG-first contrast reporting** replaces upstream's APCA-first thresholds.
- **Target-size exceptions restored** (five WAI exceptions).
- **Orchestration removed**: upstream review skills coordinate sibling skills,
  caps, and mode parsing; this skill is standalone, read-only, and names no
  sibling or host tools.
- **Omitted**: upstream framework recipes (Tailwind/Framer Motion specifics),
  fixed templates, vendored fonts, icons, transitions, and product values;
  product tokens stay in the consuming project.
