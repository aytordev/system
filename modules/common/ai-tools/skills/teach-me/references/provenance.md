# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/teach-me/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

The imported revision was obtained from the GitHub commits API filtered by the
upstream content path (`per_page=1`); no fallback clone was needed.

## What was imported

The upstream `SKILL.md` plus five resource documents: the learning-science
reference (active recall, spaced repetition, interleaving, dual coding,
calibration), Bloom's-level assessment patterns with question templates,
course generation with the learning-plan/mission templates, session management
(resuming, spaced-repetition scheduling, progress tracking), and the HTML
lesson format with design principles and template. No `assets/` directory
exists upstream; HTML lessons are generated outputs described by
`references/html-lessons.md`, not shipped template files.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (session protocol, learner-does-the-
  thinking techniques, workspace and records), with the five upstream
  deep-dive resources kept as `references/`.
- Removed the cross-skill dependency on a `diagrams` package: the rule is
  restated inline (ASCII diagrams, tables, and structured layouts as the
  second cognitive channel) with a diagram-tooling skill named only as an
  optional companion. The generic "skill integration" guidance became a
  bounded local note about using an installed topic skill as source material.
- Distilled the long upstream body into hard rules that carry the
  non-negotiables (one workspace per topic, authorization before outside
  writes, evidence before mastery, fluency vs storage strength) so nothing
  depends on reading a resource file first.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

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
