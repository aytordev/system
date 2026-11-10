# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/storyboard/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

One upstream document (`SKILL.md`): the storyboard definition and purpose,
when to produce and refuse one, the gathered inputs, the nine required page
sections, style/token conformance rules, iframe sandboxing and CSP rules,
formatter-safety rules, convention integration (manifest links, plan
references, deletion), non-negotiables, anti-patterns, the invocation
sequence, and the quick reference.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and four `rules/` files: when to storyboard, page structure and
  style conventions, embedding and formatter safety, review lifecycle.
- Restated upstream companion-skill routing as bounded local notes. The
  external impeccable-family commands (`/critique`, `/polish`, `/adapt`,
  `/impeccable harden`, `/distill`) are replaced by the inline rule that
  every audit-checklist item names a design discipline that will actually
  run locally; the `critique` post-hoc reference is reduced to "audit the
  live surfaces directly". Mentions of story-splitting, planning, find-gaps,
  and expectations are restated inline and named only as optional
  companions; no dependency on an unpublished skill remains.
- Replaced the vendored quick-reference invocation tree with the execution
  steps and review sequence in `SKILL.md` and `rules/review-lifecycle.md`.

No assets were imported: upstream explicitly treats the storyboard as a
pattern rather than a template, and ships no template file; the storyboard
HTML is generated per scope.

No synchronization branch or automatic update policy exists. Updates are
manual comparisons against the upstream path and revision above.

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
