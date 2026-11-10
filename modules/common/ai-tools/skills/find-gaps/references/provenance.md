# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/find-gaps/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document (about 340 lines): the silence-is-a-red-flag principle,
the gap-closing conversational loop, triage classes, the plan/AC/mock survey
checklists, the three conversion patterns with worked examples, the free-text
vs structured-input judgment, the anti-pattern list, and the quick-reference
table.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files: `gap-checklists.md` (survey checklists
  and quick reference), `conversion-patterns.md` (answer → criterion / plan
  update / mock state spec, with the upstream worked examples), and
  `questioning-discipline.md` (cadence, structured-input judgment,
  anti-patterns).
- Replaced upstream cross-skill references (`storyboard`, `story-splitting`,
  `grill-me`, `specification`, `acceptance-review`, `planning`,
  `characterisation-tests`, `testing`) with bounded local notes: the
  needs-an-artifact boundary, the splitting route, and the test-first
  behaviour note are restated inline; companions are named only as optional.
- Generalized the mock-state example's "reuse `EmptyIllustration` from
  impeccable tokens" to "reuse an existing illustration token if present" so
  the folder works alone.
- Kept the host-neutral structured-input framing of the upstream text
  (inspect the host's schema; no provider-specific tool names).

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
