# Feature: pi-gui-environment-stable-command

## Authorization and baseline

User reported a hard failure and then authorized the fix ("Solucionalo"). No
activation, rebuild, app restart, commit, push, PR or merge authorized by that
request; each remains a separate decision.

Incident: every `subagent_run` in a live session failed with

```
pi exited with code 1 before agent_settled; stderr:
Error: Failed to load extension ".../gentle-pi/extensions/quiet-tools.ts":
Failed to load extension: (0, _piCodingAgent.createCodemodeExtension) is not a function
```

Root cause is environmental, not source: the long-lived GUI host (`herdr`,
launched by the user LaunchAgent at login) had captured
`GENTLE_PI_AGENTS_PI=/nix/store/il4y2236i8bcrmjpqs27zbdq8f10bg3m-pi-coding-agent-0.87.1/bin/pi`
and propagated it to every shell and `pi` it spawned, while the freshly
resolved `pi` on PATH was 1.0.3.

Verified facts (direct execution, not inference):

- `pi` 0.87.1 `dist/index.js` does not export `createCodemodeExtension` at all
  (`typeof` → `undefined`; the build has no `dist/extensions/codemode/`).
- `pi` 1.0.3 exports it (`typeof` → `function`).
- gentle-pi 4.0.0 `extensions/quiet-tools.ts:815` imports it at module top
  level, so the whole extension throws and the child exits 1; gentle-pi's
  declared peer floor is `@earendil-works/pi-coding-agent >=0.99.1`.
- `piCommand()` (`gentle-pi/lib/agents-runner.ts:276-285`) prefers
  `GENTLE_PI_AGENTS_PI` over `process.execPath` + `argv[1]` over bare `pi`.

Source defect in scope: `modules/home/programs/terminal/tools/pi/gui-environment.nix`
published `lib.getExe' cfg.package "pi"`, an **absolute version-pinned store
path**. A long-lived GUI process captures the override once and never re-reads
it, so after a `pi` upgrade the tree keeps an older build that is still
executable: the pin cannot self-correct, and the failure surfaces far from its
cause (here, inside a subagent extension load). Baseline: `main` at
`e537e7bf`, branch `fix/pi-gui-environment-stable-command`. Pre-existing
uncommitted `flake.lock` and `flake/dev/flake.lock` modifications belong to the
user and are never staged by this work.

Observed on host `civislend`: `config.home.profileDirectory` =
`/etc/profiles/per-user/avicente`, and `bin/pi` there is a stable symlink
resolving to the currently built `pi` (1.0.3); `useUserPackages = true` is set
repository-wide in `libraries/system/common/default.nix`.

## Implemented design

Publish the **stable Home Manager profile indirection**
`${config.home.profileDirectory}/bin/pi` instead of the configured package's
store path. `home.packages = [cfg.package]` (sibling `default.nix`) guarantees
that path is the configured `pi`, and every activation re-points the profile in
place, so a GUI process that captured the override once keeps resolving the
current `pi` across upgrades with no republish.

Unchanged: opt-in gating (Pi + `guiEnvironment.enable` + Darwin + HM launchd),
override-only publication (never PATH), whitespace rejection, private 0700/0600
atomic state, ownership rules (never adopt a same-valued foreign publication),
foreign-override preservation, exact-match disable cleanup, bounded
ownership-token lock, isolated activation fragments, dry-run inertness, and
cleanup reachability. Because the published value is now stable, the
update/reconcile branch only fires for a pre-existing versioned publication.

Deliberately out of scope: validating the installed `npm:gentle-pi` peer floor
at activation. No repository file pins `npm:gentle-pi` (see
`odd/tasks/gentle-upstream-v4.md`), pi ownership stays with the nixpkgs/profile
generation, and a runtime read of the npm tree from an activation script would
add a second writer over a runtime-owned path.

## Tasks

