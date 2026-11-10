# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/graph-engineering/` |
| Imported revision | `bcfb33203eea2653f6e6aecac41f8583e38089fb` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

Five upstream documents: the skill (`SKILL.md` — terminology, activation
boundaries, the seven-step design protocol, guardrails, completion check) and
four references: node design (brief template, skill resolution, output
contracts, write-node handoff, verifier briefs, repair loop), topologies
(stage patterns, dependent-write graphs, scale), model policy (capability
tiers, provider mappings, runtime contract, execution ledger), and execution
(three runtimes, workflow-script authoring, run diagnosis).

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, guardrails,
  output contract) and four `rules/` files (node design, topologies,
  capability tiers, execution runtimes).
- Dropped the vendored dynamic-workflow JavaScript skeleton and its
  host-specific primitives from the upstream execution reference: the
  decisions it encoded (pure-literal metadata, phase-title agreement,
  deterministic code for resume, JSON run arguments, null-filtering with
  failure counts, pipeline default, journal diagnosis, resume-from-cache,
  explicit opt-in, and the integration/exclusion/approval semantics the
  runtime does not enforce) are restated as rules in
  `rules/execution-runtimes.md`. No script is vendored and no script path is
  referenced.
- Generalized the upstream provider model-mapping table (Claude and Codex
  model IDs, `agents/openai.yaml` notes) into a host-neutral rule: tiers and
  gates are policy; the model mapping is deployment data resolved from the
  host at run time.
- Generalized Claude Code-specific skill-resolution text (`Skill` tool,
  `~/.claude/skills`, CLAUDE.md injection) into host-neutral rules; the
  concrete fallback paths are kept as examples.
- Replaced upstream cross-skill references (`panel-review`, `double-check`)
  with bounded local notes: the PR-review instance and cross-provider second
  opinions are restated inline, companions only as optional.
- Removed the upstream `agents/openai.yaml` client descriptor.

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
