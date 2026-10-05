# Gentle upstream v4 migration

## Goal and authority

Migrate Civislend to Pi **1.0.0**, Nix operator Gentle AI **4.0.0**, and native Gentle Shell **`npm:gentle-pi@4.0.0`**. Nix and the native package-local engine have separate owners.

The user authorized source changes, live Nix activation (including pending main changes/database tooling), exact native installation and `sync`. The user subsequently explicitly confirmed **strict TDD and local feature-branch commits**. No push/PR, model/provider changes, GitHub permissions, historical review cleanup, secret migration or database connections. Pi/Pen restart remains manual.

Worktree: `../system-gentle-upstream`; branch: `feat/gentle-upstream-v4`; base/review boundary: `9ca3827b21d8d770e71b13cf7a79222208ad25a6`. Preserve the original clean checkout at `948d142c` and the database worktree at `e548f029` with its dirty progress and frozen authority.

Active baseline: Pi 0.87.1, Node 24.20.0, Nix CLI/native Shell/bundled engine 3.7.0. Main already pins nixpkgs `a7868a727837f3c09cee2ce0ca671c76b1589fed` with Pi 1.0.0; no overlay or lock bump is needed. Previous live Darwin system: `/nix/store/dmz79x8gdjip1j8hh09zqdsa7qxdb0rf-darwin-system-26.11.4cff07d`, generation 44; recheck before activation. Actual integrated Home Manager gcroot remains unverified.

## Execution and rollback contract

- ODD, delegated direct; one sequential writer. Parent owns this document, its full Engram mirror `odd/gentle-upstream-v4/tasks`, reconciliation and commits.
- TDD **on**, source **explicit user choice for this migration**. Observe RED before pin changes, then GREEN/refactor. Do not restore v4's retired Strict TDD selector or SDD/OpenSpec workflow.
- Exact RED/GREEN runner: `nix build path:.#checks.aarch64-darwin.integration-gentle-ai-engine --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.
- Docs runner: `nix build path:.#checks.aarch64-darwin.integration-ai-tools-docs-links --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.
- Full evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`.
- Tests use fixture secrets; production build/switch use the existing real host input normally. Never activate fixture identities or print credentials.
- Source surfaces: `packages/gentle-ai/package.nix`, `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`. Preserve overrides and module ownership; no Nix writer for native settings/model profiles.
- Native runtime replacement is last. Pi must satisfy Shell 4's prerequisite before `sync` retires `pi-mcp-adapter` for built-in MCP. Preserve user-owned/unknown assets and companion package preferences.
- This session loaded 3.7.0. After replacement, do not spawn agents or invoke old capture tooling; hand off restart explicitly.
- Snapshot configuration/package state privately (owner-only) and retain old system/package rollback evidence before rollout. Noninteractive sudo requires a password; use an interactive user handoff, never ask for the password or bypass privileges.
- RDD enabled: assess exact work-unit candidates through the facade, inspect before START and obey fresh provider bindings/consent. Existing Pi/database lineages are not approval and remain untouched.
- Forecast 150–250 authored diff lines including tests/docs/tracking, no option golden changes expected. Delivery strategy `ask-on-risk`; no publication authorized. Record checks and local commits before fully closing units.

## Tasks and evidence

- [ ] **GU-1 — Update pins, regression checks and component docs.** Delegated `gentle-ai-worker` (multiple nontrivial files, mapper already completed). Verify four official archive hashes/layout; test-first version/runtime coverage; package 4.0.0 and docs for native pin/Pi/MCP/ODD-only prerequisites; focused checks and scoped format. Commit: pending immediately after verified source preparation. State: checks verified; local closure pending commit.
- [ ] **GU-2 — Verify the coordinated stack and build Civislend.** Independent `gentle-ai-verify` for expensive external runtime/install/build checks. Isolated Pi 1.0.0 + Shell/engine 4.0.0 without credentials, real MCP connections or user-home writes; applicable evaluation/checks/native candidate review; actual production build through repository entry point. Record exact binaries and limitations. Evidence commit: pending.
- [ ] **GU-3 — Snapshot privately, activate and read back Nix.** Parent-approved operational execution; verifier handles readback. Review closure delta, retain rollback generation/backups, repository switch entry point, prove live system and integrated Home Manager plus exact Pi/operator versions. Await interactive sudo when needed. Evidence commit: pending.
- [ ] **GU-4 — Install native Shell, sync and verify restart handoff.** Final bounded operational transaction after all prerequisites. Preserve preferences/models, exact `npm:gentle-pi@4.0.0`, documented sync order, bundled engine/MCP migration readback; no blind companion deduplication. Mark restart-dependent checks pending rather than claim reload. Evidence commit before runtime replacement; final private evidence/mirror handoff as needed.

## Acceptance

Exact versions (no bare latest/development head); real default CLI regression without breaking overrides; unchanged unrelated locks/overlays; preserved user state/secrets/old authority; live Nix/HM proof before native migration; installed native package/engine 4.0.0; MCP/startup-header compatibility proved or explicitly pending restart; report every failed, skipped, blocked check. No publication.

## Current result / next action

GU-1 source checks verified. Writer observed RED `AI ownership failures: packageVersion` while the default pin remained 3.7.0, then GREEN with exact `gentle-ai 4.0.0` from the real Darwin binary. Engine/docs checks and `git diff --check` passed independently. Package overrides/ownership preserved. Authoritative four archive pins: tagged publisher installer `https://raw.githubusercontent.com/Gentleman-Programming/gentle-shell/v4.0.0/scripts/gentle-ai-installer.mjs`; local Nix hash/build verified Darwin arm64 bytes and root `LICENSE`/`gentle-ai` layout. Foreign-architecture runtime/signatures were not verified. Darwin post-processing changes the installed binary hash; no raw/store byte-fidelity claim.

Formatting incident: writer's claimed success for `nix fmt -- --check` was invalid; treefmt rejects that flag (exit 1). Separate read-only incident verification used the exact repository treefmt 2.6.0/config on temporary copies with `--tree-root TEMP --ci`: exit 0, two Nix files, zero changes; Markdown unmatched. Source unchanged by verification. Proper repository entry point is `just fmt-check` (`nix run .#formatter.aarch64-darwin -- --ci path`). First ASSESS was unassessable due to untracked progress; required independent verification completed. Check output: `/nix/store/qq2x8fpql1c8qi6dim9nd04z724y8qgq-ai-native-ownership-check`; CLI: `/nix/store/gqf2jgrslab5b72j19ibiz6w4r68l1hd-gentle-ai-4.0.0`.

Next: exact four-file local source work-unit commit, then committed candidate assessment/native preflight and GU-2. No activation, native installation, synchronization, model or old-lineage change. `sudo -n true` requires interactive authentication; native migration remains gated on live Pi 1.0.0.