- [x] PGE-S1: Extend `checks/pi-gui-environment/default.nix` with the stable-command contract, the store-path prohibition and the upgrade/staleness regression; observe RED against the current version-pinned publication. Route: inline (delegation unavailable, see below).
- [x] PGE-S2: Publish the stable profile command in `gui-environment.nix` and align `README.md`; observe GREEN on the focused check. Route: inline (same reason).
- [x] PGE-S3: Scoped `nix fmt`, `git diff --check`, focused check re-run and evidence recording. Route: inline (same reason).

Delegation is unavailable in this session: every subagent child inherits the
stale `GENTLE_PI_AGENTS_PI` pin documented above and dies at extension load, so
the mandatory delegation triggers are honored as an explicit, reported
exception rather than silently routed inline. Resolution requires a relaunch of
the GUI process tree (restart `herdr` or a new login session), which is a user
action; starting `pi` with `env -u GENTLE_PI_AGENTS_PI pi` removes the stale
value and lets `piCommand()` fall back to the parent's own entrypoint.

## Verification evidence

Strict TDD, focused runner:
`nix build path:.#checks.aarch64-darwin.integration-pi-gui-environment --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`

- Observed RED before the adapter was corrected (`f2ra24y8pzlq6hddgs3d1n1a85s8w8ff-pi-gui-environment.drv`):
  `publisher does not reference the stable profile command /Users/pi-gui-ci/.nix-profile/bin/pi`.
- Observed GREEN after the fix (`1q8r0msxqlv79cbq9931xd2kax7ijzq8-pi-gui-environment.drv`): 32 PASS
  lines, including the two new branches `PASS published command is the stable profile indirection`,
  `PASS captured override follows an upgrade without republishing`, and
  `PASS publisher references the stable profile command via ...`, alongside the 30 unchanged
  lifecycle/ownership/lock/rollback branches.
- Linux guard: `nix eval --raw path:.#checks.x86_64-linux.integration-pi-gui-environment.drvPath` →
  `/nix/store/g15whr7959sx5cy3qdgcmp9dxp9403b5-pi-gui-environment-linux-guard.drv`.
- Real host config, evaluation and derivation only, no activation: the civislend publisher
  derivative builds and its script reads `desired=/etc/profiles/per-user/avicente/bin/pi`; the only
  `nix/store` string left in it is its own bash shebang, so no version-pinned `pi` remains.
  `config.home.profileDirectory` evaluates to `/etc/profiles/per-user/avicente` on civislend, where
  `bin/pi` is the stable symlink the shell itself resolves.
- `nix fmt` over the three changed files: 0 changed. `git diff --check`: clean.
- Not verified: live inheritance and a real subagent spawn after the relaunch (user actions); no
  activation, no `nix flake check`, no full flake build, no commit.

## Remaining work and delivery

Source work unit committed as `821dabe5` (`fix(pi): publish a stable profile command for the GUI
override`) on branch `fix/pi-gui-environment-stable-command`, five files, and pushed to `origin`.
Commit hooks green: conflict-marker, deadnix, statix, treefmt, typos. The pre-existing uncommitted
`flake.lock` and `flake/dev/flake.lock` changes are the user's and were deliberately left unstaged.

Pull request: not created. `gh` has no session on this host
(`To get started with GitHub CLI, please run: gh auth login`) and no token is present in the
environment, so the remote write was impossible rather than refused; the prepared body is at
`/tmp/pr-body-pi-gui-stable-command.md`. Target policy for this repository is path-based
auto-labeling only (`.github/labeler.yml`): it enforces neither issue linkage nor a `type:*` label,
so no issue reference is invented and no protected label is requested. Base is `main`.

Live remediation remains a user action and is independent of this source change: an already-running
GUI process tree keeps its captured value until relaunched (restart `herdr`, open a new login
session, or start `pi` with `env -u GENTLE_PI_AGENTS_PI pi`). After one relaunch with the new
published value, later `pi` upgrades are followed without any republish. Merging or merging plus
activating are separate decisions; no activation was performed for this work.
