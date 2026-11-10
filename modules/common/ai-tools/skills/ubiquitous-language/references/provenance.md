# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/ubiquitous-language/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` plus its two `resources/` documents: the five-step
language protocol (detect, propose, decide, record, rename) with the worked
`abandonCheckout` example, and the glossary format/bootstrap guidance. The
upstream "Where the Language Lives" model, mechanical-enforcement section,
adoption spectrum, boundaries table, and verification checklist are all
preserved.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and three `rules/` files (language protocol, mechanical
  enforcement, where the language lives and boundaries), with the two upstream
  `resources/` documents moved to `references/` — the directory name this
  repository's contract supports (`glossary-format.md` from
  `resources/glossary-format.md`).
- Converted upstream cross-skill routing (`domain-driven-design`,
  `hexagonal-architecture`, `structure-codebase`, `api-design`) into bounded
  local notes: each rule is restated inline (published-boundary renames are
  contract changes governed by additive-evolution/deprecation rules; context
  mapping and structural policy stay out of a vocabulary lint) and the
  companions are named only as optional, so this folder works alone.
- Added the explicit Output Contract (decision per term, where recorded,
  honest enforcement status) — the upstream stated it inside prose and the
  checklist.
- No `assets/` directory exists upstream and none was created. No executable
  code was shipped upstream; nothing was dropped for that reason.

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
