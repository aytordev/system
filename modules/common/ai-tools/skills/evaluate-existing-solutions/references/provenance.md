# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/evaluate-existing-solutions/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

Four upstream documents: the skill (`SKILL.md` — activation depths, operating
contract, seven-step workflow, completion check), the evaluation-dimensions
reference (hard gates, qualitative comparison table, comparison rules), the
evidence-and-currentness reference (evidence hierarchy, minimum evidence
record, supply-chain safety, methodology sources), and the decision-template
asset (the decision-artifact skeleton).

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (evidence and currentness, evaluation
  dimensions, decision and ownership); the decision template stays in
  `assets/` because it is a real output artifact.
- Replaced upstream cross-skill references (`find-skills`, `specification`,
  `grill-me`, `expectations`, `technical-writing`, `codebase-design`,
  `api-design`, `structure-codebase`, `reduce-system-complexity`, `planning`,
  `tdd`, `testing`, `refactoring`, `mutation-testing`, `double-check`) with
  bounded local notes: each routed discipline is restated inline and companion
  skills are named only as optional.
- Generalized the ambiguity rule ("return to `specification` / `grill-me`")
  into "resolve it first — ask one focused question at a time".
- Renamed the template's "Implementation skills/plan" row to "Implementation
  plan and disciplines" so the asset stays host- and skill-neutral.

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
