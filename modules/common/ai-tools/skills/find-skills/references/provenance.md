# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/find-skills/` |
| Imported revision | `640a334d3f233e7569586ed5e7d2251aab212788` |
| Upstream author | Paul Hammond |
| License | MIT — nested upstream notice, copyright Vercel, Inc. |

Unlike the other packages adapted from this repository, `find-skills` ships
a nested `LICENSE` upstream, carrying the notice of the upstream-of-upstream
bundle (material adapted from vercel-labs/skills). That notice, including
its rider, is preserved verbatim below and in
`references/source-notes.md`; the real copyright holder is Vercel, Inc. and
the licence family is MIT.

## What was imported

Two upstream files: `SKILL.md` (ecosystem discovery, installed-skill
coordination, the Skills CLI and its pinned use, the four-step
find/recommend/install flow, the seven verification rules, category table,
search tips, and the no-results path) and `references/source-notes.md` (the
import history and licence evidence from vercel-labs/skills). Upstream also
ships a nested `LICENSE`, whose notice is preserved below rather than
vendored as a loose file.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and two `rules/` files: verification before recommending, and
  installation authorization.
- The upstream mention of `evaluate-existing-solutions` became an inline
  boundary statement and an optional companion note; the closing mention of
  a `skill-creator` scaffold workflow became the inline local-authoring
  alternative in `SKILL.md`. No dependency on an unpublished skill remains.
- The top-level `LICENSE` file was not vendored; its exact notice (with
  rider) lives here so the copyright holder stays visible. The upstream
  attribution blockquote was reworded to point at
  `references/source-notes.md` and this document.
- Kept the recommendation example with concrete wording but no fabricated
  package URL.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path and revision above.

## MIT notice (nested upstream file, copied verbatim)

```text
MIT License

Copyright (c) 2026 Vercel, Inc.

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

---

This exact notice was added upstream in commit
e173b8c88f2581cfdaa1b6767c6519a08155790e and is preserved for material
adapted from vercel-labs/skills. The older imported snapshot predated the full
notice; see references/source-notes.md for that distinction and immutable
source links.
```
