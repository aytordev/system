# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/react-testing/` |
| Imported revision | `08c3dae2b3dac766ed4dc839df163bcb5dbe3d80` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus one resource document: element-perception
querying, Vitest Browser Mode with `vitest-browser-react` (setup, component,
props, conditional rendering with MSW, hooks, context, forms, loading states,
error boundaries, portals, Suspense, RSC), React-specific anti-patterns
(`act`, internals, shallow rendering/child mocking, shared renders and
cleanup), and the `@testing-library/react` + jsdom legacy dialect.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output
  contract) and two `rules/` files (browser-mode patterns, component
  integrity), keeping the legacy dialect as `references/`.
- Removed the relative links into the front-end-testing, tdd, and testing
  packages; the general UI rules (queries, async, MSW, affected scope), the
  TDD loop, and factory fixtures are restated as bounded local notes so this
  folder works alone.
- Named the xstate and react-performance upstream mentions as bounded local
  notes (headless flow logic; behaviour tests stay green through performance
  changes) instead of sibling skill references.
- Reworded one pointer in the legacy reference from the upstream resource
  path to the general network-mocking rule.

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
