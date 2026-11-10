# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/characterisation-tests/` |
| Imported revision | `63a85bef3505f3446ec5c9421fcd84a4bf57dad8` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document plus two resources: the Feathers concept, when to use and avoid, the placeholder-and-run algorithm, naming and lifecycle, suspicious-behaviour markers, async handling, the stop heuristic, and the temporary-strategy commitment.

## What changed locally

- Split into `SKILL.md` (concept, activation, hard rules, algorithm, stop heuristic, bug policy, lifecycle) and two `rules/` files (naming and lifecycle, algorithm and tooling).
- Not carried over: the separate deep-dive resources on tooling and the long worked example. The rule keeps the decisions an agent must make — placeholders, snapshots, async, seams, stop condition — without the tutorial walkthrough.
- Replaced sibling skill references (`tdd`, `testing`, `mutation-testing`, seam-finding) with bounded local notes so the folder works alone.

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
