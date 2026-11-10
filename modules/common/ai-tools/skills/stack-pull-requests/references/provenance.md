# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/stack-pull-requests/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (three-units separation, independent-versus-stack
decision gates, counterfactuals, stack design, verification routing by boundary
type, CI topology checks, delivery plan template, build/review/merge workflow)
and the `references/source-notes.md` provenance document with the GitHub/Graphite
source map, reconciliation decisions, preview caveat, native `gh stack` command
model, and update procedure.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files (units and decision, stack design,
  verification and CI, build/review/merge), keeping the upstream examples and
  the delivery plan template intact.
- Replaced the upstream `story-splitting` and `planning` skill references with
  inline restatements of the vertical-splitting and delivery-plan rules, because
  this collection publishes no skills by those names and the folder must work
  alone.
- Named the tdd, testing, mutation-testing, finding-seams,
  characterisation-tests, reduce-system-complexity, and find-gaps companions as
  optional, with their governing rules restated inline.
- Generalized the upstream `mutation-testing` gate wording to the accumulated-
  or-alternate-evidence gate so the rule holds without a mutation harness.
- Dropped the upstream `agents/openai.yaml` client interface metadata; it is
  client-specific and not part of the portable contract.

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
