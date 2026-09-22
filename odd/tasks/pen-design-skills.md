# Feature: pen-design-skills

## Objective and accepted scope

Publish three independent, Nix-managed skills under the existing ai-tools
catalog: `aytordev-interface-design`, `aytordev-design-system`, and
`aytordev-pen-ops`. Adapt useful upstream knowledge without importing its
workflow authority, duplicated rules, arbitrary taste mandates, or stale APIs.

The user approved implementation, the three-way separation, the local
`modules/common/ai-tools/skills/skill-creator` authoring contract, and strict
TDD. Manual import into Pen is acceptable. No VM, separate macOS account,
vendor inquiry, automatic registration, or live Pen probe is wanted.

## Rationale and boundaries

- Interface design applies the project's system to screens and flows.
- Design-system work defines and evolves shared tokens, component contracts,
  variants, states, documentation, and adoption decisions.
- Pen operations implement authorized changes using the observed tool surface;
  they do not choose product aesthetics or replace the project's system.
- Product-specific tokens and brand choices stay in the consuming project.
- Each skill must work from an isolated folder. No sibling dependencies,
  escaping resource paths, circular loading, or required all-three activation.
- One canonical owner per concern; cross-skill mentions are optional capability
  routing, never file dependencies. Shared standards may be externally cited.
- Preserve upstream pins, attribution, MIT notices, and explicit correction /
  omission rationale. Do not claim the original full audit was recovered.
- WAI/MDN take precedence over upstream design advice. In particular preserve
  normal-text contrast 4.5:1; large text at 18pt or 14pt bold (24px or exactly
  18 2/3px); target-size AA 24 CSS px with exceptions; `ch` is the zero glyph's
  advance, not a character count; no mandatory macOS-only font smoothing.
- No vendored transitions content, fonts, icons, or fixed product templates.
- Do not manage updater-owned `~/.pencil/skills`, credentials, application
  config, or signed bundles. No Pen launch, authentication, or model calls.
- No system activation, push, or PR creation. The user explicitly authorized
  committing this planning checkpoint; implementation commits need their own
  delivery authorization.

## Historical evidence and superseded plan

PDS-1 (original SDD 1.1) was recorded as complete: selected 49-file audit
(15 Nisus, 34 Krehel), manifest, ownership/protocol ledgers, four broken
reference triples. Its reported Engram topics are
`sdd/pen-design-skills/{selection-manifest,audit,ledgers,tasks,state}`.
Current searches did not recover those artifacts; retain this as historical
provenance, not independently reverified evidence.

Original PDS-2..PDS-12 never started. They are superseded, not completed:
- PDS-2/3: two dependent skills replaced by three standalone skills below.
- PDS-4/5: projection extraction replaced by existing XDG/Pi publication and
  current contract, inventory, dependency, resource, and publication checks.
- PDS-6/7/8: fixture/live registration probes removed by the accepted manual
  integration route.
- PDS-9/10/11: new home module, registration driver, watcher, and GC roots
  removed; reuse the existing ai-skills capability.
- PDS-12: runtime end-to-end claim replaced by repository verification below;
  manual Pen import/use remains explicitly untested.

## Current repository facts

`ai-skills.nix` exports the whole catalog at `$XDG_DATA_HOME/aytordev/skills`
and named complete folders to Pi when enabled. The current standalone contract
rejects every nonempty metadata dependency array. Expand inventory and checks
with each skill; do not relax independence or invent a new module.

Installed system app metadata reports Pencil 1.2.0; Nix labels its package
1.1.63. Earlier static research used Pen 1.2.13. Current Pen documentation is
rolling, not proof of the installed tool surface. The package version is out
of scope. Official docs describe Add SKILL.md, re-add after edits, and removal
from the picker without deleting source files; automatic discovery is unproven.

## Work and verification

Branch: `feat/pen-design-skills`.
Route: delegated writer for each bounded multi-file task, parent tracking,
independent verification afterward (RDD off). Mapping was delegated because
more than four files carry the publication contract.
TDD: **strict**, explicitly selected by the user in this session. For each skill,
change relevant test expectations first, observe a missing-skill RED, implement,
observe GREEN, then refactor and repeat checks. Never count an infrastructure
failure as the required RED. Keep tests and publication/docs in the same unit.
Baseline: all six focused checks below passed before source changes (exit 0;
Nix cache-satisfied, 8 seconds).
Delivery: three reviewable skill slices, forecast 250-400 changed lines each,
plus tracking and final verification. Preserve the historical <=400 actual-diff
slice boundary; split honestly before overrun, never omit tests or minify.
The user requested a planning checkpoint commit before implementation.
Commit only this feature document; keep all skill implementation pending.

