# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/tdd/` |
| Imported revision | `08c3dae2b3dac766ed4dc839df163bcb5dbe3d80` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document plus a Vitest watcher resource: the RED-GREEN-REFACTOR workflow, fast-feedback selection, watcher lifecycle and automation safety, monorepo affected scope, RED/GREEN/final evidence, and the end-of-phase mutation gate.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output contract) and two `rules/` files (feedback loop, evidence and gates).
- Dropped the Vitest version-specific backend detail and the separate watcher resource file; the rule states the preference order, the proof condition, and the lifecycle, which is what an agent must decide from.
- Named the testing, mutation-testing, refactoring, and review-pr-readiness companions as bounded local notes rather than upstream skill references, because this collection has no declared sibling dependencies.

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
