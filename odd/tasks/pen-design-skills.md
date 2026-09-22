# Feature: pen-design-skills

## Intent and authorization

Publish three independent Nix-managed skills in the existing ai-tools catalog:
`aytordev-interface-design`, `aytordev-design-system`, `aytordev-pen-ops`.
Adapt useful upstream knowledge without importing workflow authority, duplicate
rules, arbitrary taste mandates, or stale APIs. User approved implementation,
this separation, the local skill-creator contract, and strict TDD.

Branch: `feat/pen-design-skills`. Planning checkpoint: `7ca1f30`.
Implementation authorized again on 2026-09-22 with the refinements below.
No staging or implementation commits without separate authorization; no push,
PR, system activation, Pen launch/authentication/model calls, or live Pen probe.
Manual Pen import is accepted. No VM, separate account, vendor inquiry,
automatic registration, updater-owned skills, credentials, or signed-app edits.

## Design contracts and accepted refinements

- Interface design applies the consuming project's system to screens/flows;
  produce justified proposals/reviews from screen context.
- Design-system work evolves shared tokens, component anatomy/variants/states,
  documentation and adoption/migration decisions from the existing inventory.
  Do not overwrite a code-bearing design-system directory.
- Pen operations implement authorized changes using observed capabilities;
  report execution evidence, never select aesthetics or replace the system.
- Declare inputs, outputs and stop/ask conditions in each entry point. Ask when
  missing context materially changes the result; never invent requirements.
- Reuse project tokens/components; brand choices remain in the consuming project.
  Upstream taste is advice, not authority. Explain accessibility conflicts and
  propose bounded corrections; never silently retain defects or redesign.
- Each skill works in isolation: no sibling dependencies, escaping paths,
  circular loading, or required all-three activation. Cross-skill mentions are
  optional capability routing only. No extra orchestrator or module.
- Keep essential decisions in concise entry points; lazily load folder-local
  references by concern. One canonical owner per concern.
- Acceptance examples cover review without writes, system reuse, accessibility
  conflict escalation, missing Pen capabilities without invented operations,
  and isolated loading. Static checks prove packaging/instruction contracts,
  not model compliance. Behavioral examples/manual Pen use remain unexecuted.
- PDS-13 is the pilot: independently inspect its contracts/structure before
  repeating the pattern for PDS-14/PDS-15.
- Re-read pinned upstream material actually adapted. Preserve attribution,
  full applicable MIT notices and corrections/omissions. No claim the original
  49-file audit was recovered. No vendored transitions, fonts/icons or fixed
  product templates.
- WAI/MDN override upstream advice: normal contrast 4.5:1; large text 18pt or
  14pt bold (24px or exactly 18 2/3px); AA target size 24 CSS px with exceptions;
  `ch` is the zero glyph advance, not character count. No mandatory macOS-only
  font smoothing.

## Repository and historical context

`ai-skills.nix` exports the whole catalog at `$XDG_DATA_HOME/aytordev/skills`
and complete named folders to Pi when enabled. Expand inventory, checks and
current-policy docs together. Nonempty metadata dependencies remain forbidden.
Preserve the historical four-name prepare script and transition `oldNames`.

Recorded app metadata: Pencil 1.2.0; Nix package label 1.1.63; earlier research
Pen 1.2.13. Rolling docs are not proof of installed capabilities; package version
is out of scope. Official docs describe Add SKILL.md, re-add after edits, picker
removal without deleting source. Automatic discovery remains unproven.

PDS-1 (original SDD 1.1) historically recorded a selected 49-file audit (15 Nisus,
34 Krehel), manifest/ledgers/four broken reference triples. Topics
`sdd/pen-design-skills/{selection-manifest,audit,ledgers,tasks,state}` could not
be recovered: historical provenance only, not reverified evidence.
PDS-2..12 never started and are superseded, not completed: dependent two-skill
plan -> three standalone skills; extraction -> existing publication/checks;
registration probes/driver/watcher/GC/new module -> manual integration; runtime
end-to-end claim -> repository checks with manual Pen use explicitly untested.

## Routing, TDD and delivery

Parent owns this file, full Engram mirror `odd/pen-design-skills/tasks`, and todo.
Original mirror was unavailable; recovered from repository checkpoint and
restored as observation #240. Delegated mapping covered 4+ files. Each multi-file
implementation uses one bounded writer, then independent verification. RDD off.

Strict TDD: user-selected in the planning session and retained on resume.
Update inventory test first; observe real missing-skill RED before source or
publisher changes; implement GREEN, then refactor/recheck. Infrastructure or
artificial dependency failures do not count as RED. Keep tests/docs with source.
Baseline: six focused checks passed before checkpoint (cache-satisfied, 8s).

Forecast: three skill slices, originally 250–400 changed lines each, plus
tracking. Count additions+deletions including new files, excluding tracking.
2026-09-22 user approved **one PDS-13 exception up to 500 lines**, including
pending corrections, after independent measurement of 465. PDS-14/PDS-15 retain
<=400 each. No minification or omitted tests/docs to fit. Splitting source from
publication leaves a failing inventory and is not an accepted green work unit.
No implementation commit authority was granted by the size exception.

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

