# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/planning/` |
| Imported revision | `89225f6ecb4b702fdc6a21b35e0ba83526d692de` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document (`SKILL.md`): vertical-slice planning, the
story/plan/PR unit distinction, small-reviewable-PR and stack topology rules,
the walking-skeleton choice method, horizontal-work exceptions, the
known-good slice contract, the red-green-refactor slice cadence with the
end-of-phase mutation gate, commit-approval discipline, the file-backed plan
template, end-of-feature closeout, and the anti-pattern list.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files (vertical slices, known-good increments
  and reduction programs, delivery and review boundaries, implementation
  cadence and commit discipline), plus the plan template in
  `references/plan-template.md`.
- Restated upstream cross-skill routing as bounded local notes: story
  splitting is described inline as the prerequisite slicing activity;
  `stack-pull-requests` topology rules are restated in
  `rules/delivery-and-review.md`; the TDD/testing/refactoring and
  mutation-evidence cadence is restated in
  `rules/implementation-cadence.md`; `find-gaps`, `grill-me`,
  `evaluate-existing-solutions`, `reduce-system-complexity`, `expectations`,
  and `panel-review` mentions are reduced to inline statements or optional
  companion names. No dependency on an unpublished skill remains.
- Replaced Claude Code `/plan`/`/continue` references with tool-neutral
  wording: create or update the plan artifact directly and resume through the
  active harness or repository workflow.

No assets were imported: upstream ships no template or output artifact for
this skill.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path and revision above.

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
