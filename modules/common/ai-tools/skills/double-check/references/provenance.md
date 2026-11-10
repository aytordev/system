# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/double-check/` |
| Imported revision | `89225f6ecb4b702fdc6a21b35e0ba83526d692de` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus two resource documents: reviewer capability
selection without vendor coupling, and the complete verifier brief template
(role, task, original scope, claim, work location, context, validation
evidence, scrutinize-hardest list, mandatory scope-fidelity checks, and the
response format with finding shape, dispositions, coverage, and verdicts).

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution order, output
  contract) and three `rules/` files (reviewer selection, scope fidelity,
  findings and verdicts), keeping both upstream resources as `references/`.
- Removed the named sibling skills (`acceptance-review`, `tdd`,
  `find-gaps`, `panel-review`, `refactoring`,
  `reduce-system-complexity`, `secure-oauth-oidc`-adjacent phase rules);
  each relationship is restated inline as a bounded local note — the
  pre-PR acceptance pass runs alongside and reports a separate verdict, the
  verify-finished-work-only placement, and the refactor-opportunity criteria —
  so this folder works alone.
- The phase guidance (acceptance pass for finished implementation, general
  second opinion for earlier-phase work) moved into the Activation Contract's
  companion note instead of referencing another skill.

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
