# Feature: pi-agent-model-profiles

## Objective

Serve the `opensource` gentle-pi agent-model profile from the system, so
`darwin-switch` is the only action needed: no profile creation by hand in the
`/gentle:profiles` panel and no manual `apply`.

## Problem

gentle-pi profiles are created and applied from the TUI. On a fresh machine, or
after any reset of the runtime files, the routing the user expects (26 roles on
`nan/deepseek-v4-flash`, `nan/glm5.3-flash`, `nan/qwen3.8-flash`) has to be
rebuilt by hand, and nothing in the repository states which routing the machine
should run.

## Why

- The routing is a hard requirement of the setup, not a preference of one
  session: the orchestrator, every SDD/judgment-day/review role and the review
  relay all read it.
- Every runtime file involved is a mutable JSON document that a Nix store symlink
  cannot own (see Constraints), so leaving it to the TUI means it is destroyed by
  any reset and can never be reviewed as a diff.

## Scope

- Declare the profile in the repository as the *export envelope* the panel also
  imports (`kind: "gentle-pi.agent_model_profile"`), so the committed artifact is
  the same one a human can hand to `/gentle:profiles` → `i`.
- Publish the global store (`~/.pi/gentle-ai/profiles.json`) with the declared
  profiles and the `active` marker, preserving profiles created at runtime.
- Materialise the effective routing that `apply` would produce:
  `~/.pi/gentle-ai/models.json`, `model_profiles` in `~/.pi/agent/subagents.json`,
  and the orchestrator keys in `~/.pi/agent/settings.json`.
- Enable the module from the development suite, like every other AI tool.

## Non-goals

- Not writing agent frontmatter (`~/.pi/agent/agents/*.md`): it is a managed
  asset with recorded hashes, and `subagents.json` takes precedence over it
  (`extensions/gentle-ai.ts:2174`), so the materialised routing works without it.
- Not touching `~/.pi/agent/models.json` (provider catalogs): that file is
  Home Manager-owned already (`provider.nix`) and the profile never writes it.
- Not declaring per-repository pins: a pin is per clone
  (`<git-common-dir>/gentle-ai/profile-pin.json` or
  `<worktree>/.pi/gentle-ai/profile.json`) and it deliberately excludes the
  orchestrator (`lib/agent-profile-pin.ts:14-21`).
- Not shipping `profiles.export.json`; the store is written directly.

## Constraints

- **The store is runtime-written and cannot be a symlink.** `profiles.json` is
  written by the Pi extension through a sibling temp file plus `renameSync`
  (`lib/agent-profiles.ts:521-566`), with no locking, so a store symlink is
  replaced by a regular file at runtime and re-linked (discarding that write) on
  the next switch. Publication must be an idempotent activation merge.
- **`active` alone materialises nothing.** The only writers of the effective
  routing are the panel's apply (`models.json` at `extensions/gentle-ai.ts:2043`,
  `subagents.json` + frontmatter at `:2753-2795`, orchestrator keys at
  `lib/profiles-orchestrator.ts:107-125`) and per-repository pins. There is no
  re-application on `session_start`; the only `setActiveProfile` outside the panel
  is the importer (`extensions/gentle-ai.ts:4231`).
- **Shapes.** Store: `{kind:"gentle-pi.agent_model_profiles",version:1,
  profiles:{<name>:<config>},active?}`, key order fixed, 2-space indent, trailing
  newline (`serializeProfilesFile`). Routing config: `{<agent>:{model?,thinking?}}`
  with `thinking` in the 7-level set (`lib/model-routing-authority.ts:4-20`).
  `subagents.json` carries the same map under `model_profiles`, with the thinking
  level stored as `effort` (`extensions/gentle-ai.ts:2500-2505`). Orchestrator:
  `settings.json` keys `defaultProvider`/`defaultModel`/`defaultThinkingLevel`,
  split from one `provider/model` id (`lib/profiles-orchestrator.ts:27-31,42-52`).
- **Provider-review roles are excluded from `subagents.json` on purpose**
  (`review-refuter`, `review-validator`: `PROVIDER_REVIEW_ROLES`,
  `extensions/gentle-ai.ts:2626-2630`) because the review relay reads them from
  `models.json`. They stay in the store, in `models.json`, and never become
  `model_profiles` entries.
