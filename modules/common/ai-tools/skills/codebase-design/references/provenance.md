# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/codebase-design/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Matt Pocock (original skill author, credited by the nested upstream LICENSE); imported via Paul Hammond's repository |
| License | MIT, Copyright (c) 2026 Matt Pocock — nested `claude/.claude/skills/codebase-design/LICENSE` overrides the repository's MIT notice for this directory |

The nested upstream notice also pins the original source: the adapted portions
derive from Matt Pocock's `codebase-design` skill at
`https://github.com/mattpocock/skills/tree/66898f60e8c744e269f8ce06c2b2b99ce7660d5f/skills/engineering/codebase-design`.
Concepts are further credited to John Ousterhout (deep modules, Design It
Twice) and Michael Feathers (seams); see `source-notes.md`.

## What was imported

The upstream `SKILL.md` plus its three reference documents: the Design It
Twice process, the deepening reference with dependency-fidelity questions and
seam strategies, and the attributed source notes. The nested upstream LICENSE.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and two `rules/` files (depth principles and vocabulary, contract
  workflow), with the three upstream reference documents kept as
  `references/`.
- Removed `agents/openai.yaml` (client-specific agent metadata); its display
  role is covered by `SKILL.md` frontmatter and `metadata.json`.
- Converted upstream cross-skill routing (structure-codebase, api-design,
  improve-codebase-architecture, reduce-system-complexity,
  evaluate-existing-solutions, render-code-shape, hexagonal-architecture,
  finding-seams, characterisation-tests, tdd, testing, refactoring,
  ubiquitous-language) into bounded local notes in
  `rules/contract-workflow.md`: each rule is restated inline and the published
  companions are named only as optional. Unpublished companions are described
  as separate concerns without skill names, so this folder works alone.
- Fixed the source-notes self-reference to the nested upstream `LICENSE` so it
  points at `provenance.md` inside this folder.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

## Licence notice

Verbatim copy of the upstream nested
`claude/.claude/skills/codebase-design/LICENSE`:

```text
MIT License

Copyright (c) 2026 Matt Pocock

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

This license applies to the adapted portions of this directory
(`claude/.claude/skills/codebase-design/`) derived from Matt Pocock's
`codebase-design` skill and linked resources at:
https://github.com/mattpocock/skills/tree/66898f60e8c744e269f8ce06c2b2b99ce7660d5f/skills/engineering/codebase-design
```
