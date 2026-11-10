# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detailed guidance lives
in `rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/typescript-strict/SKILL.md` |
| Imported revision | `63a85bef3505f3446ec5c9421fcd84a4bf57dad8` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream file is one document. Its substance is preserved here:

- Boundary typing with `unknown`, contained `any`, and assertion discipline.
- `type` versus `interface` semantics.
- One owner per value set, including schema-derived types.
- Branded primitives conferred by validating constructors.
- Schema-first validation at trust boundaries, and the cases where a schema is
  noise.
- Strict compiler baseline, additional project checks, and the flags to assess.

## What changed locally

- Split into `rules/` (directives) and `references/` (provenance), with
  `SKILL.md` reduced to activation, hard rules, an index, and an output contract.
- Added host-capability reporting and an explicit boundary-first execution order.
- Replaced the upstream cross-reference to its companion `functional` skill with
  a bounded local note, because each folder in this collection must stay
  independently consumable.
- Named the upstream library examples generically where the choice is the target
  repository's.

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
