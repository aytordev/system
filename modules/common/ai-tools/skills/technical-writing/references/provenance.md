# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/technical-writing/` |
| Imported revision | `315ab6fc9a74794cd6b12964b70d036b53947681` |
| Upstream author | Paul Hammond (skill adaptation); formatting seed content by Adam Bulmer |
| License | MIT (nested `LICENSE` notice, copyright 2025 Adam Bulmer, copied verbatim below) |

## What was imported

The upstream `SKILL.md` in full (the skimmed-first contract, one primary
reader job, the principles, the receipts rule, docs-are-behavior verification,
the maintained-docs lifecycle, agent-readable documentation, document shapes,
the boundaries table, and the verification checklist) and all seven of its
`resources/` documents: doc types, READMEs, docs quality engineering,
agent-facing documentation, formatting, the source list, and the pinned-origin
source notes.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files (reader-first structure; claims need
  receipts; docs are behavior; agent-readable docs), with the seven upstream
  `resources/` documents carried over as `references/` (`references.md`
  renamed to `sources.md` to avoid colliding with the directory name).
- Converted upstream cross-skill references into bounded local notes so the
  folder works alone: sentence-level voice (clarity) and plain-English
  routing (simple-english) are restated inline without naming unpublished
  skills; diagrams and CLI-design boundaries are restated as inline rules.
  Published companions (`api-design`, `expectations`,
  `ubiquitous-language`) are named only as optional.
- Fixed two relative references that left the folder: `../LICENSE` pointers
  now route to `references/provenance.md`, which carries the notice verbatim.
- No `assets/` directory: upstream ships no output artifact, only
  documentation resources.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

## Licence notice (from the upstream nested LICENSE, copied verbatim)

```text
MIT License

Copyright (c) 2025 Adam Bulmer

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
