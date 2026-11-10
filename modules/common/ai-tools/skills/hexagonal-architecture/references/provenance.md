# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/hexagonal-architecture/` |
| Imported revision | `618665cb465edbead0b83befd9e96839a58b4dbe` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (opt-in gate, Before You Write Code, core concept,
ports/naming, adapters, CQRS-lite, dependency injection and composition root,
file organization, testing strategy, cross-cutting concerns, anti-patterns,
checklist) plus seven `resources/` documents: the full worked example, testing
patterns, CQRS-lite, cross-cutting concerns, incremental adoption, the
greenfield sequence, and the source-rationale notes (kept as
`references/sources.md`).

## What changed locally

- Split into `SKILL.md` (activation, condensed before-you-write-code, hard rules,
  execution steps, output contract) and five `rules/` files (before you write
  code, ports and naming, adapters and wiring, testing boundaries,
  anti-patterns), with the seven upstream resources kept as `references/`.
- Restated the physical-layout rules that upstream delegated to the
  `structure-codebase` skill, and named it and the domain-driven-design,
  finding-seams, event-sourcing, observability, and bff-entry-points companions
  as optional, because this folder must work alone.
- Replaced pointers to resources inside other skills with inline restatements:
  the aggregate-per-transaction rule, the in-memory probe-adapter test pattern,
  and property-based testing guidance. The unpublished `acceptance-testing`
  skill reference became an inline statement of the ATDD outer-loop rule.
- Renamed the upstream `resources/references.md` to `references/sources.md` so
  the folder keeps one `references/` namespace.

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
