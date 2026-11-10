# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/story-splitting/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

Upstream itself attributes the method to Tim Ottinger's "Splitting Stories —
A Resource Listicle" and the linked story-splitting writing by Ottinger,
Wake, Kerievsky, Adzic, Killick, and others; see
`references/source-notes.md` for the full source map.

## What was imported

Three upstream files: the main `SKILL.md` (splitting goal, refinement
pipeline, core principles, INVEST quality bar, workflow, validation
checklist, red flags, output format), `resources/pattern-catalog.md`
(pattern-selection heuristic, capability slicing, SPIDR, Humanizing Work
patterns, feedback-oriented splits, Bill Wake's split families, deferrals,
Hamburger Method, splitting by testable requirements, first-version
patterns, mistakes, safety rules), and `resources/source-notes.md`
(source-by-source concept mapping and synthesis decisions).

## What changed locally

- Restructured into `SKILL.md` plus two `rules/` files (capability slicing
  principles; quality bar, validation, and output format) and moved both
  `resources/` files into `references/` (`pattern-catalog.md`,
  `source-notes.md`).
- Upstream's "How This Fits With Other Skills" routing became bounded local
  notes: splitting-before-planning and find-gaps-after-split are restated
  inline in `SKILL.md` and `rules/quality-and-output.md`; `grill-me` is
  reduced to the inline one-question-at-a-time fallback; storyboard and
  external design-command mentions are reduced to optional companion names;
  upstream's `acceptance-testing` companion mention is replaced by the
  inline statement that acceptance examples feed the team's own
  acceptance-testing practice. No dependency on an unpublished skill
  remains.
- Kept the upstream seven-dimension prompt table in `SKILL.md` and left the
  named-pattern detail on demand in `references/pattern-catalog.md`.

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
