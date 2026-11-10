# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/xstate/` |
| Imported revision | `08c3dae2b3dac766ed4dc839df163bcb5dbe3d80` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (default stance, before-you-write-state classification,
the ten rules that prevent most XState bugs, the diagram contract,
anti-patterns, completion check) and all six of its `references/` documents:
when to model, machine design, actors and systems, React integration, testing,
and TypeScript/versions with the full v4→v5 migration table.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) plus two extracted `rules/` files (before-you-write-state — the
  smell table, two lifetime tests, existing-owner override, and sweeping;
  render-the-diagram — the Mermaid render contract), with the six upstream
  `references/` documents carried over. The upstream completion check was
  distributed across the output contract, the rules files, and the reference
  checklists so no rule was lost in the split.
- Converted upstream cross-skill routing (`testing`, `react-testing`,
  `front-end-testing`, `typescript-strict`, `functional`, `event-sourcing`,
  `structure-codebase`, `diagrams`) into bounded local notes: each rule is
  restated inline (behaviour-driven tests through the public API with no
  module mocks, schema-parsed events at the door, immutable context, no domain
  event log in machine context, repository layer rules first, validated
  parser-safe diagrams) and the companions are named only as optional, so
  this folder works alone.
- Removed the upstream `agents/openai.yaml` client-adapter metadata
  (display name and default prompt for one specific client); it is not part
  of the portable skill contract.
- Added the explicit Output Contract (ownership verdicts, machine and diagram
  paths, honest validation result, test coverage).
- No `assets/` directory exists upstream and none was created. No executable
  code or scripts were shipped upstream; nothing was dropped for that reason.

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
