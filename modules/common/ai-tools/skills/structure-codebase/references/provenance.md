# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/structure-codebase/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus its five resource documents: backend structure
grammars, frontend structure patterns, the visible-hexagon ports-and-adapters
target, enforcement and migration gates, and the attributed research notes.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (shape selection, proposal contract,
  cohesion and boundaries), with the five upstream deep-dive resources kept as
  `references/`.
- Removed `agents/openai.yaml` (client-specific agent metadata); its display
  role is covered by `SKILL.md` frontmatter and `metadata.json`.
- Converted upstream cross-skill routing (codebase-design,
  improve-codebase-architecture, reduce-system-complexity,
  evaluate-existing-solutions, hexagonal-architecture, domain-driven-design,
  bff-design, bff-entry-points, ubiquitous-language) into bounded local notes:
  each rule is restated inline in `SKILL.md`, `rules/`, or `references/`, and
  the published companions are named only as optional. Unpublished companions
  are described as separate concerns (API design, architecture audit,
  reduction evidence, domain modelling, BFF design, endpoint access
  classification) without skill names, so this folder works alone.
- Restated the endpoint access-classification/registrar rule from the upstream
  `bff-entry-points` dependency as a local rule in
  `rules/proposal-contract.md`.

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
