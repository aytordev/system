# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/event-sourcing/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (decider division of labour, command handler loop,
event store port, events-as-data, projections, testing stance, snapshots,
anti-patterns, checklist) and all nine of its `resources/` documents: the
adoption decision framework, event modelling and EventStorming, the Decider
and rehydration deep dive, the event store and Postgres schema, projections
and read models, event versioning, testing, production concerns, and the
bundled source notes. Every upstream normative rule, guard, and example is
preserved; the upstream `SKILL.md` account example now lives intact across
`SKILL.md` (abstract) and the `rules/` files where its fragments carry rules.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (event modelling, Decider and
  rehydration, anti-pattern catalogue), with the nine upstream `resources/`
  documents moved to `references/` — the directory name this repository's
  contract supports. `resources/references.md` was renamed
  `references/source-notes.md`.
- Converted upstream cross-skill routing (`domain-driven-design`,
  `hexagonal-architecture`, `typescript-strict`, `functional`, `testing`,
  `mutation-testing`) into bounded local notes: each rule is restated inline
  (pure Decider, driven port, schema-first at trust boundaries, explicit time
  and ids, behaviour-driven testing through the public API, mutation
  awareness) and the companions are named only as optional, so this folder
  works alone.
- Upstream references between resource documents were re-pointed at the local
  `rules/` and `references/` paths.
- Added the explicit Output Contract (scope, invariants, versioning strategy,
  test evidence).
- No `assets/` directory exists upstream and none was created. No executable
  code or scripts were shipped upstream (SQL and TypeScript snippets are
  illustrative examples inside prose, kept as such); nothing was dropped for
  that reason.

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