RED uses only the inventory target, with the same flags. `path:.` includes new
files without staging. Format only touched files; CI verification uses
`nix fmt -- --ci <touched Nix paths>`. Run `git diff --check`. Report cached versus
forced execution, failures and unexecuted checks honestly; no runtime claim.

## Tasks

- [x] **PDS-1** Historical audit, qualified above; no repository output.
- [x] **PDS-17** Planning checkpoint and reconciliation.
  Evidence: `7ca1f30`, document readback and staged whitespace passed;
  no skill source changed in that checkpoint. Accepted refinements now recorded.
- [x] **PDS-13** Interface-design pilot and five-skill publication.
  Status: done (implementation/checks); atomic delivery authorized below.
  Cover layout, typography, color/accessibility, motion/icons, writing and
  evidence-based review. Acceptance: observed RED/GREEN, metadata/links/resource
  isolation, XDG/Pi and disabled-client guards; <=500 one-time exception.
  Independent pilot contract/provenance readback passed after corrections;
  measured 476 lines. Do not claim examples are executed model tests.
- [x] **PDS-14** Design-system skill and six-skill publication.
  Status: done after accessibility-applicability correction and independent PASS;
  Atomic delivery authorized below. Final slice: 366 event-counted lines.
  Discovery, semantic tokens, component anatomy/variants/states,
  adoption/migration and optional project docs; no fixed product values.
  Same strict TDD/publication checks and input/output/stop contract; <=400 slice.
- [x] **PDS-15** Pen-operations skill and seven-skill publication.
  Status: done after standalone-loading correction and independent PASS;
  Atomic delivery authorized below. Final slice: 310 event-counted lines.
  Observe capabilities before choosing operations; distinguish
  rolling documentation from stale API recipes; manual import/reload, no sibling
  auto-loading. Same checks/contracts; <=400 slice; no live Pen execution.
- [x] **PDS-16** Independent final verification and structural readback.
  Status: done. Six checks, scoped format/whitespace, contract/scope/provenance,
  isolated-folder behavior and measured diffs; report omissions and no activation.

## Evidence and next action

PDS-13 writer reported inventory RED (actual four vs expected five naming the new
skill) before source/publisher changes, followed by the exact six-check GREEN
twice, including post-format. This is delegated execution evidence, not a parent
RED replay. No artificial dependency failure was introduced.

Independent verifier: six-check runner exit 0 (5.814s, cache/store hits, not forced
execution); CI formatter six Nix files, zero changes/exit 0; whitespace exit 0.
Git status unchanged by verification; no result link/lockfile/index/commit writes.
Native read-only ASSESS unavailable (empty output): treated as high and performed
independent verification; no RDD lifecycle started.

Pilot contract readback passed inputs/outputs/stops, system reuse, accessibility
conflict escalation, read-only review, progressive local references/isolation,
provenance/MIT notice and acceptance-example disclaimer. Independently measured
92 tracked changed lines + 373 new = 465 excluding this file; supersedes writer's
467 estimate. No size acceptance before the user's explicit <=500 exception.

Corrections complete: exact 18 2/3px equivalence in entry/reference; count-neutral
checks/AGENTS and portable-folder comment; reflow corrected from 200% to 400%
at 1280px (=320 CSS px); color hierarchy made conditional on project variants,
semantic roles reused before proposing additions. WAI reflow source confirmed.
Final independent pilot PASS: six checks exit 0 (5.866s, cache satisfied), scoped
CI format six files/zero changes, whitespace exit 0, empty staging. Footprint:
98 tracked + 378 new = **476**, within approved 500. Count delta is explained by
the corrections; no unknown edits. No blocking findings. Optional SC 1.4.4
citation and project-overridable typography/icon defaults left unchanged.
Writer fetched pinned sources via read-only HTTP GET (fetch_content unavailable);
full Krehel MIT retained, Nisus fetched but not adapted for pilot. No parent fetch
or recovered-audit claim. Behavior examples/manual Pen remain unexecuted.

PDS-14 complete: writer observed genuine inventory RED five vs six before
source/publication changes, then six-check GREEN before/after scoped formatting.
Independent PASS: same runner exit 0 (5.819s, cache satisfied), scoped format
zero changes, whitespace exit 0, staging empty/status unchanged. New skill:
302 lines/six files; writer's per-edit tracked accounting 29 lines; parent fixed
one stale terminal AGENTS sentence (two diff lines, readback passed): slice
**333**. Cumulative implementation diff **791** (111 tracked +680 new).
Shared-line replacements mean slice counts are not additive against HEAD.
Independent readback passed discovery/tokens/components/adoption/rollback,
code-bearing-directory protection, standalone resources, scenario disclaimer,
Nisus pinned MIT attribution. External fetch evidence is writer-reported.

