# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/secure-oauth-oidc/` |
| Imported revision | `bc59bd65ca710e0afe388069e552a6f688ae5c0d` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` (OAuth-vs-OIDC rule, the bring-the-flow-to-baseline
mandate, security-profile establishment, the transaction ledger, all four RFC
9700 boundary sections, the OIDC identity layer, the three task paths, the
false-assurance list, and the delivery contract) and all five of its
`references/` documents: the RFC 9700 control catalog, OIDC validation, the
attack and test catalog, the review and delivery protocol, and the standards
map. Every upstream guard, refusal, validation rule, applicability trap, and
negative test is preserved verbatim or near-verbatim — this skill is
security-sensitive and nothing was softened or summarized away.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files (the four RFC 9700 boundary sections, the
  false-assurance refusal list, the security-profile checklist plus the
  transaction-ledger binding table, and the three task paths), with the five
  upstream `references/` documents carried over unchanged in substance.
- Converted the upstream `bff-entry-points` cross-skill reference into a
  bounded local note: the BFF/session rule is restated inline (tokens stay out
  of the browser and behind server-side sessions; browser-facing endpoints
  follow the repository's session/CSRF policy) and the companion is named only
  as optional, so this folder works alone.
- Added the explicit Activation Contract and the hard-rule framing (baseline
  mandate, no inherited exceptions, no reliance on memory for normative
  wording, fail-closed, telemetry redaction) — the upstream stated these as
  prose and task-path bullets; every original bullet is retained.
- Removed the upstream `agents/openai.yaml` client-adapter metadata
  (display name and default prompt for one specific client); it is not part
  of the portable skill contract.
- No `assets/` directory exists upstream and none was created. No executable
  code or scripts were shipped upstream (the repository search-term block in
  the review protocol is quoted prose, kept as such); nothing was dropped for
  that reason.

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