### Exact focused runner

```sh
nix build \
  path:.#checks.aarch64-darwin.integration-ai-tools-skill-contract \
  path:.#checks.aarch64-darwin.unit-ai-tools-inventory \
  path:.#checks.aarch64-darwin.unit-ai-tools-dependencies \
  path:.#checks.aarch64-darwin.integration-gentle-ai-engine \
  path:.#checks.aarch64-darwin.integration-ai-skills-transition \
  path:.#checks.aarch64-darwin.integration-ai-tools-docs-links \
  --override-input secrets path:./checks/fixtures/secrets \
  --no-write-lock-file --no-link
```

`path:.` includes new files without staging. Format only authorized files using
the repository formatter; report any unavailable check instead of claiming it.

## Tasks

- [x] **PDS-1** Historical source audit, as qualified above. No repository output.
- [x] **PDS-17** Reconcile the planning checkpoint.
  Status: done. Capture the three-skill decision, authoring contract,
  manual Pen route, strict TDD runner, baseline, and superseded task history.
  Acceptance: document readback and staged whitespace check pass; no skill
  source changes. Delivery: document-only commit on the feature branch, with
  its identity recorded in the Engram mirror.
- [ ] **PDS-13** Interface-design skill and five-skill publication.
  Status: pending. Adapt layout, typography, color, accessibility,
  motion/icons, writing, and evidence-based screen/change review. Keep review
  read-only unless changes are requested. Include provenance/corrections.
  Acceptance: observed RED/GREEN; metadata, links, isolated resources, XDG/Pi
  publication and disabled-client regression checks pass; <=400-line slice.
- [ ] **PDS-14** Design-system skill and six-skill publication.
  Status: pending. Cover existing-system discovery, semantic token decisions,
  component anatomy/variants/states, adoption and migration, and optional
  project documentation. Do not create fixed product values or overwrite a
  code-bearing design-system directory. Same TDD/publication acceptance.
- [ ] **PDS-15** Pen-operations skill and seven-skill publication.
  Status: pending. Observe live capabilities before choosing operations;
  distinguish documented current tools from old API recipes; document manual
  import/reload and no automatic sibling loading. Same acceptance; no live Pen.
- [ ] **PDS-16** Independent final verification and structural readback.
  Status: pending. Run all six checks, formatting verification, and inspect
  contract/scope/provenance and isolated-folder behavior. Record measured diff,
  failures, omissions, and no runtime/activation claims.

## Evidence and next action

Source changes: none. PDS-17 readback passed; `git diff --cached --check`
passed (exit 0), with only this document staged. Six baseline checks passed
before this documentation-only checkpoint; they were not rerun for the plan.
Next implementation action: PDS-13 writer observes RED before implementation.
Checkpoint identity: recorded in the Engram mirror after commit; locate it with
`git log -1 --format='%h %s' -- odd/tasks/pen-design-skills.md`.
Activation/import: not performed.

## Sources

- Krehel pinned corpus and MIT license:
  https://github.com/jakubkrehel/skills/tree/d01493b0a7b976a74bfcedc80c783d60c7995910
  (`better-accessibility`, `better-layout`, `better-writing`,
  `better-typography`, `better-colors`, `better-ui`, `better-interface`,
  `interface-review`). Primary entries/licenses re-fetched in this session.
- Nisus pinned corpus and MIT license (Travis Polland 2026):
  https://github.com/Nisus74/pencil-skill/tree/28ec61cefe3000a59bdac6b98b83168dbacca9c8
  (`skills/pencil-design/SKILL.md`, optional `design-system/` templates).
  Main entry excerpts/template README and license re-fetched in this session.
- https://docs.pen.dev/core-concepts/ai-agents
- https://docs.pen.dev/getting-started/ai-integration
- https://docs.pen.dev/for-developers/pen-cli
- https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- https://www.w3.org/WAI/WCAG22/Understanding/reflow.html
- https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/length
- https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-smooth