- **Agent ids are an open set** (`SAFE_AGENT_NAME_PATTERN`,
  `lib/model-routing-authority.ts:29`): an unknown id is kept in the store and
  silently ignored at materialisation. The declared payload includes three ids
  with no shipped agent definition: `sdd-sync` (retired), `review-refuter` and
  `review-validator` (provider roles). They are kept: the store is the profile's
  own record and `review-refuter`/`review-validator` are live review roles.
- **The package does not validate model ids against providers at write time**; a
  missing provider or model only fails at launch. Keep the declared ids in sync
  with `provider.nix` (`nan` provider: `deepseek-v4-flash`, `glm5.3-flash`,
  `qwen3.8-flash`, `mimo-v2.5`, `gemma4`, `qwen3.6`).
- **Home Manager becomes authoritative over three runtime routing files.** A
  manual `apply` (or `/gentle:models` edit) is reverted by the next
  `darwin-switch`. The module documents this and offers `materialize = false` for
  the seed-only behaviour.
- **Option ownership guard.** `checks/gentle-ai-engine/default.nix:113` asserts
  the exact option set of `tools.pi`, so the new sub-option must be allowlisted
  (the same breakage CSH-13 fixed for `startup-header`).
- **Option docs golden.** New option paths change
  `checks/docs-generation/golden/home.txt`, which must be regenerated with the
  `docs-options` build (the check text that says `golden-update` is stale).

## Tasks

- [x] **PAMP-1** Add the profile artifact and the module. Commit the export
  envelope verbatim under
  `modules/home/programs/terminal/tools/pi/profiles/opensource.json`, and add
  `agent-profiles.nix` with options `enable`, `profiles`, `active` and
  `materialize`, validating the envelope (`kind`, `version`, name, `config`) at
  evaluation time.
  Acceptance: `nix eval` renders the store, the routing map, the
  `model_profiles` fragment and the orchestrator keys; a malformed envelope fails
  evaluation with a named error.
- [x] **PAMP-2** Publish the store through an idempotent activation merge that
  preserves runtime-created profiles and sets `active` only when configured.
  Acceptance: two consecutive runs against a scratch copy leave the file
  byte-identical, a pre-existing foreign profile survives, and an existing
  `active` marker for another profile is replaced only when configured.
- [x] **PAMP-3** Materialise the effective routing through three idempotent
  activation merges: `~/.pi/gentle-ai/models.json` (declared agents win, foreign
  keys preserved), `model_profiles` in `~/.pi/agent/subagents.json` (excluding
  `orchestrator` and the provider-review roles), and the orchestrator keys in
  `~/.pi/agent/settings.json` (every unrelated key preserved, including the
  banner filter published by `startup-header.nix`).
  Acceptance: second run is a no-op; `packages`, `theme`, `tuiMode` and other
  agents' entries survive; `review-refuter`/`review-validator` never appear in
  `model_profiles` but do appear in `models.json`.
- [x] **PAMP-4** Wire it in: import the module from
  `pi/default.nix`, enable it from the development suite with
  `pi."agent-profiles".enable = mkDefault cfg.aiEnable`, and allowlist the option
  in `checks/gentle-ai-engine/default.nix`.
  Acceptance: `integration-gentle-ai-engine` and `integration-module-contract`
  pass; the evaluated option reports the profile and `active = "opensource"` for
  `wang-lin`.
- [x] **PAMP-5** Regenerate `checks/docs-generation/golden/home.txt` and confirm
  the diff contains only the new option paths.
  Acceptance: `integration-docs-generation` passes and `darwin.txt` is unchanged.
- [x] **PAMP-6** Verify end to end: build the system, run the generated
  activation merges against scratch copies, and drive a real Pi in a pty with the
  materialised files to confirm the panel reports the profile and its routing.
  Acceptance: recorded evidence per step, plus `nix build
  .#darwinConfigurations.wang-lin.system` succeeding.

## Verification evidence

Parent-owned, all run on this machine on 2026-09-22:

- **Rendered documents** (`nix eval --json`
  `…tools.pi.agent-profiles.rendered`): store has one profile (`opensource`, 26
  roles) with `active = "opensource"`; `models` has 25 role keys and no
  `orchestrator`; `subagents.model_profiles` has 23 keys and contains neither
  `orchestrator` nor `review-refuter` nor `review-validator`; `orchestrator` is
  `{"defaultModel":"deepseek-v4-flash","defaultProvider":"nan","defaultThinkingLevel":"high"}`.
