# Adopt the citypaul skill set

Program record for adopting the remaining Agent Skills from
`citypaul/.dotfiles`. Batches land as separate stacked PRs; this document owns
the batch plan, the specs, and the per-batch evidence.

## Specs

- **S1** — The user authorized adopting the whole remaining set, in batches,
  under this repository's authoring contract:

  > Me gustan mucho todas las skills que leo aqui, con su REFERENCES. https://github.com/citypaul/.dotfiles/tree/main/claude/.claude/skills

  > Todo el set, por lotes, teniendo en cuenta nuestro @skill-creator.

- **S2** — Every package satisfies `skills/skill-creator/SKILL.md`: `SKILL.md`
  with `name` equal to the directory and one single-line quoted `description`,
  a matching `metadata.json`, concise runtime entry point, and detail pushed to
  `rules/` or `references/`. No empty directories, no `README.md`/`CHANGELOG.md`.
- **S3** — Every package stays independently consumable. `checks/ai-tools-dependencies`
  forbids declared sibling dependencies, so upstream cross-skill references
  (`tdd`, `observability`, `characterisation-tests`, `codebase-design`,
  `reduce-system-complexity`, `technical-writing`, `ubiquitous-language`, …)
  are restated as bounded local notes, never as declared dependencies. This
  follows the creator's "bundle necessary references" rule rather than changing
  the dependency contract.
- **S4** — Provenance is honest: each entry is `adapted`, records origin
  repository and content path plus the exact imported revision, keeps
  `tracking = null`, and carries an MIT notice in `references/provenance.md`.
- **S5** — The inventory surface moves with each batch: `catalog.nix`,
  `checks/ai-tools-inventory`, `checks/ai-tools-dependencies`,
  `checks/gentle-ai-engine`, `checks/ai-skills-transition`,
  `checks/ai-tools-docs-links`, `modules/common/ai-tools/AGENTS.md`, its
  `README.md`, `modules/common/AGENTS.md`, root `README.md`, `CONTRIBUTING.md`,
  and the creator's authored-package list.
- **S6** — Batches are stacked, not merged into one PR: each batch branches from
  the previous batch's branch and targets it as PR base, so review stays
  per-batch and merge order is explicit.
- **S7** — Each batch is verified with the focused ai-tools checks before its
  PR exists, and the batch is only reported complete with that evidence.

## Batch plan

48 skills remain (upstream also ships `REFERENCES.md`, a cross-skill index that
is not a skill and is not copied). Upstream root: `claude/.claude/skills/`.

| Batch | Theme | Skills | Branch |
| --- | --- | --- | --- |
| B1 | Engineering hygiene | `expectations`, `ci-debugging`, `refactoring` | `feat/adopt-b1-engineering-hygiene` |
| B2a | Testing core | `tdd`, `testing` | `feat/adopt-b2-testing-core` |
| B2b | Test evidence | `test-design-reviewer`, `characterisation-tests`, `mutation-testing` | `feat/adopt-b2-test-evidence` |
| B2c | Frontend verification | `front-end-testing`, `react-testing`, `double-check` | `feat/adopt-b2-frontend-testing` |
| B3 | Review and evaluation | `acceptance-review`, `panel-review`, `evaluate-existing-solutions`, `find-gaps` | `feat/adopt-b3-review` |
| B4 | Architecture and structure | `codebase-design`, `structure-codebase`, `folder-structure`, `finding-seams`, `improve-codebase-architecture`, `reduce-system-complexity`, `graph-engineering`, `twelve-factor` | `feat/adopt-b4-architecture` |
| B5 | Domain, API and events | `api-design`, `bff-design`, `bff-entry-points`, `domain-driven-design`, `ubiquitous-language`, `event-sourcing`, `xstate`, `secure-oauth-oidc` | `feat/adopt-b5-domain-api` |
| B6 | Frontend and diagrams | `react-performance`, `render-code-shape`, `diagrams` | `feat/adopt-b6-frontend` |
| B7 | Operations and writing | `observability`, `debugging`, `production-parity-skill-builder`, `technical-writing`, `teach-me`, `wtf` | `feat/adopt-b7-operations` |
| B8 | Planning and delivery | `planning`, `storyboard`, `story-splitting`, `specification`, `find-skills`, `stack-pull-requests`, `cli-design`, `hexagonal-architecture` | `feat/adopt-b8-planning` |

Batch order is by dependency usefulness, not importance: B1-B3 give the
vocabulary the later skills cite, so their bounded local notes can reference an
already-adapted rule instead of restating it from scratch.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| B1.1 | S1-S4 | inline, package authoring | `feat(skills): adopt expectations, ci-debugging, and refactoring` |
| B1.2 | S5-S7 | inline, inventory wiring + focused checks | same commit |
| B2a.x…B8.x | S1-S7 | as each batch opens | one stacked PR each |

## Verification contract

Per batch:

```sh
nix build path:.#checks.aarch64-darwin.integration-ai-tools-skill-contract \
  path:.#checks.aarch64-darwin.unit-ai-tools-inventory \
  path:.#checks.aarch64-darwin.unit-ai-tools-dependencies \
  path:.#checks.aarch64-darwin.integration-ai-tools-docs-links \
  path:.#checks.aarch64-darwin.integration-gentle-ai-engine \
  path:.#checks.aarch64-darwin.integration-ai-skills-transition \
  --override-input secrets path:./checks/fixtures/secrets \
  --no-write-lock-file --no-link
```

