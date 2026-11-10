# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/specification/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

Three upstream files: the main `SKILL.md` (specification-as-conversation
stance, the seven-part contract, the draft-then-accountable-review flow, the
review-page protocol, vocabulary capture, skill boundaries, and the
verification checklist), `resources/references.md` (the source notes for the
practices taught), and `resources/spec-review-template.html` (the review
handoff page template).

## What changed locally

- Restructured into `SKILL.md` plus two `rules/` files (example map;
  accountable review and vocabulary capture), moved the review template to
  `assets/spec-review-template.html`, and renamed the source notes to
  `references/concept-sources.md`.
- Upstream cross-skill routing became bounded local notes. Mentions of
  `grill-me`, `find-gaps`, `story-splitting`, `planning`,
  `evaluate-existing-solutions`, and `ubiquitous-language` are restated
  inline as inline rule statements or optional companion names. The
  reference to this collection's `acceptance-testing` companion was
  replaced, because the local collection does not publish that package:
  downstream acceptance testing is described as the team's own loop that
  consumes the stabilised map, not as a bundled skill. No dependency on an
  unpublished skill remains.
- Trailing-boundaries wording follows the local contract: refusals and
  handoffs are stated in `SKILL.md` instead of a table of sibling skills.

Assets imported: `assets/spec-review-template.html` is a real upstream
output artifact (the review page template), retained as the only asset.

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
