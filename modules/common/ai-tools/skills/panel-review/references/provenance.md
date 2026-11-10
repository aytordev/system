# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/panel-review/` |
| Imported revision | `bcfb33203eea2653f6e6aecac41f8583e38089fb` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

Four upstream documents: the skill (`SKILL.md` — invocation grammar, workflow,
report, boundaries, completion check), the lenses reference (built-in,
default, and conditional lens registry, lens brief, finding discipline), the
PR-readiness reference (change-path classification, mutation-evidence
freshness model, verification gate), and the workflow-template reference (the
dynamic-workflow script with findings/verdict schemas and agent-tool
fallback).

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (lens registry, PR readiness,
  verification and report).
- Folded the upstream workflow-template reference — a host-specific
  workflow-script tutorial — into `rules/verification-and-report.md`: the findings/verdict
  schemas, dedup key, multi-vote resolution, sequential degraded mode, budget
  discipline, and posting discipline are retained as rules; the executable
  script and its host-specific `resolveInvocation`/model-policy machinery were
  dropped.
- Removed the upstream dependency on the `graph-engineering` skill and its
  `../graph-engineering/references/*` links: the node/topology/runtime and
  model-policy decisions it supplied (isolated contexts, schema-shaped
  returns, requested-versus-applied model/effort/budget, runtime fallback
  order) are restated inline so the folder works alone.
- Replaced upstream cross-skill references (`tdd-guardian`, `ts-enforcer`,
  `refactor-scan`, `double-check`, `/code-review`, `stack-pull-requests`,
  `mutation-testing`) with bounded local notes: focused single-concern checks,
  independent second opinions, stack semantics, and once-per-boundary mutation
  evidence are restated inline, companions only as optional.
- Generalized the `/panel-review` slash-command grammar into target/modifier
  semantics described host-neutrally; kept the token meanings (wip, PR target,
  add/remove/only/thorough/post).
- Removed the client-specific agents descriptor.

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