- **Evaluation-time validation**: eight malformed envelopes/entries (name
  mismatch, unsupported entry key, model charset, thinking level, empty config,
  orchestrator without a `provider/model` pair, `active` not declared,
  `materialize` with a null `active`) each fail closed with the
  `pi agent-profiles (<profile>): ` prefix.
- **System build**: `nix build .#darwinConfigurations.wang-lin.system` ->
  `0k51xvyfrqi3qp76p3d2d4pv52jwcmf7`; its home-manager generation
  `0y0k3mbq1bsihysyjamlw1zv4gi57115` carries `piAgentModelProfiles` at line 507
  and `piStartupHeaderBannerFilter` at line 605, so the two `settings.json`
  writers run in a defined order.
- **Both `settings.json` writers on one file** (scratch copy of the real file,
  both activation entries executed): `packages` with the `!startup-banner.ts`
  filter, `theme`, `tuiMode`, `lastChangelogVersion` and the three orchestrator
  keys all survive; a second run of both entries is byte-identical
  (`sha256 c12420a3…` for settings, `e2ac8567…` store, `3402f0ef…` models,
  `aba1aab7…` subagents), i.e. no churn.
- **Invalid-JSON guard**: a target containing `{ this is not json` stays
  byte-identical (`0fb1db0e…`) and the entry warns on stderr.
- **Real profile + live Pi** (the entry executed against the real files, backups
  in `/tmp/pamp-backup-*`): a real Pi in a 45x150 pty reported
  `deepseek-v4-flash · high · opensource` in the footer and `Profile opensource`
  in the gentle-shell status widget, our own header panel rendered
  `model nan/deepseek-v4-flash · high` and `profile opensource`, and gentle-pi
  itself logged `applied saved model config to 20 agent(s)`. After that session,
  `profiles.json` and `models.json` were unchanged, all four targets kept their
  bytes and mtimes when the activation ran again, and the extension wrote the
  agent frontmatter itself (the file this module deliberately does not touch).
- **Nix checks**: `integration-docs-generation`, `integration-module-contract`,
  `integration-home-module` and `integration-gentle-ai-engine` pass. The docs
  golden diff is 4 insertions (only the new option paths) and `darwin.txt` is
  unchanged. The repository pre-commit suite passes; note that its `treefmt`
  applies the pinned alejandra (not the store build) and its statix step rewrote
  `{model = entry.model;}` into `inherit (entry) model;`, and that a repeated
  `pi.` key in the development suite had to be nested so `statix` passes.
- Not done: no pull request yet. The repository requires an approved issue for
  every PR (`status:approved` plus exactly one `type:*` label), which is a human
  triage decision.

## Decisions

- **Full effective routing, not just a seed** (user's choice): the system
  declares the store *and* the materialised routing, so a start after
  `darwin-switch` needs no manual `apply`. The orchestrator keys are included, so
  the default provider/model/thinking of every new session come from the profile
  (`defaultThinkingLevel = high`).
- **Export envelope committed verbatim** (parent's choice): the file the user
  pasted stays byte-identical in the repository, so it doubles as the artifact a
  human can import through `/gentle:profiles` → `i`, and the module derives the
  store entry from it instead of duplicating the data in Nix.
- **`subagents.json` over agent frontmatter** (evidence-driven): the launch path
  reads `subagents.json` model profiles first and the frontmatter otherwise, so
  the routing can be served without touching hash-tracked managed assets.
- **New branch and PR, not the startup-header fix** (user's choice): the
  header-slot bugfix is already in `fix/pi-startup-header-slot`; this is a
  configuration feature and mixing them costs the reviewer focus.

## Progress

Branch `feat/pi-agent-model-profiles`, from `main`.

Work unit 1 — commit `76710f7 feat(pi): serve gentle-pi agent-model profiles
from the system`, 6 files, 451 insertions, 5 deletions:
`modules/home/programs/terminal/tools/pi/agent-profiles.nix` (new, 326 lines),
`modules/home/programs/terminal/tools/pi/profiles/opensource.json` (new, the
envelope verbatim), `modules/home/programs/terminal/tools/pi/default.nix`,
`modules/home/suites/development/default.nix`,
`checks/gentle-ai-engine/default.nix` (option allowlist) and
`checks/docs-generation/golden/home.txt`.
