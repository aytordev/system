# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/observability/` |
| Imported revision | `fd017e2008465b8ba4d95a0312c112150c836116` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (wide-event default and one-exit construction rule,
the pillars position, the OpenTelemetry substrate with semconv and context
propagation, the cardinality routing rule, the sampling ladder, SLI/SLO/error
budget discipline, symptom-based multiwindow multi-burn-rate alerting,
structured-logging content discipline, Effect logging, the four-tier
architecture placement, telemetry testing, the anti-pattern table, the
verification checklist, and the boundaries table) and all four of its
`resources/` documents: Node/TypeScript patterns, SLO/burn-rate worked
detail, telemetry testing patterns, and the source notes. Every upstream
guard — including the complete never-log boundary for secrets, tokens, and
personal data — is preserved verbatim or near-verbatim.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and seven `rules/` files (wide events; the OpenTelemetry baseline
  with cardinality and sampling; SLOs and alerting; logging content;
  telemetry hygiene; architecture placement; testing telemetry), with the
  upstream `resources/` documents carried over as `references/`.
- Converted upstream cross-skill references into bounded local notes so the
  folder works alone: log transport/shape (twelve-factor), CI failure
  diagnosis (ci-debugging), environment drift (production-parity-skill-
  builder), TDD/testing, and the Effect runtime material (functional) are
  restated inline and named only as optional companions.
- Removed references to skills this repository does not publish
  (hexagonal-architecture, core-web-vitals, performance, cli-design): their
  rules are restated inline, and the Domain Probe deep treatment is pointed
  to its original article instead.
- Dropped the upstream relative link to the functional skill's Effect runtime
  resource; the runtime-documentation pointer is restated inline.
- No `assets/` directory: upstream ships no output artifact, only
  documentation resources.

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
