# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/production-parity-skill-builder/` |
| Imported revision | `8f1ebbc67094ecfe47f49a474eeaf87becd8114f` |
| Upstream author | Paul Hammond |
| License | MIT (repository `LICENSE`; no nested notice for this path) |

## What was imported

The upstream `SKILL.md` in full: the inspect-before-asking workflow with its
source list and search terms, the parity map fields, the targeted-question
rules and example, the generated-skill contract (naming, project-local
storage decision tree, required sections, validation), the safeguard surface
list, the intentional-divergence register, and the output contract — plus all
three `resources/` documents: the parity surface catalog, the question
patterns, and the generated skill template.

## What changed locally

- Split into `SKILL.md` (activation, hard rules, execution steps, output
  contract) and five `rules/` files (inspection; parity map; targeted
  questions; generated-skill contract; safeguards and authorization), with
  the three upstream `resources/` documents carried over unchanged in
  substance as `references/`.
- Converted the upstream cross-skill routing through
  `evaluate-existing-solutions` into a bounded local note: the rule (state
  the known parity contract and constraints before comparing environment
  options) is restated inline and the companion is named only as optional,
  so this folder works alone.
- No `assets/` directory: the generated-skill template is reference material
  the agent reads and adapts, not a file the skill emits byte-for-byte, and
  upstream ships no other output artifact.

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
