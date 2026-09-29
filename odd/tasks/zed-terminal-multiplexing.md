# Zed terminal multiplexing

## Objective and authorization

Let Zed terminals open inside a workspace-named multiplexer session, reusing what this repository already owns instead of adopting the upstream `codemux` binary. Keep Zed's native file finder and project search; do not add global `tasks.json` entries and do not adopt `fff-gpui` (its upstream repository ships no license).

User decisions in this session: support **both** zellij and tmux, selectable through one option; multiplex **by default**, with a fallback to the system shell. User authorized two temporary `openai-codex/gpt-6-astra` agents (writer, verifier) for this work, to be removed afterward.

Prior context: `zed-101-setup` was adopted in PR #207 with codemux and fff-gpui deliberately excluded; see `modules/home/programs/desktop/editors/zed/README.md` and `odd/tasks/` records. Baseline for this feature is `origin/main` after #205 and #207; work happens on branch `feat/zed-terminal-multiplexing`.

Not authorized: commits, push, PR, activation, profile installation, live-file edits, new third-party dependency, or changing the user's login shell.

### External worktree condition (incident)

Another session refreshed `flake.lock` and `flake/dev/flake.lock` in this shared worktree (14 input revisions, including home-manager `0b2f1129` -> `7b4c5ec4`) right after it pulled `main`. This change is external to this feature. User decision: leave it untouched, never stage or commit it, and verify against it. Consequence: this feature is validated against the refreshed home-manager, and the earlier inspection of its Zed module (revision `0b2f1129`) must be re-checked against the currently locked revision before relying on `userTasks`/`extraPackages`/mutable-merge behavior. All Nix commands must pass `--no-write-lock-file` so this worktree's locks are never rewritten.

## Design and scope

- New option `aytordev.programs.desktop.editors.zed.terminal.multiplexer` with values `zellij | tmux | system`, default `zellij`.
- Declarative fallback: when the selected multiplexer capability
  (`aytordev.programs.terminal.tools.{zellij,tmux}.enable`) is not enabled, resolve to `system` so Zed keeps its current shell behavior instead of failing. Both capabilities are enabled by the home common suite today.
- Reuse one session-naming/attach implementation per multiplexer instead of duplicating it in the Zed module. Extract the existing zellij helper into a pure file and add the tmux equivalent; the Zed module consumes those pure helpers by absolute store path, so no `extraPackages`/PATH dependency is needed and no personal absolute path enters the configuration.
- Proven-safe Zed shape: upstream usage proves `terminal.shell = { program = "..."; }` is accepted. If the pinned Zed also accepts `args`, using it is optional. The chosen helper must therefore work with **no arguments** (default action = attach-or-create), or the module must supply arguments through a verified schema.
- Keep `terminal.env.EDITOR` derived from the selected Zed package, and keep the login/system shell untouched.
- Session naming stays compatible with what `zellij-session` already does (workspace basename). tmux requires its own sanitization: tmux rejects `.` and `:` in session names.
- Documented limitation: unlike `codemux`, no multi-window `-2`/`-3` suffix algorithm. Record it rather than silently diverging.

## Tasks and routing

