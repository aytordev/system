# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, directives live in
`rules/`, and worked examples live in `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/functional/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

- The core immutability mandate, including the explicit rule that a request to
  mutate in place still returns a new value.
- Functional Light guardrails and the purity / composition principles.
- Array-method selection, options objects, guard clauses, and Result values.
- Upstream resources: `immutability-catalog.md`, `composition-patterns.md`, and
  `effect-runtime.md`, now under `references/`.

## What changed locally

- Split into `rules/` (directives) and `references/` (worked detail), with
  `SKILL.md` reduced to activation, hard rules, an index, an output contract, and
  the reference table.
- Added host-capability reporting, execution steps, and an explicit output
  contract.
- Removed upstream cross-skill references (`tdd`, `codebase-design`,
  `characterisation-tests`, `observability`) because this repository publishes
  none of them; each folder must work when copied alone. Their substance is
  restated inline where it was load-bearing.
- Replaced an upstream link escaping the skill folder with project-agnostic
  guidance, and pointed the Effect outcome rule at the local rule file.
- Generalized version-specific Effect guidance so it does not assert a release
  that the target project may not use.
- Named the companion `typescript-strict` skill only as an optional cross
  reference; no dependency is declared.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream paths above.

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
