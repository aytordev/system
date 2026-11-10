# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/testing/` |
| Imported revision | `63a85bef3505f3446ec5c9421fcd84a4bf57dad8` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document: behaviour-over-implementation testing, the interface-per-claim table, factory rules with production-schema reuse, mutation-aware planning, coverage-theatre patterns, and affected-scope execution.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output contract) and five `rules/` files (interface, factories, mutation-aware planning, coverage theatre, execution scope).
- Removed the sibling path into the tdd package's watcher resource; the execution rule restates the scope preference order so this folder works alone.
- Named mutation-testing, test-design-review, frontend-testing, react-testing, and seam-finding companions as bounded local notes instead of upstream skill references.

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