- [x] **T1 — Implement the option, helpers, tests and docs.** Completed by one temporary Astra writer. 12 files changed. Observed intended RED in both `unit-nix-unit` and `integration-home-zed` after the parent corrected the check attribute names, then GREEN, then triangulation (explicit tmux/system, disabled and absent capabilities, nullable tmux package, tmux name sanitization, no-argument invocation, invalid-mode rejection, argument boundaries).
- [x] **T2 — Independently verify the candidate.** Completed by a second temporary Astra verifier: PASS within authorized scope, no blocking defect, `all checks passed!` on both platforms (evaluation only). GREEN reproduced; the historical RED was not independently observed and is not claimed as replayed. Parent also re-ran `integration-home-zed` and read the generated settings as its spot check.
- [x] **T2b — Harden the flagged weak assertions, then re-verify.** User chose to harden before delivery. Writer strengthened three test/check files only (invalid-mode exit code 1; independently derived generated-shell expectations; helper absence for nullable-tmux and absent-capability cases; complete `exec` templates instead of substring matches). The same verifier re-judged them as genuine improvements, found no production change against its T1 observations, and both affected checks passed fresh `--rebuild` execution.
- [ ] **T3 — Delivery.** In progress. User authorized one PR with a size exception and an approved linked issue. Issue [#208](https://github.com/aytordev/system/issues/208) was created and read back with `enhancement` and `status:approved`.

## Verification contract

Strict TDD is ON (explicit user selection earlier in this session; no contrary setting). Runner: `nix build path:.#checks.aarch64-darwin.<check> --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.

Focused checks for this change (the check loader in `flake/dev/checks` exports prefixed attributes, not directory names — corrected after the writer proved the first contract unrunnable, and independently confirmed by listing `checks.aarch64-darwin`): `unit-nix-unit` (pure tests under `tests/`), `integration-home-zed` (real Home Manager evaluation), `integration-module-contract`, `integration-home-portability`, `production-home-integration`, `integration-home-module`. Final: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`. Scoped formatting via `nix run path:.#formatter.aarch64-darwin` over the touched files, plus `git diff --check`.

Required evidence: intended RED before implementation, GREEN after; generated `settings.json` assertions for default `zellij`, explicit `tmux`, explicit `system`, and capability-disabled fallback; no evaluation error when the multiplexer capabilities are absent; unchanged `env.EDITOR`; no finder/task changes; `flake.lock` and `flake/dev/flake.lock` byte-identical before and after the task.

Path claim is scoped precisely: no personal absolute path is *introduced* by this change. `checks/home-zed/default.nix` already contained synthetic `/Users/zed-test` and `/home/zed-test` home-directory fixtures before this work; those stay and are not a regression.

Known risk to settle with a failing test first: `profile.nix` composes selected settings with owned preferences and may only accept scalar leaves. If its leaf handling rejects an attribute-set value, `terminal.shell = { program = ...; }` needs an explicit supported path rather than a workaround.

Normal Nix store/cache outputs are allowed. No activation, no Linux runtime claim, no live Zed file writes.

## Acceptance criteria

1. Option exists, is documented, and defaults to multiplexed-with-fallback.
2. Both helper derivations are reproducible, carry no personal paths, and preserve existing `zns`/`zas`/`zo` behavior.
3. Generated Zed settings select the helper only when that capability is enabled; otherwise `system`.
4. Finder, search, tasks and login shell are unchanged.
5. Touched checks pass; pure tests cover the resolution matrix and tmux sanitization.
6. Documentation states the fallback, the nested-multiplexer implications and the missing multi-window suffixes.
7. No commit, push, PR or activation performed.

## Evidence and next action

- Parent explored: HM zed module supports `userTasks`/`extraPackages`; repo already enables tmux (resurrect/continuum/sessionx) and zellij (`zellij-session` + aliases); neither codemux nor fff-gpui is in nixpkgs; fff-gpui has no license file.
- Incident diagnosed from the worktree itself: reflog shows an external `checkout main` + `pull` + lock refresh; no source files were affected. Locks stay out of scope.

### T1 verification evidence

- Writer observed RED in both corrected runners before implementation: the unit runner rejected the unsupported `terminalShell` value and the Home Manager runner reported `home-zed failed: defaultZellijTerminal`. GREEN followed, then triangulation. Two erroneous test assumptions were corrected during triangulation: unrelated tools remain in minimal homes, and native finder settings already exist.
- `profile.nix` needed no modification: it already composes attribute-set values and applies `mkDefault` at leaves, which retired the known composition risk.
- Focused suite passed before and after formatting: `unit-nix-unit`, `integration-home-zed`, `integration-module-contract`, `integration-home-portability`, `production-home-integration`, `integration-home-module`. `integration-module-contract` needed no edit.
- Scoped formatter ran over the 12 changed files (7 changed); `git diff --check` clean; `nix flake check path:. --all-systems --no-build` reported `all checks passed!` for both platforms (evaluation only).
- Generated settings: default and explicit tmux select the helper store paths; explicit `system` and the disabled-capability fixture emit `"system"`; all cases keep `env.EDITOR` as the fixture Zed executable plus `--wait`.
- Bounded runtime check by the verifier, from a temporary directory named with a dot and a colon: both helpers printed their usage and exited 1 without starting, attaching or killing any real session. The temporary directory was removed; the repository was untouched.
- Locks stayed byte-identical (`8c6c8c81…` and `54d39271…`) before and after, in both the writer's and the verifier's runs.

### Independent verification limits (do not overstate)

1. The generated-JSON shell comparison derives its expected value from the same Home Manager configuration, so it proves serialization rather than independent selection; separate literal/structural assertions carry that coverage.
2. Command tests in `tests/apps/{tmux,zellij}.nix` match substrings and could pass against dead code; the recorder assertion at argument level is stronger but its derivation was served from cache during verification.
3. The isolation assertion compares against the current base configuration, not a frozen pre-change baseline; the inspected diff supplies the historical comparison.
4. Nullable tmux and absent capabilities have evaluation assertions, not separate generated-JSON fixtures; null tmux does not explicitly assert helper absence from `home.packages`.
5. Invalid-mode assertions require failure and usage, not specifically exit 1; the verifier's independent execution confirmed 1 for both.
6. Only invalid-mode branches actually executed. GUI/schema acceptance by a running Zed, interactive multiplexer behaviour, activation, live mutable-setting migration, Linux runtime and clean-store rebuilds of cached checks remain unverified. No formatting check was authorized in the verifier run.
7. Process note: the parent edited this passive record while the verifier was running. The verifier detected and reported it; source, checks and locks were unaffected, and the parent stopped further tree writes until verification finished.

### Hardening addendum

- Hardening touched only `checks/home-zed/default.nix`, `tests/apps/tmux.nix` and `tests/apps/zellij.nix`; production helpers and modules were unchanged, confirmed by the verifier against its own earlier diff.
- Fresh execution evidence: `integration-home-zed --rebuild` checked and passed; `unit-nix-unit --rebuild` first refused with `some outputs of '...nix-unit-check.drv' are not valid, so checking is not possible` — an unrealized-output precondition, not a product defect. After the suite run freshly built that output, one authorized rerun checked and passed. Both outcomes are reported separately and neither is hidden.
- Strict TDD exception, declared rather than manufactured: this was test-strengthening of already-implemented and already-verified behaviour, so no meaningful pre-implementation RED existed. Every affected check was still run.

### CI drift found after the first delivery attempt

- PR 209's first CI run failed on `Check aarch64-darwin`. The failing check was `integration-docs-generation`, not any of the six focused checks: it reported `docs drift for home` and showed the missing `aytordev.programs.desktop.editors.zed.terminal.multiplexer` header.
- Cause: the new option adds a header to the generated home option index, and the golden index in `checks/docs-generation/golden/` was never resynced.
- Why it was missed: the parent's focused verification set omitted `integration-docs-generation`, and the all-system run used `--no-build`, which evaluates outputs without building the check that detects drift. This is a parent contract error, not a writer defect.
- Fix: regenerated with the repository's `just docs-golden` recipe (`nix build .#packages.aarch64-darwin.docs-options`, then copy both indices). Result: exactly one added line in `home.txt`, `darwin.txt` unchanged. Committed as `0e2d2ed`.
- Verified after the fix by building `integration-docs-generation` locally, which now exits 0.
- Lesson recorded: an option-adding change must include the docs golden index in its verification set.

### Delivery record

- Implementation, tests and documentation are committed together in `cd65892` (`feat(zed): multiplex terminals through zellij or tmux`), 12 files, 507 insertions and 35 deletions. Commit hooks passed conflict-marker, deadnix, statix, treefmt and typo checks without bypass. The hook's stash/restore cycle left the two externally refreshed lock files byte-identical, verified by hash afterwards.
- Issue #208 was created and read back confirmed. The pull request, its `type:feature` and `size:exception` labels, and the merge decision remain separate steps; merge and activation are never implied.
