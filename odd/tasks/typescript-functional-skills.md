# Publish TypeScript Strict and Functional skills

Implementation record for inventory expansion of `modules/common/ai-tools/skills/`
with two adapted skill packages. Later authorization and commit evidence appear
at the end; earlier statements describe their original phase.

## Specs

- **S1** — The user authorized exactly two new published skills, named after
  their upstream folders: `typescript-strict` and `functional`. Both are adapted
  from `citypaul/.dotfiles` and authored under
  `modules/common/ai-tools/skills/<name>/`. No other inventory expansion is in
  scope.
- **S2** — Each package satisfies the local authoring contract in
  `skills/skill-creator/SKILL.md`: `SKILL.md` with `name` equal to the directory
  and a single-line quoted `description`, a matching `metadata.json`, concise
  runtime-oriented entry point, and detail pushed into `rules/` and
  `references/`. No empty directories, no `README.md`/`CHANGELOG.md`, no
  `assets/` until a real asset exists.
- **S3** — Each package stays independently consumable: no declared sibling
  skill dependency, every bundled link resolves inside its own folder, and no
  reference to skills that this repository does not publish.
- **S4** — Substance from the upstream skills is preserved: strict-boundary
  typing, assertion discipline, type/interface semantics, single-owner value
  sets, schema-first trust boundaries, branded primitives, strict compiler
  flags; and immutable domain data, purity with isolated effects, functional
  light, array-method selection, options objects, guard clauses, and Result
  values. Wording and examples are adapted to this repository's layout, not
  copied wholesale.
- **S5** — Provenance is honest and notices are retained. Both entries are
  `adapted`, record their origin repository/content path and the exact imported
  revision, keep `tracking = null`, and carry an MIT notice in
  `references/provenance.md`.
- **S6** — The inventory surface changes together: `catalog.nix`, the
  `ai-tools-inventory`, `ai-tools-dependencies`, `gentle-ai-engine`,
  `ai-skills-transition`, and `ai-tools-docs-links` expectations, plus
  `modules/common/ai-tools/AGENTS.md`, its `README.md`, `modules/common/AGENTS.md`,
  root `README.md`, `CONTRIBUTING.md`, and the creator's own authored-package
  list. Publication itself stays catalog-derived: no second name list, runtime
  registry, updater, or adapter.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1-S5 | inline, package authoring | `feat(skills): add adapted typescript-strict skill` |
| T2 | S1-S5 | inline, package authoring | `feat(skills): add adapted functional skill` |
| T3 | S6 | inline, inventory wiring + focused checks | `feat(skills): publish typescript-strict and functional` |
| T4 | S2-S6 | inline, full validation and closure | none (evidence only) |

Each package is its own commit so a reviewer reads one skill folder at a time;
`S6` stays in a single commit because the inventory expectation is atomic over
the exact authored folder set. A per-skill wiring commit would leave an
intermediate tree that the repository's own checks reject.

## Verification contract

Applicable deterministic checks are the repository's own ai-tools checks, run
against the working tree:

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

Contract tests exercise every observable effect the specs name: directory/name
match, frontmatter/metadata agreement, single-line quoted description, catalog
ownership shape (kind, origin, tracking, provenance paths), pure-data catalog,
independent dependency closure, isolated dereferenced folder resource
resolution, and realized neutral/Pi publication of the exact folder bytes.

## Risk

No Task Size high-risk item applies. The change is additive content plus
inventory expectations; the catalog is Nix-evaluated data, and the changed
contracts are the ones this task is asked to change. Existing skills, upstream
Impeccable pins, publication mechanism, and client guards are untouched.

## Log

**L1** — User request, verbatim:

> Quiero implementar estas skills https://github.com/citypaul/.dotfiles/blob/main/claude/.claude/skills/typescript-strict/SKILL.md y https://github.com/citypaul/.dotfiles/blob/main/claude/.claude/skills/functional/SKILL.md siguiendo @modules/common/ai-tools/skills/skill-creator/SKILL.md

**L2** — Routing decision recorded before the first commit. The two packages were
authored inline rather than delegated: both touch the same catalog, check
expectations, and documentation surfaces, so parallel writers would not have
disjoint allowed edit surfaces. Commits are sliced by concern: two content
commits (one per skill folder) and one wiring commit.

Evidence at T3: focused `nix build` of the six ai-tools checks exited 0; the
publication check printed `PASS isolated folder resources: functional` and
`PASS isolated folder resources: typescript-strict`, and its byte-for-byte
comparison covered the neutral collection, Pi projection, custom HOME/XDG, and a
dereferenced isolated copy for both new folders. `nix fmt -- --ci` reported 0
changed files.

**L3** — Slice boundaries recorded for delivery review. A complete skill package
is the smallest valid reviewable unit here: a partial package is not a valid
skill under `S2`, so the fragments cannot be staged independently. Measured
authored lines since `origin/main` (lock files excluded):

| Slice | Commit | Authored lines | Content |
| --- | --- | --- | --- |
| Content | `d2ec10c5` | 773 | `typescript-strict` package plus this task document |
| Content | `8bc85129` | 1154 | `functional` package (13 files, three bundled references) |
| Wiring | `511e4c62` | 166 | Catalog, check expectations, inventory documentation |

The two content slices exceed the ~400-line guidance because each is one
coherent, contract-valid package of Markdown rules and references; splitting a
package by file would produce a tree the skill contract rejects. Review can be
scoped per folder, and the wiring slice stays small and separate.

**L4** — Verification and closure.

- Focused `nix build` of `integration-ai-tools-skill-contract`,
  `unit-ai-tools-inventory`, `unit-ai-tools-dependencies`,
  `integration-ai-tools-docs-links`, `integration-gentle-ai-engine`, and
  `integration-ai-skills-transition` exited 0. The publication check printed
  `PASS isolated folder resources: functional`,
  `PASS isolated folder resources: typescript-strict`, and
  `PASS missing bundled support rejected; neutral and client contents match`,
  which covers byte-for-byte publication of both new folders to the neutral
  collection, the Pi projection, a custom HOME/XDG tree, and a dereferenced
  isolated copy.
- `integration-impeccable` exited 0, so the untouched upstream package still
  passes. `nix flake check path:. --all-systems --no-build` printed
  `all checks passed!`, so every platform's check set still evaluates.
- `nix fmt -- --ci` reported 0 changed files, and the repository pre-commit
  hooks (treefmt, statix, deadnix, typos, conflict markers) passed on all three
  commits.
- No independent verifier ran: `assess` reported no Task Size high-risk item and
  no escalation, so the risk-gated plan kept the writer's self-verification. The
  native review tier was `unassessable` for uncommitted work; the switch is on
  and a committed-range assessment is the remaining outside view, not a
  requirement of this plan.
- Negative coverage relies on the repository's existing checks, not on new
  fixtures: the inventory check asserts the exact authored folder set and rejects
  eleven invalid catalog fixtures, the dependency check asserts every client
  selection is closed and dependency-free, and the publication check removes one
  bundled reference from a copied folder and expects failure.

Risk: none. No Task Size high-risk item applies: no stored data, credentials,
guards, or irreversible effects change; the touched contracts are the ones this
task exists to change; the catalog remains Nix-evaluated pure data; and the
ai-tools checks would catch a regression in the inventory, dependencies,
publication, or documentation links.
