# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and the upstream
relative delegation link is restated as a bounded local rule so the folder
works alone.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/folder-structure/` |
| Imported revision | `5f2d0602765f522ddc14b405885174d11320e4fb` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` in full: the deprecated compatibility-alias semantics
— retired screaming-architecture guidance, delegation to `structure-codebase`,
the prohibition on reproducing the former protected-`domain/` plus sibling
`use-cases/` convention, and the stop-and-ask behaviour when the sibling is
unavailable.

## What changed locally

- Added `Trigger:`-style activation frontmatter and a runtime body (activation
  contract, hard rules, execution steps, output contract) in this repository's
  authoring contract; upstream had only frontmatter plus a three-step list.
- Replaced the upstream relative link into the sibling `structure-codebase`
  skill with a named delegation rule, because a link leaving this folder
  would break the standalone-folder guarantee. The structure-codebase skill
  in this repository is the local canonical target.
- Preserved the upstream `disable-model-invocation` intent as an activation
  rule (activate only for the exact legacy name), since that frontmatter key
  is not part of this contract's frontmatter.
- Removed `agents/openai.yaml` (client-specific agent metadata); its display
  role is covered by `SKILL.md` frontmatter and `metadata.json`.
- Generalized the upstream "install from citypaul/.dotfiles" instruction to
  this repository's acquisition path, without inventing an unverified URL.

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
