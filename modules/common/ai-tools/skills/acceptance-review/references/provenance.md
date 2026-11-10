# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/acceptance-review/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Adam Bulmer (directory carries a nested MIT `LICENSE`; itself adapted from Mintuz's `acceptance-review` at `976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324`, https://github.com/mintuz/skills) |
| License | MIT (nested `claude/.claude/skills/acceptance-review/LICENSE`; the repository `LICENSE` covers the rest) |

## What was imported

One upstream skill document plus its source notes: the acceptance-contract
model, criterion mapping, the three evidence lanes, untrusted-evidence rules,
trace/exercise steps, the criterion status table, verdict derivation, report
shape, and the read-only and historical-authority boundaries.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output
  contract) and three `rules/` files (contract building, evidence and
  verification, verdict and report).
- Folded the upstream source-notes reference into this provenance document: the
  upstream attribution to Mintuz's skill, the RFC 8174 normative-language note,
  and the Cucumber BDD compatibility note are retained above and in the local
  rules rather than as a separate bundled file.
- Replaced upstream cross-skill references (`find-gaps`, `double-check`,
  `testing`, `tdd`) with bounded local notes: artifact-improvement and
  independent-review boundaries are restated inline, and the test-first
  hand-off rule is restated with companions as optional.
- Removed the client-specific agents descriptor; the runtime contract is
  host-neutral.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## MIT notice

```text
MIT License

Copyright (c) 2025 Adam Bulmer

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

This license applies to the adapted portions of this directory derived from
Mintuz's `acceptance-review` skill at:
https://github.com/mintuz/skills/tree/976d4a0ccda4fc8468ffd2e96e0c6f7db5f42324/src/core/skills/acceptance-review
```
