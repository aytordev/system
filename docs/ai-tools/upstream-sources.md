# Upstream Sources and Local Adaptations

Provenance record for the AI skill migration in
[ADR 0017](../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md)
and task T24 of the [implementation plan](./implementation-plan.md).

This file records the frozen upstream revision, the local skill census, the
adaptation map, and the bundle grouping. It is not a support matrix; a capability
is only supported once its bundle is deployed and verified.

Local baseline: `3752d5c43840671467487e9805ef867c2816f5b8`.

## 1. Frozen source

| Field | Value |
| --- | --- |
| Upstream repository | `https://github.com/Gentleman-Programming/gentle-ai` |
| Release tag | `v2.9.0` |
| Commit | `be49554794917ae92a6dc9dbfa2eb3db5cf70084` |
| Commit date | 2026-09-14 (commit 11:17:37 +0200; tag created 11:42:31 +0200) |
| Repository license | MIT (`LICENSE`) |
| Upstream skill root | `internal/assets/skills/` |

This commit is the **migration baseline**. It is also `main` HEAD and the
`v2.9.0` tag target, so the audit pin and the latest stable release are the same
revision; T24 records that baseline rather than selecting a newer version. The
exact commit is authoritative. `main` and `latest` must not move the target
during implementation or at runtime ([ADR 0017][adr-0017]).

The khanelinix-derived methods are pinned separately at
`8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd` and are **not** part of this file's
gentle-ai skill inventory.

Per-skill frontmatter licenses upstream: the ten inherited SDD phase skills plus
`skill-registry` and `sdd-research` declare `MIT`; the auxiliary and authoring
skills (`branch-pr`, `chained-pr`, `cognitive-doc-design`, `comment-writer`,
`issue-creation`, `judgment-day`, `go-testing`, `work-unit-commits`,
`skill-creator`, `skill-improver`, `rdd-defect-workflow`,
`hermes-ephemeral-delegation`, `systemic-issue-triage`, `gentle-ai-bench`)
declare `Apache-2.0`.

Access method: read-only sparse clone already present at
`/var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/gentle-ai-sdd-audit`
(sparse checkout of `internal/assets`, `internal/sddstatus`,
`internal/skillregistry`, `docs`). Skill files and git metadata were read from
that clone. No network fetch was required.

## 2. Local skills inventory

Derived from the on-disk tree under `modules/common/ai-tools/skills/`. There are
21 skill directories, 16 with `rules/`, 21 with `metadata.json`, 2 with
`modules/`, and none with `scripts/` or `assets/`.

`_shared/` is a shared-protocol directory, not a skill, and is excluded from the
skill count.

| Skill | Upstream v2.9.0 same name | rules/ | modules/ | metadata.json | references/ | scripts/ | assets/ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| branch-pr | yes | — | — | yes | yes | — | — |
| chained-pr | yes | — | — | yes | yes | — | — |
| cognitive-doc-design | yes | — | — | yes | yes | — | — |
| comment-writer | yes | — | — | yes | yes | — | — |
| dotfiles-coder | no | yes | — | yes | — | — | — |
| issue-creation | yes | — | — | yes | yes | — | — |
| judgment-day | yes | yes | — | yes | — | — | — |
| nix | no | yes | — | yes | — | — | — |
| sdd-apply | yes | yes | yes | yes | — | — | — |
| sdd-archive | yes | yes | — | yes | — | — | — |
| sdd-design | yes | yes | — | yes | yes | — | — |
| sdd-explore | yes | yes | — | yes | — | — | — |
| sdd-init | yes | yes | — | yes | yes | — | — |
| sdd-onboard | yes | yes | — | yes | — | — | — |
| sdd-propose | yes | yes | — | yes | yes | — | — |
| sdd-spec | yes | yes | — | yes | yes | — | — |
| sdd-tasks | yes | yes | — | yes | yes | — | — |
| sdd-verify | yes | yes | yes | yes | yes | — | — |
| skill-creator | yes | yes | — | yes | — | — | — |
| skill-registry | yes | yes | — | yes | — | — | — |
| work-unit-commits | yes | yes | — | yes | — | — | — |

