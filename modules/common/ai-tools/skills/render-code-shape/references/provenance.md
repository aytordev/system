# Provenance

This skill is an adaptation of an upstream Agent Skill that is itself an
attributed adaptation. The local contract differs: `SKILL.md` is a concise
runtime entry point, and detail lives in `rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/render-code-shape/` |
| Imported revision | `96cdd38632b4ef523aa7c445059d97e960de43ce` |
| Upstream author | Paul Hammond (adapting Adam Bulmer's `pseudocode` skill) |
| License | MIT — nested notice, Copyright (c) 2025 Adam Bulmer, with a rider scoping it to the adapted portions of this directory |

## What was imported

The upstream `SKILL.md` (waterline concept, read-only contract, five-step
workflow, shape render, call graph format with annotation vocabulary,
anti-patterns, completion check) and the upstream source-notes lineage document, kept as `references/upstream-notes.md`.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (citation contract, render format, findings
  and boundaries).
- Rewrote the description to lead with "Trigger:" per the local frontmatter
  convention while keeping the pseudocode vocabulary for discovery.
- Replaced upstream cross-skill routing (`codebase-design`,
  `structure-codebase`, `improve-codebase-architecture`, `finding-seams`,
  `characterisation-tests`, `diagrams`, `technical-writing`, `ubiquitous-language`,
  `tdd`, `refactoring`, `reduce-system-complexity`, `planning`) with inline
  restatements of each rule; published companions are described only as optional
  decision owners, and the unpublished `planning` skill became "the project's
  slice plan".
- Replaced the upstream notes' relative `../LICENSE` link, which leaves the
  folder, with an inline pointer to `provenance.md`, where the notice is
  preserved verbatim.
- Dropped the upstream `agents/openai.yaml` client interface metadata; it is
  client-specific and not part of the portable contract.
- No `assets/` directory: upstream ships no output artifact or template file at
  the imported revision.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## Licence notice

Nested notice from `claude/.claude/skills/render-code-shape/LICENSE`, copied
verbatim including its rider:

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

---

This license applies to the adapted portions of this directory
(`claude/.claude/skills/render-code-shape/`) derived from Adam
Bulmer's `pseudocode` skill at:
https://github.com/mintuz/skills/tree/976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324/src/core/skills/pseudocode
```
