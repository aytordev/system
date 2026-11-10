# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/wtf/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (nested upstream `LICENSE`; Copyright (c) 2025 Adam Bulmer) |

The imported revision was obtained from the GitHub commits API filtered by the
upstream content path (`per_page=1`); no fallback clone was needed.

## What was imported

The upstream `SKILL.md`: explicit-invocation re-explanation of the immediately
previous LLM response, repository-declared glossary lookup before conventional
glossary paths, ASD-STE100-inspired writing rules, clarity controls, and the
completion criterion. No `assets/` directory exists upstream.

Upstream attributes the underlying skill to Adam Bulmer's MIT-licensed Mintuz
`wtf` skill at pinned revision
`e436942ef328e692567300dba51424c68850ab12`
([pinned source](https://github.com/mintuz/skills/blob/e436942ef328e692567300dba51424c68850ab12/src/core/skills/wtf/SKILL.md),
[pinned licence](https://github.com/mintuz/skills/blob/e436942ef328e692567300dba51424c68850ab12/LICENSE));
the nested upstream `LICENSE` carries that MIT notice, quoted below.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and two `rules/` files (glossary authority, plain language).
- Promoted "never invoked implicitly" — upstream declares this with a
  `disable-model-invocation` frontmatter flag this contract does not carry —
  into the description and Activation Contract instead.
- Dropped the upstream client adapter `agents/openai.yaml`: it is client
  metadata, not an output artifact or instruction content, and this package
  must work alone across hosts. Its decisions (explicit display name, no
  implicit invocation, explicit default prompt) are restated as rules above.
- Restated the glossary procedure as a focused rule file; no other content
  was renamed or dropped.

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
```
