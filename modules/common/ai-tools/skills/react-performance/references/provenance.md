# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/react-performance/` |
| Imported revision | `08c3dae2b3dac766ed4dc839df163bcb5dbe3d80` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` in full: the two predictable failure modes
(optimizing the wrong thing; buying speed with mutation, casts, or deleted
tests), the catalogue-vs-plan distinction, the four-step measurement method
with completion criteria, the seven house rules, the anti-pattern list, and the
completion check.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (measurement method, house rules,
  anti-patterns).
- Rewrote the description to lead with user-observable triggers and the
  measurement-first contract, per the local frontmatter convention.
- Replaced the upstream table of external pinned catalogue skills
  (`vercel-react-best-practices`, `vercel-composition-patterns`,
  `next-best-practices`, `next-cache-components`, `core-web-vitals`,
  `performance`) and sibling skills (`react-testing`, `front-end-testing`,
  `xstate`, `functional`, `typescript-strict`, `tdd`, `expectations`,
  `reduce-system-complexity`) with inline restatements: catalogues are described
  generically as project-pinned rule collections, and every measurement-first
  rule that forbids optimizing or reshaping without evidence is kept verbatim in
  intent. Published companions are named as optional with their rules restated.
- Generalized the `tdd` reference to "the failing-test-first workflow" and the
  `functional`/`typescript-strict` references to the immutability and typing
  rules themselves, so the folder works alone.
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