Structural summary: 19 of 21 local skills have a same-named upstream v2.9.0
directory; `dotfiles-coder` and `nix` have no upstream counterpart. Upstream
v2.9.0 skill directories contain only `SKILL.md` and optional `references/`; they
do not ship `rules/`, `modules/`, or `metadata.json`. Local `strict-tdd.md` and
`strict-tdd-verify.md` live under `modules/`, while upstream keeps the same files
at the skill root (`sdd-apply/strict-tdd.md`, `sdd-verify/strict-tdd-verify.md`).

## 3. Adaptation map

Classification: `preserved` (upstream behavior kept), `adapted` (upstream
behavior changed to fit local layout or policy), `deferred` (not migrated now and
not advertised as supported). Every row was checked by reading both the local
file and the upstream file at the frozen commit.

### Inherited SDD phase skills

Upstream v2.9.0 phases carry executor-only role guards, a language-domain
contract, native status/locator contracts, size budgets, a threat matrix, and a
verification validator that the local `rules/`-split phases do not. Adopting the
frozen behavior requires reorganizing it into the local layout, so each phase is
`adapted`.

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| sdd-init | `internal/assets/skills/sdd-init/SKILL.md` (+ `references/init-details.md`) | `modules/common/ai-tools/skills/sdd-init/` | adapted | Upstream is v3.0 with a decision-gated strict-TDD fail-closed policy; local is a simpler prompt that delegates steps to `rules/` and hardcodes `~/.config/opencode` paths. | SDD execution |
| sdd-explore | `internal/assets/skills/sdd-explore/SKILL.md` | `modules/common/ai-tools/skills/sdd-explore/` | adapted | Upstream inlines retrieval and requires a mandatory persist step for named changes; local splits this into `rules/` and references shared `skill-loading.md`. | SDD execution |
| sdd-propose | `internal/assets/skills/sdd-propose/SKILL.md` | `modules/common/ai-tools/skills/sdd-propose/` | adapted | Upstream adds a Capabilities contract, a confirmed pre-proposal handoff, and a 450-word budget; local has none of these. | SDD execution |
| sdd-spec | `internal/assets/skills/sdd-spec/SKILL.md` | `modules/common/ai-tools/skills/sdd-spec/` | adapted | Upstream adds RENAMED deltas, full-block MODIFIED rules, and a 650-word budget; local references a separate `delta-spec-format.md`. | SDD execution |
| sdd-design | `internal/assets/skills/sdd-design/SKILL.md` (+ `references/threat-matrix.md`) | `modules/common/ai-tools/skills/sdd-design/` | adapted | Upstream adds an applicability-driven threat matrix and an 800-word budget; local keeps a `design-template.md` reference instead. | SDD execution |
| sdd-tasks | `internal/assets/skills/sdd-tasks/SKILL.md` | `modules/common/ai-tools/skills/sdd-tasks/` | adapted | Upstream mandates a Review Workload Forecast with exact guard lines and threat-matrix RED-test tasks; local has hierarchical phases only. | SDD execution |
| sdd-apply | `internal/assets/skills/sdd-apply/SKILL.md` (+ `strict-tdd.md`) | `modules/common/ai-tools/skills/sdd-apply/` (+ `modules/strict-tdd.md`) | adapted | Upstream enforces a review-workload decision, status/locator guards, and work-unit evidence; local `modules/` modules must be reconciled with the upstream root file. | SDD execution |
| sdd-verify | `internal/assets/skills/sdd-verify/SKILL.md` (+ `strict-tdd-verify.md`, `references/report-format.md`) | `modules/common/ai-tools/skills/sdd-verify/` (+ `modules/strict-tdd-verify.md`, `references/compliance-matrix-format.md`) | adapted | Upstream requires exact candidate bytes validated by `gentle-ai sdd-verify-validate` before any write; local reports a compliance matrix without a validator. | SDD execution |
| sdd-archive | `internal/assets/skills/sdd-archive/SKILL.md` | `modules/common/ai-tools/skills/sdd-archive/` | adapted | Upstream adds a mechanical copy/move contract with snapshot readback, RENAMED ordering, and a strict-vs-OpenSpec policy; local relies on model-driven merge instructions. | SDD execution |
| sdd-onboard | `internal/assets/skills/sdd-onboard/SKILL.md` | `modules/common/ai-tools/skills/sdd-onboard/` | adapted | Upstream is a 10-phase narrated walkthrough with an executor override; local keeps a phase list in `rules/execution-phases.md`. | SDD execution |

