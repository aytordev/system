# Provenance

This skill is an adaptation of an upstream Agent Skill. The local contract
differs: `SKILL.md` is a concise runtime entry point, and detail lives in
`rules/` and `references/`.

| Field | Value |
| --- | --- |
| Upstream repository | https://github.com/citypaul/.dotfiles |
| Upstream content path | `claude/.claude/skills/cli-design/` |
| Imported revision | `bc59bd65ca710e0afe388069e552a6f688ae5c0d` |
| Upstream author | Paul Hammond |
| License | CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike 4.0 International; nested upstream `LICENSE`) |

The imported revision was obtained from the GitHub commits API filtered by the
upstream content path (`per_page=1`); no fallback clone was needed.

## Licence

This upstream `cli-design` directory is published under **CC BY-SA 4.0**, not
the repository-root MIT license. It adapts *Command Line Interface
Guidelines* by **Aanand Prasad, Ben Firshman, Carl Tashian, and Eva Parish**
([clig.dev](https://clig.dev/), source
[`cli-guidelines/cli-guidelines`](https://github.com/cli-guidelines/cli-guidelines),
audited at pinned revision
[`697d6a29fc8c93d3981a755c0c7683507ad39c3e`](https://github.com/cli-guidelines/cli-guidelines/blob/697d6a29fc8c93d3981a755c0c7683507ad39c3e/content/_index.md)).
This local bundle is a modified adaptation; no upstream endorsement is
implied. Licence legal code:
https://creativecommons.org/licenses/by-sa/4.0/legalcode

## What was imported

The upstream `SKILL.md` plus four resource documents: TypeScript output
architecture (result types, entry-point wiring, formatters, logger, JSON
envelope schemas), stream contracts (Node.js buffering, backpressure, NDJSON,
signals, crash-only design), CLI testing patterns (subprocess stream/exit-code
tests), and worked shell composability examples. No `assets/` directory exists
upstream.

## What changed locally

- Split the large upstream `SKILL.md` into `SKILL.md` (activation, core
  principle, hard rules, execution steps, output contract) and five `rules/`
  files (streams and formats, exit codes and errors, input/config/secrets,
  composability and help, stability and robustness), with the four upstream
  deep-dive resources kept as `references/`.
- Removed the cross-skill references to `api-design`, `twelve-factor`, and
  `hexagonal-architecture`: each rule is restated inline in `SKILL.md`'s
  companion note (Hyrum's Law for stdout shape, env-config and graceful
  shutdown, the driving-adapter/use-case mapping) and those skills are named
  only as optional companions. The hexagonal testing-pointer inside
  `references/testing-cli.md` became a bounded local note restating
  fakes-over-mocks.
- Dropped the mention of the upstream repository's internal `REFERENCES.md`
  (a sibling file outside this folder); the separately credited sources it
  names are not bundled, and the retained clig.dev attribution above covers
  the quoted material.
- Dropped the upstream `resources/source-notes.md` revision narrative; its
  audited clig.dev baseline and licence scope are recorded above.

No synchronization branch or automatic update policy exists. Updates are manual
comparisons against the upstream path above.

## Upstream licence notice

The notice below is quoted from the upstream `cli-design/LICENSE` file at the
imported revision; it is the authoritative licence statement for this bundle.

```text
Creative Commons Attribution-ShareAlike 4.0 International

The files in this `cli-design` directory (`SKILL.md` and `resources/`) are
licensed under the Creative Commons Attribution-ShareAlike 4.0 International
license (CC BY-SA 4.0), not the repository-root MIT license.

This bundle adapts *Command Line Interface Guidelines* by Aanand Prasad,
Ben Firshman, Carl Tashian, and Eva Parish from the pinned source revision
697d6a29fc8c93d3981a755c0c7683507ad39c3e:

https://github.com/cli-guidelines/cli-guidelines/blob/697d6a29fc8c93d3981a755c0c7683507ad39c3e/content/_index.md

The upstream work is licensed under CC BY-SA 4.0. This local bundle is a
modified adaptation; `resources/source-notes.md` records the changes and
revision history. No upstream endorsement is implied.

License legal code:
https://creativecommons.org/licenses/by-sa/4.0/legalcode

Pinned upstream license copy:
https://github.com/cli-guidelines/cli-guidelines/blob/697d6a29fc8c93d3981a755c0c7683507ad39c3e/LICENSE
```
