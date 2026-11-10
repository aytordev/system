# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/finding-seams/` |
| Imported revision | `63a85bef3505f3446ec5c9421fcd84a4bf57dad8` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus its three `resources/` deep-dive documents:
FP-first seam types, step-by-step seam-creation techniques with before/after
examples, and OOP seam patterns for legacy class-based code. Seam terminology
is credited to Michael Feathers, *Working Effectively with Legacy Code*
(2004), as the upstream text states.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and two `rules/` files (seam selection and smell-to-technique
  matching, common mistakes and sensing), with the three upstream deep-dive
  documents moved from `resources/` to `references/`, the directory name this
  repository's contract supports.
- Converted the upstream opening routing paragraph (characterisation-tests,
  tdd, testing, refactoring, codebase-design) and the hexagonal-architecture
  cross-reference into bounded local notes: each rule is restated inline and
  the companions are named only as optional, so this folder works alone.
- Added the hand-back requirements (seam type, enabling-point location, call
  sites unchanged, mocks removed) as the explicit output contract; the
  upstream stated them inside the workflow prose.
- Fixed the resource cross-references that pointed at "the main
  `finding-seams` skill" so they point at `SKILL.md` within this folder.

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
