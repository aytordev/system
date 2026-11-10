# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/domain-driven-design/` |
| Imported revision | `618665cb465edbead0b83befd9e96839a58b4dbe` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus four of its seven resource documents: aggregate
design, bounded contexts, domain events, and testing by layer. The source
list recorded in upstream `resources/references.md` (Evans, Vernon, Newman,
Khorikov, Chassaing, Khononov, Jemuović's Use Case Driven Design, and
property-based-testing references) was imported as attribution facts and is
recorded here rather than as a separate file.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and six `rules/` files (ubiquitous language, placement and purity,
  building blocks, aggregates, domain services and events, testing domain
  models), with the four upstream deep-dive resources kept as `references/`.
- Dropped upstream `resources/domain-services.md` and
  `resources/error-modeling.md`: their content substantially duplicates the
  `SKILL.md` sections and is preserved in `rules/domain-services-and-events.md`
  and `rules/building-blocks.md`.
- Dropped upstream `resources/references.md`; its source attribution is
  recorded in this document's "What was imported" section.
- Converted upstream cross-skill routing (hexagonal-architecture,
  structure-codebase, typescript-strict, event-sourcing, functional, testing,
  tdd, observability, refactoring) into bounded local notes: each rule is
  restated inline, the published companions are named only as optional, and
  unpublished concerns (ports-and-adapters placement, event sourcing,
  observability) are described without skill names, so this folder works
  alone.
- The ubiquitous-language guidance from upstream (glossary authority,
  alias translation, lint-scope honesty) is restated as a first-class rule
  file rather than a named external dependency.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

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