## Risk

No Task Size high-risk item applies to a batch: additive skill content plus the
inventory expectations that batch exists to update. The one contract-shaped
decision — cross-skill references — is resolved by the creator's existing
standalone rule (`S3`), not by changing the dependency check.

## Log

**L1** — User request, verbatim:

> Me gustan mucho todas las skills que leo aqui, con su REFERENCES. https://github.com/citypaul/.dotfiles/tree/main/claude/.claude/skills

**L2** — Scope decision, verbatim: `Todo el set, por lotes, teniendo en cuenta nuestro @skill-creator.`

**L3** — Slice boundary for B1. `89d438c8` carries 3 243 authored lines since
`origin/main`, of which 2 129 belong to the already-delivered
typescript-strict/functional work that this branch is stacked on. The batch
itself is 1 114 authored lines in one commit: three complete skill packages
(17 files, including three MIT notices) plus the routing/media changes to the
catalog, five checks, and six documents. A skill package is the smallest
contract-valid unit, so the batch is one reviewable slice rather than three
partial ones; the wiring cannot be split without leaving a tree the repository's
own checks reject.

**L4** — B2 split before authoring. The eight testing skills total 2 316 upstream
lines and 20 files, which is not one reviewable slice. It becomes three PRs:
`tdd` + `testing` (833 lines, the two anchors every other testing skill cites),
then the evidence trio, then the frontend trio. Batch numbering in the plan table
follows that split.

**L5** — Slice boundary for B2a. `2e29c266` is 844 authored lines: two complete
packages (13 files, including their MIT notices) plus the inventory wiring. Total
since `origin/main` is 4 097 lines across nine commits, of which 3 253 belong to
the two stacked parent branches. Each batch keeps the same shape: one content
commit per batch with its wiring, and a small `docs(odd)` commit recording the
boundary.

**L6** — Slice boundary for B2b. `fdba7491` is 950 authored lines: three complete
packages (14 files, including their MIT notices, one with Dave Farley's
attribution for the eight test properties) plus the inventory wiring. Total since
`origin/main` is 5 054 lines across eleven commits, of which 4 104 belong to the
three stacked parent branches.

**L7** — Slice boundary for wave 1 (7 skills). `9c34ff6a` is 4 991 authored
lines: the packages dominate because `front-end-testing` alone carries four
rules and five bundled references (1 264 lines) and `react-testing` two more.
This is progressive disclosure working as intended, not a monolithic file: the
entry points stay at 92-139 lines each. Total since `origin/main` is 10 051
lines across thirteen commits, of which 5 060 belong to the four stacked parents.
The remaining waves (33 skills) follow the same shape: delegated authoring in
disjoint folders, parent wiring and verification, one commit per wave.

**L8** — Slice boundary for wave 2 (8 skills). `ac81d813` is 6 354 authored
lines: the architecture packages carry substantial bundled references
(`structure-codebase` 2 423 lines of rules and references, `finding-seams`
1 064, `graph-engineering` restated from a workflow script). Entry points stay
117-140 lines. Total since `origin/main` is 16 414 lines across fifteen commits.
Two of the eight needed their own licence notice: `codebase-design` and
`improve-codebase-architecture` are Matt Pocock's (c) 2026, and
`reduce-system-complexity` is Adam Bulmer's (c) 2025 — verified against the
upstream files, not inferred from the repository licence.

**L9** — Slice boundary for wave 3 (8 skills). `ecc748ca` is 9 387 authored
lines: `secure-oauth-oidc` carries a five-file RFC 9700 control catalog and
`event-sourcing` eight references, which is where the volume comes from; entry
points stay 101-145 lines. Total since `origin/main` is 25 811 lines.
Fidelity checks before commit: `api-design`'s nested Addy Osmani notice is byte
identical to upstream, and `secure-oauth-oidc` retains every upstream guard term.
The pre-commit `typos` hook caught two spellings in `bff-entry-points`; both were
rewritten rather than allowlisted.

**L10** — Slice boundary for wave 4 (8 skills). `cecb4132` is 8 823 authored
lines; `cli-design` alone carries four long references and `observability` nine
rule files. Two defects were caught by the repository's own gates rather than by
reading: the `docs-links` check rejected a link to a file the writer had dropped
and five `[label](url)` template placeholders, both rewritten instead of excluded
from the check. `cli-design` is the collection's first non-MIT package and now
carries its CC BY-SA 4.0 attribution and pinned upstream revision.

**L11** — Program closure. `12528e96` closes wave 5 (nine packages) and the
authoring program: 45 of the 50 upstream skills adopted in five waves plus the
two from the earlier feature, for **55 authored / 56 published** packages and
**41 350 authored lines** across twenty-one commits. The publication check
reports **55** `PASS isolated folder resources` lines and the six ai-tools checks
pass on the final tree.

Licensing is recorded per package, not per repository: nine adaptations carry
nested MIT notices from their own authors and `cli-design` is CC BY-SA 4.0.
Each notice was compared against the upstream file; where a separator was
missing it was restored rather than paraphrased.

Not adopted: `REFERENCES.md` upstream, which is a cross-skill index rather than
an Agent Skill, and nothing else — the five remaining upstream directories are
the ones delivered here.

Remaining work is outside authoring: the reviews requested after implementation,
and the merge order for the stacked PRs.
