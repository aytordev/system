# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/front-end-testing/` |
| Imported revision | `08c3dae2b3dac766ed4dc839df163bcb5dbe3d80` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus four resource documents: behaviour-driven UI
testing philosophy, Vitest Browser Mode guidance (setup, locators,
`expect.element()` assertions, CDP user events, multi-project config,
gotchas), Playwright E2E evidence boundaries with the direct-transport audit
and auth/lifecycle contract, async testing patterns, MSW integration setup for
both environments, and the legacy DOM Testing Library/jsdom dialect.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output
  contract) and five `rules/` files (harness and claims, browser feedback,
  query priority, network mocking, evidence boundaries), with the four
  upstream deep-dive resources kept as `references/`.
- Folded the upstream summary checklist into the hard rules and output
  contract so nothing is checked only at merge time.
- Removed the relative link into the tdd package's watcher resource; the
  browser-feedback rule restates the affected-scope preference order so this
  folder works alone.
- Named the tdd, testing, react-testing, and finding-seams companions as
  bounded local notes rather than upstream skill references, because this
  collection has no declared sibling dependencies.
- Reworded the auth/lifecycle section so OAuth/OIDC and session-cookie policy
  design are described as separate concerns instead of named sibling skills,
  keeping the testing evidence contract intact.

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
