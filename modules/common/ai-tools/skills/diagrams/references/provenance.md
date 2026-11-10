# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/diagrams/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested `LICENSE` — the upstream `NOTICE` documents rights status and the historical-import remediation, summarised below and in `references/source-notes.md`) |

The imported revision was obtained from the GitHub commits API filtered by the
upstream content path (`per_page=1`); no fallback clone was needed.

## What was imported

The upstream `SKILL.md` (an independent 2026 rewrite: contract establishment,
destination-aware format selection table, model-before-styling, accessibility
without the renderer, real-output validation) and its
`references/source-notes.md`, which records the historical import, the
incomplete upstream licence evidence, and the current-tree remediation. No
`assets/` directory exists upstream.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract, format-selection table) and two `rules/` files (evidence and
  authority, accessibility and validation); each upstream section's
  "Complete when" gate is carried into the rules.
- Folded the upstream SKILL.md "Provenance" section into this file and kept
  the upstream source notes verbatim as `references/source-notes.md`.
- Added a bounded local companion note replacing a named tutoring-skill
  dependency: the rule (a diagram earns its place only when it carries
  meaning prose cannot) is restated inline.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## Upstream rights notice

The upstream `diagrams/NOTICE` at the imported revision reads:

```text
Current-tree rights status

The current `SKILL.md`, this notice, and `references/source-notes.md` are an
original rewrite covered by this repository's root MIT licence. No imported
diagram reference or example text remains in the current bundle.

Earlier commits and published releases contained substantial material derived
from `markdown-viewer/skills` without a complete upstream copyright and
permission notice. Removing that expression from the current tree does not cure
historical redistribution. See `references/source-notes.md` for the pinned
source, import history, evidence gap, and follow-up.
```

This local bundle imports only the remediated current tree, so the MIT notice
below applies.

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
