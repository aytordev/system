# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/twelve-factor/` |
| Imported revision | `bc59bd65ca710e0afe388069e552a6f688ae5c0d` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

Two upstream documents: the skill (`SKILL.md` — all twelve factors with rules,
anti-patterns, code-level implications, the brownfield adoption order, the
testing section, and the checklist) and the Node/TypeScript implementation
examples (`resources/node-patterns.md`).

## What changed locally

- Split into `SKILL.md` (activation, cross-cutting hard rules, execution steps,
  output contract, completion check) and four `rules/` files — config and build
  (Factors I, III, V), dependencies and services (Factors II, IV, X), processes
  (Factors VI, VII, VIII, IX, XII), and logs (Factor XI) — each keeping the
  upstream anti-pattern examples that carry the rule.
- Moved the upstream `resources/node-patterns.md` implementation examples to
  `references/node-patterns.md` (this contract has no `resources/` directory);
  content is unchanged apart from pointers retargeted from `../SKILL.md` to
  `SKILL.md` and `rules/logs.md`.
- Replaced upstream cross-skill references (`typescript-strict`, `testing`,
  `functional`, `hexagonal-architecture`, `observability`) with bounded local
  notes: schema-first validation, behavior-driven testing of config/shutdown/
  bindings, statelessness support, ports-and-adapters mapping, and the
  transport-versus-content split are restated inline, companions only as
  optional.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

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