### Shared protocols

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| Persistence contract | `internal/assets/skills/_shared/persistence-contract.md` | `modules/common/ai-tools/skills/_shared/persistence-contract.md` | adapted | Upstream adds research reconciliation, orchestrator state persistence, verify-report admission, sub-agent context rules, and `capture_prompt: false`; local defines the four modes without them. | SDD execution |
| Phase-common protocol | `internal/assets/skills/_shared/sdd-phase-common.md` | `modules/common/ai-tools/skills/_shared/sdd-phase-common.md` | adapted | Upstream sections A-F include locator-based retrieval, review workload guard, and Key Learnings; local only defines Section B retrieval. | SDD execution |
| Engram convention | `internal/assets/skills/_shared/engram-convention.md` | `modules/common/ai-tools/skills/_shared/engram-convention.md` | adapted | Upstream adds the `state` artifact, research/preproposal topics, `capture_prompt`, and `mem_review` lifecycle; local omits them. | SDD execution |
| OpenSpec convention | `internal/assets/skills/_shared/openspec-convention.md` | `modules/common/ai-tools/skills/_shared/openspec-convention.md` | adapted | Upstream adds `state.yaml`, `research.md`, RENAMED delta rules, and nested `apply.guidelines`; local lacks them. | SDD execution |
| Skill resolver | `internal/assets/skills/_shared/skill-resolver.md` | `modules/common/ai-tools/skills/_shared/skill-resolver.md` | adapted | Upstream is index-first and passes exact `SKILL.md` paths; local injects generated compact rules, which ADR 0016 replaces. | Discovery/loading |
| Skill loading protocol | folded into `_shared/sdd-phase-common.md` Section A | `modules/common/ai-tools/skills/_shared/skill-loading.md` | adapted | Local splits loading into its own file with an injected-compact-rules priority; the target contract reads selected originals. | Discovery/loading |
| Return envelope | folded into `_shared/sdd-phase-common.md` Section D | `modules/common/ai-tools/skills/_shared/return-envelope.md` | adapted | Local keeps a standalone envelope whose `skill_resolution` values differ from upstream (`paths-injected` versus `injected`). | Discovery/loading |
| SDD status contract | `internal/assets/skills/_shared/sdd-status-contract.md` | none | deferred | Native `gentle-ai.sdd-status/v2` engine contract; adoption depends on the T19 engine choice. | SDD execution |
| Orchestrator sections | `internal/assets/skills/_shared/sdd-orchestrator-sections.md` | none | deferred | Native dispatcher and runtime-attempt authority sections; engine-dependent. | SDD execution |
| Research lifecycle | `internal/assets/skills/_shared/research-lifecycle.md` | none | deferred | Backs the `sdd-research` collector deferred below. | New methods |
| Review ledger contracts | `internal/assets/skills/_shared/review-ledger-contract.md`, `review-ledger-contract-pi.md` | none | deferred | Ordinary negotiated-review context; local review is `judgment-day` only. | Auxiliary workflows |
| Shared README | `internal/assets/skills/_shared/README.md` | none | deferred | Upstream directory note; no local equivalent needed. | None |

### Authoring and discovery skills

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| skill-creator | `internal/assets/skills/skill-creator/SKILL.md` (+ `references/skill-style-guide.md`) | `modules/common/ai-tools/skills/skill-creator/` | adapted | Upstream is an LLM-first contract targeting 180-450 tokens with required license/author frontmatter and a `docs/skill-style-guide.md`; local documents a `rules/`-split layout and still cites absent helper scripts (finding K2). | Authoring |
| skill-registry | `internal/assets/skills/skill-registry/SKILL.md` | `modules/common/ai-tools/skills/skill-registry/` | adapted | Upstream is already index-first and forbids compact-rule generation, matching ADR 0016; local generates and injects compact rules and writes `.atl/` plus Engram unconditionally, which local persistence policy rejects. | Discovery/loading |

