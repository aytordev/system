# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/improve-codebase-architecture/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Matt Pocock (original skill and HTML report resource; adapted within citypaul's distribution by Paul Hammond) |
| License | MIT — nested `LICENSE` in the upstream directory overrides the repository licence; notice copied verbatim below |

## What was imported

Three upstream documents: the skill (`SKILL.md` — activation boundaries, the
eight-step audit workflow, candidate requirements, completion check), the HTML
report reference (output location, security and portability, information
architecture, candidate cards, diagram patterns, accessible visual system,
scaffold, quality check), and the source-notes reference documenting the
attribution to Matt Pocock's `improve-codebase-architecture` skill.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (scope and evidence, candidates and
  ranking, selection and routing); the HTML report reference moved to
  `references/html-report.md` with the scaffold and quality check retained.
- Removed upstream cross-skill references (`codebase-design`,
  `structure-codebase`, `reduce-system-complexity`, `refactoring`,
  `tdd`, `testing`, `mutation-testing`, `characterisation-tests`,
  `finding-seams`, `api-design`, `hexagonal-architecture`,
  `domain-driven-design`, `ubiquitous-language`, `evaluate-existing-solutions`,
  `planning`, `double-check`, `grill-me`): each rule is restated inline and the
  companion is mentioned only as optional, so the folder works alone.
- Generalized the upstream client-specific exploration guidance (fixed
  `Agent` tool, `grill-me` command) into host-neutral rules; the
  Design-It-Two-Passes process is restated in `rules/selection-and-routing.md`.
- Dropped the upstream `agents/openai.yaml` client descriptor and the
  upstream `source-notes.md` narration; the durable facts live here.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## MIT notice (nested upstream `LICENSE`, copied verbatim)

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
(`claude/.claude/skills/improve-codebase-architecture/`) derived from Matt
Pocock's `improve-codebase-architecture` skill and HTML report resource at:
https://github.com/mattpocock/skills/tree/66898f60e8c744e269f8ce06c2b2b99ce7660d5f/skills/engineering/improve-codebase-architecture
```
