# Provenance, Licenses, and Corrections

This skill adapts the operational-safety concepts of an upstream Pencil skill
rather than vendoring its recipes. The original 49-file PDS-1 audit was not
recovered; nothing here claims it.

## Adapted source (required notice)

The method is adapted from `skills/pencil-design/SKILL.md` in the
`pencil-skill` repository by Travis Polland (Nisus74), MIT License, pinned at
commit `28ec61cefe3000a59bdac6b98b83168dbacca9c8`
(https://github.com/Nisus74/pencil-skill). Re-fetched at the pin in September
2026 via read-only HTTP GET.

Adapted at the concept level only, generalized away from specific tools:

- Inspecting the running host and open document before any operation, and
  stopping with an explicit user-facing report when the host is unreachable or
  no document is open.
- Recording current state, selection, and identifiers before proposing changes.
- Bounded change batches sized for scanability, with verification between
  batches and structural readback as a debugging fallback.
- A failure-mode posture of stop-and-report instead of improvised fallbacks,
  and refusing to overwrite user-owned state (existing variables, components)
  that was not inspected first.

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

## Corrections and omissions

- **No fixed tool names, arguments, or schemas.** The pinned recipe names
  tools (`get_editor_state`, `batch_design`, `get_variables`, `batch_get`,
  `snapshot_layout`, `get_screenshot`, `export_nodes`, `export_html`,
  `get_guidelines`) and batch operations (`Insert`, `Update`, `Replace`,
  `Copy`, `Delete`, `Move`, `SetVariables`, `FindEmptySpace`, `Generate`).
  These are recorded here as history, never as executable authority.
- **Stale-recipe check against current docs (September 2026, read-only
  fetch).** The official pen.dev documentation then described a different
  top-level MCP surface (`get_style`, `read_skill`, `get_app_state`,
  `execute`, with conditional `browser` and `spawn_agents`), directed
  users to their client's live tool list for the installed version, and
  documented the CLI as `pen interactive` with a `pen interactive --help`
  reference. The pinned recipe and the then-current docs disagree on tool
  naming and structure; this skill therefore trusts only the schemas observed
  in the live session and treats every documented list as unverified for a
  given install.
- **No version compatibility claim.** Recorded local metadata (Pencil 1.2.0;
  Nix package label 1.1.63) does not match the rolling documentation, so no
  documentation statement is claimed to hold for the installed app.
- **No CLI, authentication, or provisioning material.** Upstream CLI usage,
  API keys (`PEN_CLI_KEY`, `ANTHROPIC_API_KEY`), login flows, and session
  token files are omitted. This skill never launches, authenticates to, or
  provisions the tool.
- **No aesthetics.** Upstream taste content (aesthetic-direction defaults,
  style catalogues, font-pairing and palette menus, anti-pattern lists, the
  self-critique gate, microcopy rules) is omitted: product aesthetics are not
  this skill's concern, and style authority stays with the project and the
  design-system owner.
- **No loading recipe duplication.** Manual Pen import and reload steps are
  recorded once in this folder's `inspection-and-editing.md` ("Manual skill
  loading"); this skill assumes no automatic discovery or registration of
  itself anywhere.
- **Sizing and chunking constants not universalized.** Upstream's specific
  caps (for example eight operations per call, five to fifteen screenshots)
  describe one workflow; this skill keeps the bounded-batch principle without
  those numbers.

## Relationship to sibling skills

The Jakub Krehel corpus (adapted by the interface-design skill) and the
design-system material (adapted by the design-system skill) were not adapted
here. This skill is standalone: no sibling skill, host tool, or shared
resource is required, and no skill loads another automatically.