### Inherited auxiliary workflows

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| judgment-day | `internal/assets/skills/judgment-day/SKILL.md` (+ `references/prompts-and-formats.md`) | `modules/common/ai-tools/skills/judgment-day/` | adapted | Upstream is v1.7 with an immutable target, a frozen ledger, bounded two-round re-judgment, and no delivery authority; local is a v1.0 parallel-review flow split across `rules/`. | Auxiliary workflows |
| branch-pr | `internal/assets/skills/branch-pr/SKILL.md` | `modules/common/ai-tools/skills/branch-pr/` | adapted | Policy is equivalent, but upstream inlines branch/conventional-commit rules while local keeps them in `references/`; content must be reconciled, not duplicated. | Auxiliary workflows |
| chained-pr | `internal/assets/skills/chained-pr/SKILL.md` (+ `references/chaining-details.md`) | `modules/common/ai-tools/skills/chained-pr/` | adapted | Upstream adds bounded one-pass slicing and a no-code-golf rule; local omits those hard rules. | Auxiliary workflows |
| work-unit-commits | `internal/assets/skills/work-unit-commits/SKILL.md` | `modules/common/ai-tools/skills/work-unit-commits/` | adapted | Upstream adds runtime-harness evidence, `review_budget_lines`, and generated-golden counting; local has the basic checklist only. | Auxiliary workflows |
| comment-writer | `internal/assets/skills/comment-writer/SKILL.md` | `modules/common/ai-tools/skills/comment-writer/` | adapted | Upstream defaults Spanish comments to neutral/professional; local mandates Rioplatense Spanish/voseo, a deliberate local policy to preserve. | Auxiliary workflows |
| cognitive-doc-design | `internal/assets/skills/cognitive-doc-design/SKILL.md` | `modules/common/ai-tools/skills/cognitive-doc-design/` | adapted | Upstream inlines a default Documentation Shape; local keeps a `references/doc-template.md`. | Auxiliary workflows |
| issue-creation | `internal/assets/skills/issue-creation/SKILL.md` (+ `references/delegated-workflow-actions.md`) | `modules/common/ai-tools/skills/issue-creation/` | adapted | Upstream is a large fail-closed, target-host-verified contract; local is a short label/template workflow. The port must preserve local issue workflow while adding upstream evidence discipline. | Auxiliary workflows |

### Local-only skills

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| nix | none | `modules/common/ai-tools/skills/nix/` | preserved | No upstream counterpart; local-canonical content is retained and later extended by T13. | None |
| dotfiles-coder | none | `modules/common/ai-tools/skills/dotfiles-coder/` | preserved | No upstream counterpart; repository conventions remain local-canonical. | None |

### Deferred upstream-only methods

These upstream v2.9.0 skills have no local equivalent and are not approved for
deployment. They are recorded so no bundle advertises them as supported.

| Item | Upstream path | Local path | Class | Rationale | Required bundle |
| --- | --- | --- | --- | --- | --- |
| sdd-research | `internal/assets/skills/sdd-research/SKILL.md` | none | deferred | Optional source-backed evidence handoff; owned by T22. | New methods |
| skill-improver | `internal/assets/skills/skill-improver/SKILL.md` (+ `references/skill-style-guide.md`) | none | deferred | ADR 0016 keeps audit/update guidance in `skill-creator`; a third owner is rejected without demonstrated need. | New methods |
| go-testing | `internal/assets/skills/go-testing/SKILL.md` (+ `references/examples.md`) | none | deferred | Testing capability work is scoped by T23; not an approved bundle yet. | New methods |
| rdd-defect-workflow | `internal/assets/skills/rdd-defect-workflow/SKILL.md` | none | deferred | Review/receipt workflow tied to the unresolved engine decision. | New methods |
| systemic-issue-triage | `internal/assets/skills/systemic-issue-triage/SKILL.md` | none | deferred | Not in the approved scope of ADR 0017. | New methods |
| hermes-ephemeral-delegation | `internal/assets/skills/hermes-ephemeral-delegation/SKILL.md` (+ `references/tuning-knobs.md`) | none | deferred | Delegation method tied to the unresolved Pi/engine decisions. | New methods |
| gentle-ai-bench | `internal/assets/skills/gentle-ai-bench/SKILL.md` | none | deferred | Not in the approved scope of ADR 0017. | New methods |

