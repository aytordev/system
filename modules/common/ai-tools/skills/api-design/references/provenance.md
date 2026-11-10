# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/api-design/` |
| Imported revision | `bc59bd65ca710e0afe388069e552a6f688ae5c0d` |
| Upstream author | Paul Hammond |
| License | MIT (c) 2025 Addy Osmani — nested `LICENSE` in the upstream directory overrides the repository notice; see the notice below |

## What was imported

The upstream `SKILL.md` plus its five resource documents: RFC 9457 problem
details, API evolution and deprecation, OWASP API security, JWT BCP security
(RFC 8725), and HTTP fundamentals (RFC 9205). The upstream directory carries
its own nested `LICENSE` naming Addy Osmani as the copyright holder for
portions adapted from his `api-and-interface-design` skill; that notice,
including its rider, is copied verbatim below and overrides the repository
MIT notice for this content.

Upstream's `resources/source-notes.md` records that the original Addy Osmani
import revision is unknown in citypaul's history, and pins the audited
Addy Osmani baseline at
`7676817c12a1317454ae3898a0c5c1eacf5dd3d5`
(https://github.com/addyosmani/agent-skills). That SHA is an audit baseline,
not a claimed import revision, and is not reproduced as a local file.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files (compatibility and evolution, errors and
  validation, idempotency and quotas, REST conventions and caching), with the
  five upstream deep-dive resources kept as `references/`.
- Removed upstream `resources/source-notes.md`; its audit facts (unknown
  original import revision, pinned Addy Osmani baseline) are recorded here.
- Converted upstream cross-skill routing (typescript-strict, functional,
  testing, secure-oauth-oidc, codebase-design, bff-design, bff-entry-points,
  observability) into bounded local notes: each rule is restated inline, the
  published companions are named only as optional, and unpublished concerns
  (OAuth/OIDC protocol workflow, module design, entry-point protection,
  observability) are described without skill names, so this folder works
  alone.
- Reworded the self-references inside `references/` files to point at the
  skill's own `SKILL.md` instead of the upstream skill name.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path above.

## MIT notice (nested upstream LICENSE, copied verbatim)

```text
MIT License

Copyright (c) 2025 Addy Osmani

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

---

This notice applies to portions of this directory adapted from Addy Osmani's
`api-and-interface-design` skill. The original upstream import revision is not
recorded in local history. For the pinned audit baseline, immutable source file,
license source, and local-change record, see `resources/source-notes.md`.
```