PDS-15 writer complete: inventory RED exit 1 (six vs seven naming pen-ops)
before source/publication edits; six-check GREEN exit 0 with changed derivations
built, then post-format GREEN cache satisfied. No --rebuild used: not forced.
Scoped format/CI six files zero changes; whitespace exit 0. Skill 268 new lines
in four files +25 per-edit tracked lines = **293**. Prior skill folders preserved.
Pinned Nisus MIT/official Pen documentation fetched read-only by writer; stale
recipes explicitly omitted, capabilities govern operations. Input/output/stops,
manual import/reload, no sibling loading and unexecuted-example limits included.

PDS-16 found a false Pen provenance cross-reference. Corrected with folder-local
manual loading, README picker-removal semantics, and removal of unverified
execute-operation names. First fix writer timed out without edits (separate
read-only diagnosis and parent git/wc confirmed baseline); bounded retry passed.
Pen-ops now281 source lines; final task footprint **310** (281 +29 event-tracked).
Independent corrected verification passed six checks, scoped format, whitespace
and forced publication/transition rebuild with seven isolated folders and
negative tests; fingerprint16f89f72 was stable before subsequent DS correction.

Parent spot-read then found a missed DS defect: invented disabled-control 3:1
floor and blanket default-only state finding. Reopened PDS-14: corrected both,
added bounded WAI criterion applicability/exemptions and exact large-text sizes.
Writer retrieved WAI SC1.4.3/1.4.11/2.5.8/1.4.10 passages confirming inactive
exceptions and threshold scope; six-check runner/whitespace pass. DS now335
source lines; PDS-14 footprint **366** (335 +31 event-tracked), still <=400.

Final PDS-16 **PASS**, no blocking findings. Six-check runner exit 0 (6.083s,
cache satisfied); scoped CI format six files/zero changes; whitespace exit 0.
Forced `--rebuild -L` of integration-gentle-ai-engine and
integration-ai-skills-transition exit 0 (2.336s): seven isolated-folder resource
passes, missing-resource rejection, and fourteen transition positive/negative
cases. Official WAI pages retrieved read-only and corrected DS claims confirmed.
Pen manual-loading correction and seven-name publication preserved.

Final verifier fingerprint (before tracking-only closure):
`99e3e7b83082da5a40aa85ab63c86f39a50b683eae614d75e46d53a6fcdefcce`;
identical before/after verification. Staging empty, HEAD7ca1f30 and flake.lock
unchanged. Final source footprint: 126 tracked changed lines (92+/34-) +994 new
(378 interface,335 design-system,281 pen-ops) = **1120**, excluding tracking.
Slice event counts476/366/310 respect approved bounds but are not independently
reconstructable shared-file commit diffs; no intermediate commits were authorized.

Unavailable: native read-only ASSESS (empty output); treated as high risk with
independent verification, RDD stayed off. Not run: full flake check, Linux,
activation, installed-client discovery, live Pen import/use, model-behavior tests.
Pre-existing docs-links scope omits skill-creator; all three new skill trees are
included, and isolated-folder checks cover all seven. No new coverage claim.
Deployment and manual Pen import remain separate from repository delivery.
Installed skills remain unchanged until a separately authorized activation.

## Delivery decision

The user subsequently authorized an atomic commit, push and PR, and explicitly
selected a **single-PR size exception** after reviewing the 1370-line forecast
(1120 implementation +250 tracking, before this delivery note). Keep the three
skills, publication, checks and documentation together in one implementation
commit; do not reconstruct intermediate trees or drop evidence to shrink it.
Use `feat/pen-design-skills` against `main`; both local/remote main resolve to
`b0070e3`, and the remote feature checkpoint is `7ca1f30`. Actual repository
policy requires no approved issue or `type:*` label; use its existing PR template.
Delivery verification uses the Git-backed `nix flake check .` after staging new
files. A full `path:.` check included `.git/hooks/pre-commit` in the sandbox and
failed before treefmt ran; separate diagnosis confirmed that invocation issue.
Do not disable hooks: the Git source includes staged files but excludes `.git`.
Final delivery verification, commit identity, PR URL and remote check state are
recorded in Engram topic `odd/pen-design-skills/delivery`, avoiding a follow-up
commit whose only purpose would be to record its own identity. This document is
the pre-delivery checkpoint, not proof that push/PR creation already succeeded.
No merge, activation, live Pen test or registry refresh is authorized.

## Sources

- Krehel + MIT: https://github.com/jakubkrehel/skills/tree/d01493b0a7b976a74bfcedc80c783d60c7995910
  (`better-accessibility`, `better-layout`, `better-writing`, `better-typography`,
  `better-colors`, `better-ui`, `better-interface`, `interface-review`).
- Nisus/Travis Polland 2026 + MIT: https://github.com/Nisus74/pencil-skill/tree/28ec61cefe3000a59bdac6b98b83168dbacca9c8
  (`skills/pencil-design/SKILL.md`, optional design-system templates).
- https://docs.pen.dev/core-concepts/ai-agents
- https://docs.pen.dev/getting-started/ai-integration
- https://docs.pen.dev/for-developers/pen-cli
- https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- https://www.w3.org/WAI/WCAG22/Understanding/reflow.html
- https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/length
- https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-smooth