Classification totals: 19 local skills classified `adapted`, 2 local skills
classified `preserved`, and 7 upstream-only skills classified `deferred`. No
local skill is classified `deferred`.

## 4. Bundle grouping

The five bundle names are defined in [ADR 0017][adr-0017]. Each bundle
must migrate its producers and consumers together.

| Bundle | Concrete files that must move together |
| --- | --- |
| Authoring | `skills/skill-creator/SKILL.md` and `skills/skill-creator/rules/*`; the `metadata.json` contract across all skills; upstream `skill-creator/SKILL.md` and `skill-creator/references/skill-style-guide.md`. |
| Discovery/loading | `skills/skill-registry/SKILL.md` and `skills/skill-registry/rules/*`; `skills/_shared/skill-resolver.md`, `skills/_shared/skill-loading.md`, `skills/_shared/return-envelope.md`; upstream `skill-registry/SKILL.md`, `_shared/skill-resolver.md`, and `_shared/sdd-phase-common.md` Sections A and D; the SDD and review consumers that read the registry (T18). |
| SDD execution | The ten `skills/sdd-*/` phase skills with their `rules/`, `modules/strict-tdd*.md`, and `references/`; `skills/_shared/persistence-contract.md`, `sdd-phase-common.md`, `engram-convention.md`, `openspec-convention.md`, and `return-envelope.md`; upstream `_shared/sdd-status-contract.md` and `_shared/sdd-orchestrator-sections.md` once the T19 engine is chosen; the SDD commands and `sdd-orchestrator` agent; and the selected engine/validator contract. |
| Auxiliary workflows | `skills/judgment-day/` (with `rules/`), `skills/branch-pr/`, `skills/chained-pr/`, `skills/work-unit-commits/`, `skills/comment-writer/`, `skills/cognitive-doc-design/`, and `skills/issue-creation/` including each `references/` directory; upstream `judgment-day` with `_shared/review-ledger-contract.md` and `review-ledger-contract-pi.md`. |
| New methods | Only approved additions: `sdd-research` (T22), `go-testing` (T23), and the `_shared/research-lifecycle.md` contract, each with a concrete invocation boundary and dependency closure. `skill-improver`, `rdd-defect-workflow`, `systemic-issue-triage`, `hermes-ephemeral-delegation`, and `gentle-ai-bench` are deferred and belong to no deployable bundle. |

## 5. Open questions and blockers

- Engine choice is unresolved (T19). `_shared/sdd-status-contract.md`,
  `_shared/sdd-orchestrator-sections.md`, `sdd-verify-validate`, and
  `sdd-attempt` cannot be classified beyond `deferred` until the pinned
  gentle-ai CLI or a local engine is selected.
- Local SDD skills hardcode `~/.config/opencode/skills/_shared/*` paths. The
  migration to client-neutral canonical paths is owned by T02 and T18 and is a
  prerequisite for every SDD-execution bundle.
- Local `metadata.json` carries only `organization: aytordev|nix` and a date;
  it records no upstream `license`, `author`, or `version`. Upstream
  frontmatter carries `license`, `metadata.author`, and `metadata.version`.
  Provenance reconciliation and validation are owned by T17.
- `skill-creator` and `skill-registry` already contradict ADR 0016 locally
  (compact-rule generation and unconditional project writes). Their adaptation
  is a policy change, not only a content refresh.
- Unverified: the Go sources under `internal/sddstatus` and
  `internal/skillregistry` in the sparse clone were not read for this record.
  Their behavior belongs to T01 and T19 and is not claimed here.
- Low-confidence: the exact wording of the upstream `judgment-day` and
  `issue-creation` port depends on local authority decisions in T10 and the
  issue-first workflow review; the classification as `adapted` holds regardless.

[adr-0017]: ../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md
