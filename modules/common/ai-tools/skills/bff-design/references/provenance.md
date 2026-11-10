# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/bff-design/` |
| Imported revision | `fb59fa34f43401e1fc4fcefd360e64aa3449ea08` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus its four reference documents: adoption and
granularity, aggregation and resilience, upstream identity, and the
alternatives comparison. Sources named inside those references (Newman,
Calçado, SoundCloud, Azure Architecture Center, IETF browser-based-apps draft,
Netflix, Leitner, Mezzalira, RFCs) were imported with the documents.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (adoption and ownership, shape don't
  decide, public-API drift), with the four upstream deep-dive references kept.
- Removed `agents/openai.yaml` (client-specific agent metadata); its display
  role is covered by `SKILL.md` frontmatter and `metadata.json`.
- Converted upstream cross-skill routing (bff-entry-points, hexagonal-
  architecture, api-design, structure-codebase, secure-oauth-oidc,
  event-sourcing, observability, front-end-testing) into bounded local notes:
  each rule is restated inline in `SKILL.md` or `rules/`, the published
  companions (structure-codebase, front-end-testing) are named only as
  optional, and unpublished concerns (entry-point protection, external API
  contract design, OAuth/OIDC protocol workflow, event sourcing,
  observability) are described without skill names, so this folder works
  alone.
- The "Test the degraded renders" and retry/idempotency cross-references are
  restated as inline rules pointing at this skill's own concerns.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

## MIT notice

```text
MIT License

Copyright (c) 2024 Paul Hammond

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
