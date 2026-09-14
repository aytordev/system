# Bundle Verification Record (T26)

Maps each of the five migration bundles from
[ADR 0017](../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md)
to its concrete files, source revision(s), effective OpenCode/Pi outputs,
dependency closure, and rollback boundary. This is the "assemble and verify"
record for T26; the task status and acceptance evidence live in the
[implementation plan](implementation-plan.md).

## Frozen inputs

| Input | Revision |
| --- | --- |
| `gentle-ai` engine + SDD skills | `v2.9.0` = `be49554794917ae92a6dc9dbfa2eb3db5cf70084` |
| khanelinix-derived methods | `8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd` |
| Local baseline | `3752d5c43840671467487e9805ef867c2816f5b8` |
| Engram | 1.7.0 (accepted; see `engram-integration-results.md`) |

The `gentle-ai` engine is consumed only through the `aytordev-sdd` adapter
(`pkgs.aytordev.gentle-ai`, ADR 0015 C12 / T27). No skill calls a raw
`gentle-ai` subcommand or its `gentle-ai.*` schemas. The provenance detail for
every adopted item is in [upstream-sources.md](upstream-sources.md); legacy state
and readback are in [legacy-compatibility.md](legacy-compatibility.md).

## Bundle map

Every bundle is deployed to both clients from the same tree:
OpenCode links `programs.opencode.skills` (whole `skills/`), projects
`programs.opencode.commands` and `programs.opencode.agents` from the shared
registry/role policy, and uses `base.md` as context; Pi links `pi.skills`, its
generated phase commands, and the same context. The engine/adapter and the
persistence backends are shared by both clients, so a producer and its consumer
always move together.

### Authoring

| Field | Value |
| --- | --- |
| Concrete files | `skills/skill-creator/**` (SKILL.md + `rules/`); the `metadata.json` contract across all skills; upstream `skill-creator/SKILL.md` (+ `references/skill-style-guide.md`) |
| Source revision | gentle-ai `be4955…` (`skill-creator`, `adapted`) |
| OpenCode output | `programs.opencode.skills` (skill tree); no command/agent |
| Pi output | `pi.skills` |
| Dependency closure | none (authoring guidance only; no `_shared` dependency) |
| Rollback boundary | code: previous Home Manager generation; load-bearing files are plain Markdown/JSON under `skills/`, so reverting the tree restores the prior creator contract. No data rollback (no artifacts written). |
| Class | `adapted` — local `rules/`-split layout; upstream license/author frontmatter not adopted |

### Discovery/loading

| Field | Value |
| --- | --- |
| Concrete files | `skills/skill-registry/**`; `skills/_shared/skill-resolver.md`, `skill-loading.md`, `return-envelope.md`; consumers `sdd-orchestrator`, all `sdd-*` phase skills, review skills |
| Source revision | gentle-ai `be4955…` (`skill-registry`, `_shared/skill-resolver.md`, `_shared/sdd-phase-common.md` A/D; `adapted`); ADR 0016 index-first policy is local |
| OpenCode output | `programs.opencode.skills`; `programs.opencode.agents` (orchestrator + generated roles); `programs.opencode.commands` |
| Pi output | `pi.skills`; generated phase commands; SDD workflow adapter |
| Dependency closure | `_shared` (declared in `skill-registry/metadata.json`); registry index read by every delegating agent |
| Rollback boundary | code: previous generation restores the compact-rule consumer; data: the legacy `.atl/skill-registry.md` is preserved by `aytordev-sdd migrate registry` before regeneration |
| Class | `adapted` — index-first, no compact-rule authority, canonical `SKILL.md` paths |

### SDD execution

