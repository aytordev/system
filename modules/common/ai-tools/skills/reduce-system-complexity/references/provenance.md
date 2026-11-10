# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/reduce-system-complexity/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Adam Bulmer (original `reducer` skill; adapted within citypaul's distribution by Paul Hammond) |
| License | MIT — nested `LICENSE` in the upstream directory overrides the repository licence; notice copied verbatim below |

## What was imported

Three upstream documents: the skill (`SKILL.md` — operating contract, the
six-step workflow from scope fixation through class-specific gates, report
requirements, completion check), the reduction evidence template
(`references/ledger-template.md`), and the source-notes reference documenting
the attribution to Adam Bulmer's `reducer` skill.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (conservation contract, mechanism
  accounting, reduction slices); the ledger template moved unchanged in
  substance to `references/ledger-template.md`.
- Removed upstream cross-skill references (`improve-codebase-architecture`,
  `codebase-design`, `structure-codebase`, `refactoring`, `functional`,
  `characterisation-tests`, `finding-seams`, `testing`, `mutation-testing`,
  `tdd`, `planning`, `evaluate-existing-solutions`) and the relative link to
  `../functional/resources/effect-runtime.md`: each rule is restated inline and
  the companion is mentioned only as optional, so the folder works alone. The
  mixed-runtime rule now states the inventory requirement without the external
  Effect reference.
- Generalized host-specific workflow narration into the rules; no executable
  script was vendored (none shipped beyond prose workflow steps).

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## MIT notice (nested upstream `LICENSE`, copied verbatim)

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
(`claude/.claude/skills/reduce-system-complexity/`) derived from Adam
Bulmer's `reducer` skill at:
https://github.com/mintuz/skills/tree/d698a88fc1e4d054a25e5919f15658f673f602cb/plugins/core/skills/reducer
```