| Field | Value |
| --- | --- |
| Concrete files | the ten `skills/sdd-*/` phases (with `rules/`, `modules/strict-tdd*.md`, `references/`); `skills/_shared/{persistence-contract,sdd-phase-common,engram-convention,openspec-convention,closure-policy,research-evidence,execution-modes}.md`; `agents/sdd/sdd-orchestrator.{md,nix}`; `commands/sdd/*.nix`; `pkgs.aytordev.gentle-ai` behind `aytordev-sdd` |
| Source revision | gentle-ai `be4955…` (ten phases + `_shared`; `adapted`); engine `be4955…` `v2.9.0` reused via the adapter |
| OpenCode output | `programs.opencode.agents` (`sdd-orchestrator` authored + generated `sdd-standard`, `sdd-design`, `sdd-archive`, `sdd-review`); `programs.opencode.commands` (`sdd-init`, `sdd-explore`, `sdd-new`, `sdd-continue`, `sdd-ff`, `sdd-apply`, `sdd-verify`, `sdd-archive`, `sdd-onboard`) |
| Pi output | generated `sdd-*` phase commands + bounded child workers; same skills tree; adapter-owned environment |
| Dependency closure | `_shared` (declared in each phase's `metadata.json`); `sdd-phase-common.md` locator model; `return-envelope.md` `sdd-result/v1`; adapter subcommands `status|continue|attempt|verify|compose|closure|archive|migrate` |
| Rollback boundary | code: previous generation restores the prior engine/adapter/skills; data: migrations preserve originals (see `legacy-compatibility.md`). Closure/promotion is never fabricated on rollback. |
| Class | `adapted` — executor-only guards, language-domain contract, and engine validators are reused behind the adapter |

### Auxiliary workflows

| Field | Value |
| --- | --- |
| Concrete files | `skills/judgment-day/**`, `branch-pr/**`, `chained-pr/**`, `work-unit-commits/**`, `comment-writer/**`, `cognitive-doc-design/**`, `issue-creation/**` (each with `references/`) |
| Source revision | gentle-ai `be4955…` (each `adapted`); `judgment-day` upstream `_shared/review-ledger-contract*.md` is deferred, local review is `judgment-day` only |
| OpenCode output | `programs.opencode.skills`; no dedicated command/agent |
| Pi output | `pi.skills` |
| Dependency closure | `_shared` (declared where used, e.g. `judgment-day`); local authority preserved (issue-first, Rioplatense `comment-writer`) |
| Rollback boundary | code: previous generation; these skills write no workflow artifacts, so no data rollback. |
| Class | `adapted` — policy preserved, content reconciled rather than duplicated |

### New methods

| Field | Value |
| --- | --- |
| Concrete files | approved additions only: `skills/bug-diagnosis/**`, `skills/impact-analysis/**`, `skills/lightweight-change/**`, `skills/nix/**` (extended references), `skills/_shared/research-evidence.md` |
| Source revision | khanelinix `8f0ca0…` (diagnosis/impact methods, `adapted`); `nix` preserved local knowledge; `lightweight-change` and `research-evidence` local (T15/T22) |
| OpenCode output | `programs.opencode.skills` |
| Pi output | `pi.skills` |
| Dependency closure | `_shared` for `bug-diagnosis`/`impact-analysis`; `research-evidence` is read by `sdd-explore`/`sdd-propose`/`sdd-design` as an **optional** handoff (`none` stays inline) |
| Rollback boundary | code: previous generation removes the added methods; no persistence artifact is owned by these methods until a phase writes one through its backend. |
| Class | `adapted`/local — no unimplemented upstream method is claimed |

## Deferred / not supported

Recorded so no bundle advertises them. The bundle check asserts these skill
directories do **not** exist:

| Upstream method | Status |
| --- | --- |
| `sdd-research` | deferred as a skill; the optional handoff is `_shared/research-evidence.md` (local adaptation) |
| `skill-improver` | deferred; authoring stays in `skill-creator` |
| `go-testing` | deferred; testing scope is T23 |
| `rdd-defect-workflow` | deferred |
| `systemic-issue-triage` | deferred |
| `hermes-ephemeral-delegation` | deferred |
| `gentle-ai-bench` | deferred |

Also unsupported/deferred: the upstream review-ledger contracts, the native
`sdd-status`/`sdd-orchestrator-sections` schemas (hidden behind the adapter),
consent/review/telemetry/model-routing engine surface, and live-model quality
evaluation. `paused`/`abandoned` closure dispositions are operator-directed and
modeled, not engine-produced.

## Update procedure

A future upstream update compares **previous upstream, new upstream, and local
adaptations**, then advances the pin deliberately. It is not a file copy.

1. **Freeze the candidate.** Record the new revision (commit authoritative; tag
   when applicable) and confirm it is a reviewed commit, not a moving ref
   (`main`/`latest` must not move the target).
2. **Diff three ways.** For each adopted item, diff previous upstream vs new
   upstream, and local adaptation vs both. Re-run the classification
   (preserved/adapted/deferred) in [upstream-sources.md](upstream-sources.md);
   carry rationale and dependency closure forward.
3. **Revalidate affected bundles.** Because bundles move together, run the
   structural checks and the native smoke scenarios for every bundle the diff
   touches: `integration-ai-tools-bundles`, plus the focused
   `unit-ai-tools-{dependencies,loading,sdd-handoffs,sdd-persistence,sdd-research,inventory}`
   and `integration-ai-tools-*` checks, and
   `integration-gentle-ai-engine`. Reconcile any schema/loader drift before
   deployment; a rejected revision means choosing a new candidate and rerunning
   the affected comparisons.
4. **Advance the pin only on evidence.** Update the frozen revision in
   `upstream-sources.md` and this record only after the affected bundles pass.
   Remove a local workaround only when its replacement is demonstrated and its
   removal is in scope.
5. **Record rollback.** State the code rollback (Home Manager generation) and the
   data rollback (preserved originals / not adopting derived output) separately,
   per `legacy-compatibility.md`.

The engine pin lives in `packages/gentle-ai/package.nix`; the adapter is the only
call surface, so an engine bump is a `package.nix` change plus a re-run of
`integration-gentle-ai-engine`, not a skills rewrite.

## Verification

Deterministic check (pure contract):

```sh
nix build .#checks.aarch64-darwin.integration-ai-tools-bundles \
  --override-input secrets path:./checks/fixtures/secrets --no-link
```

It proves bundle file coverage, `sdd-result/v1` + locator documentation for
every SDD phase, archive's C11 closure gate, optional research, the index-first
registry, the absence of compact-rule authority and hardcoded
`~/.config/opencode` paths, the absence of the deferred upstream methods, and
that the T25 legacy fixtures stay distinct from the current schema.
