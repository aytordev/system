# Feature: gentle-shell-launcher-upgrade

## Objective

Advance the native-owned **Gentle Shell** package (npm `gentle-pi`) from the
pinned **3.4.0** to **3.5.1**, the current latest, so the upstream
`gentle-shell` launcher exists on this machine, and bring the repository's Shell
version statements back in line with the machine.

## Problem

The operator updated the public Gentle AI CLI to 3.6.0 and still could not run
`gentle-shell`. Investigation produced four facts, and none of them was the CLI:

- `gentle-shell` is **not** a `gentle-ai` command. CLI 3.6.0 lists no `shell`
  subcommand, `gentle-ai shell --help` reports `unknown command "shell"`, and
  `strings` over the shipped binary contains no `gentle-shell` occurrence. The
  two components are owned separately: Nix owns the public CLI, the native
  installer owns Shell.
- `gentle-shell` is a `bin` published by the npm package `gentle-pi`.
- The **published 3.4.0 tarball ships no `bin/` at all** — 537 files, `bin: []`,
  and the installed `node_modules/gentle-pi` has no `bin/` directory. Its own
  release notes announce the launcher, so this is an upstream packaging gap, not
  a consequence of our pin. The bin first ships in **3.5.0** (548 files,
  `bin/gentle-shell.mjs`).
- `decideTakeOver` in the launcher returns `false` for an `npm`-kinded
  declaration, so `gentle-shell --link` does **not** take over extension loading
  for our npm-pinned spec: it runs `pi` against the same home. The launcher's
  default isolated home (`~/.gentle-shell/agent`, absent on this machine) would
  carry none of the Nix-managed surface.

The repository states the Shell pin at 3.4.0 in
`modules/common/ai-tools/README.md`. Bumping the runtime without updating those
statements would leave the repository reporting a state the machine no longer
has, which is the inconsistency this feature exists to remove.

## Why

- The operator wants the launcher available, and wants the repository consistent
  with the machine.
- 3.5.1 is the current latest. A versioned npm spec is skipped by `pi update`,
  so the pin is what keeps Shell from drifting; that mechanism is unchanged.
- The alternative — leaving the repository at 3.4.0 — is already consistent and
  delivers nothing the operator asked for.

## Scope

- **Runtime:** `pi install npm:gentle-pi@3.5.1`, then `gentle-ai sync`.
- **Repository:** the Shell version statements in
  `modules/common/ai-tools/README.md`; the two illustrative
  `npm:gentle-pi@3.4.0` examples in `startup-header.nix` and
  `startup-header/index.ts`, made version-neutral; this task file.

## Non-goals

- Not touching the `gentle-ai` CLI pin (already 3.6.0) or Engram.
- Not adopting `gentle-shell` as the default launcher. Its isolated home is not
  our managed Pi profile, so it is an auxiliary entry point, not a replacement.
- Not touching the RDD switch.
- Not packaging Shell as a Nix derivation: `modules/common/ai-tools/README.md`
  assigns Shell to the native installer, and a derivation would fight Pi's
  package manager for the same tree.
- Not adding a declarative pin for the npm spec. It lives in the runtime-owned
  `~/.pi/agent/settings.json`.

## Constraints

- **`settings.json` is runtime-owned and `pi install` rewrites it.** The
  `!startup-banner.ts` filter can be dropped in that rewrite, which is the one
  real risk this upgrade carries. Two layers cover it: the activation merge in
  `startup-header.nix` (matcher already generalized to `^npm:gentle-pi(@.+)?\z`)
  and the runtime heal `ensureGentlePiBannerFilter`
  (`/^npm:gentle-pi(@.+)?$/`). Back up the file first regardless.
- **The install mutates a live installation.** It replaces
  `~/.pi/agent/npm/node_modules/gentle-pi` and rewrites `settings.json` while a
  Pi session is running. The previous feature verified its pin with a *fresh* Pi
  process; that is still the verification to repeat, and the operator was warned
  to restart Pi afterwards.
- **npm's script gate blocks gentle-pi's `postinstall`** on this machine
  (recorded in `gentle-stack-upgrade.md`), so the package-local Gentle AI runtime
  is not provisioned by it. Unchanged by this feature.
- **`~/.pi/agent/bin` is not on the operator's login PATH.** Pi prepends its own
  `getBinDir()` (`<agent dir>/bin`) only for the processes it spawns, and Home
  Manager does not publish that directory. `gentle-shell` is therefore reachable
  inside Pi, and outside it only by absolute path or after an explicit
  `home.sessionPath` entry.
- **`checks/gentle-ai-engine` has no automated test for the runtime half.**
  Extension loading is verified by observation, not by a runner.

## Decisions

- **3.5.1, not 3.5.0** — 3.5.1 is the current latest and its changes over 3.5.0
  are launcher fixes (`--link` against a path-declared gentle-pi, loose
  extensions during take-over) plus a README rewrite. Neither surface is used by
  this machine, but there is no reason to pin a superseded patch.
- **Continue on `chore/upgrade-gentle-stack`** — the branch has no upstream and
  was never pushed, and this is the same feature (the Gentle stack) continued.
  A separate branch would split one review slice in two for no gain.
- **Make the source comments version-neutral instead of re-pointing them at
  3.5.1.** Both sites read "a version-pinned variant such as
  `npm:gentle-pi@3.4.0`": they illustrate a *shape*, not the current state.
  Neutralizing them is the same diff size and never goes stale again. Rewriting
  them to a new literal would leave the same trap for the next bump.
- **Update the repository only after the runtime action is verified.** Writing
  3.5.1 into the README first would make the repository describe a state the
  machine did not have yet, which is the defect being fixed.
- **Leave the `Shell 3.4's packaged names` sentence in place if the names are
  unchanged.** Verified: `gentle-pi` 3.5.1 still declares
  `name: gentle-ai-skill-creator` and `name: gentle-ai-skill-registry`, and still
  excludes the literal `skill-registry` from its registry. Only the version
  label needs to change.

## Progress

Branch `chore/upgrade-gentle-stack`, from `main` at `9475473`. Worktree clean at
start; five prior commits on the branch from the previous feature.

### Evidence gathered before writing

Structural comparison of the two published tarballs (`npm pack`, then
`diff -rq`), not a reading of release notes:

- **Zero files removed, zero renamed.** 537 files -> 548 files.
- **11 files added:** `bin/gentle-shell.mjs`, `lib/gentle-shell-launcher.ts`,
  `runtime/gentle-shell-launcher.mjs`, `lib/rpc-host.ts`,
  `lib/agents-rpc-publisher.ts`, `docs/gentle-agents-activity.md`, and five
  tests (`gentle-shell-bin`, `gentle-shell-launcher`, `rpc-host`,
  `agents-rpc-publisher`, `install-tui-mode-guard`).
- **Changed:** `package.json` (adds `bin.gentle-shell` and `files: bin/`),
  `README.md`, `docs/readme-reference.md`,
  `extensions/{ask-user-choice,ask-user-question,gentle-agents}.ts`,
  `lib/agents-runner.ts`, and
  `scripts/{install-gentle-ai,install-tui-mode-setting,build-runtime-modules,verify-package-files}.mjs`.
- **Identical:** exact dependencies (`@earendil-works/pi-tui` 0.85.1,
  `@heyhuynhgiabuu/pi-pretty` 0.6.27), the peer range
  (`@earendil-works/pi-coding-agent >= 0.85.1`), the pinned package-local Gentle
  AI runtime (**v3.5.0**, the same value 3.4.0 pinned), the review provider
  contract (**1.2.0**), the same 13 extensions, and
  `extensions/startup-banner.ts`.
- **The TUI-visible code changes are gated.** Every behavioral edit in
  `ask-user-choice.ts`, `ask-user-question.ts`, `gentle-agents.ts` and
  `agents-runner.ts` sits behind `isInteractiveRpcHost(ctx.mode, env)`, which
  requires `GENTLE_SHELL_INTERACTIVE_HOST=1` (the desktop app's host). Plain TUI
  takes the unchanged path; subagent children now strip that variable through
  `withoutInteractiveHost`, and `notifiedRpcActivityErrors` deduplicates a
  recurring push failure.
- **`pi update` drift is unaffected:** the settings entry stays a versioned npm
  spec, which Pi's updater skips.
- **`gentle-ai sync` is required after the install** — upstream documents it, and
  the previous feature observed it rewriting six files while the pin and the
  banner filter both survived.

### Work unit 1 (WU1) — commit `a93e29f docs(pi): make the pinned gentle-pi
  examples version-neutral`, 2 files, 6 insertions, 4 deletions:
`startup-header.nix` and `startup-header/index.ts`.

Both sites read "a version-pinned variant such as `npm:gentle-pi@3.4.0`". They
illustrate a *shape*, not the current pin, so the literal goes stale on every
bump. Both now read `npm:gentle-pi@<version>`.

Executed evidence for "comment-only":

- The escape-sensitive jq program, extracted from `HEAD:` and from the working
  copy and hashed, is identical:
  `5e1e5bfdea8ae245e26113506910f960ccca597b30642aabbe1a5e04c4892c70`.
- `git diff -U0 | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vE
  '^[+-][[:space:]]*[#*]'` returns nothing: every changed line is a comment.
- `alejandra --check modules/home/programs/terminal/tools/pi/startup-header.nix`
  reports "Congratulations! Your code complies with the Alejandra style", exit 0,
  with the file's sha256 unchanged by the run (`68277a87…`). `alejandra` is not on
  `PATH` here; the store binary `alejandra-4.0.0` was used. `just fmt-check` was
  avoided on purpose (see the tooling note in `gentle-stack-upgrade.md`).
- `grep -n "gentle-pi@3.4.0"` over both files returns nothing. Occurrences under
  `odd/tasks/*.md` remain by design: they are historical records.

Recorded, not fixed: the substituted line in `index.ts` is 82 columns where the
original was 80, accepted rather than reflowing the surrounding prose.

### Work unit 2 (WU2) — commit `fe650ca docs(ai-tools): record the gentle-shell
  3.5.1 pin and the launcher`, 1 file, 13 insertions, 2 deletions:
`modules/common/ai-tools/README.md`.

Records the pin (`currently **npm:gentle-pi@3.5.1**`) and adds a paragraph on the
launcher: that it is a package `bin`, that it is absent from the login `PATH`, why
(`<agent dir>/bin` is prepended only for spawned processes and package bins are
never linked into it; `npm prefix -g` is a read-only Nix store path), how to reach
it by absolute path, and that `--link` reuses `~/.pi/agent` while the default
isolated home carries none of the Nix-managed surface.

### The runtime action — no repository change

Applied through Pi's own package manager, after backing up `settings.json`,
`npm/package.json` and `npm/package-lock.json`:

```
pi install npm:gentle-pi@3.5.1
gentle-ai sync
```

Net effect on the two runtime files, per a semantic diff against the backups:

- `~/.pi/agent/settings.json`: **only** `3.4.0` -> `3.5.1` on the gentle-pi entry's
  `source`. The `!startup-banner.ts` filter, every other package, `theme`,
  `tuiMode` and the HM `models.json` symlink are untouched.
- `~/.pi/agent/npm/package.json`: only `gentle-pi: ^3.4.0` -> `^3.5.1`.

The pin and the filter therefore survived **two** native whole-file rewrites in
sequence (`pi install`, then `gentle-ai sync`), which is the risk this upgrade
carried. `pi list` reports `npm:gentle-pi@3.5.1 (filtered)`.

npm's script gate still blocks gentle-pi's `postinstall` (`npm warn
install-scripts 1 package has install scripts not yet covered by allowScripts`),
so the package-local Gentle AI runtime is still unprovisioned by that script — the
same pre-existing limitation the previous feature recorded, and the public Nix CLI
remains the runtime in use.

### Verification (independent, read-only)

Eight flake checks green, each via `nix build .#checks.aarch64-darwin.<name>
--no-link` with no secrets override needed: `integration-ai-tools-docs-links`,
`integration-ai-tools-skill-contract`, `unit-ai-tools-inventory`,
`unit-ai-tools-dependencies`, `integration-gentle-ai-engine`,
`integration-docs-generation`, `integration-module-contract`,
`integration-home-module`. Naming note: the two AI-tools inventory checks are
`unit-*`, not `integration-*`.

The runtime claims in the new README paragraph were checked by execution, not
inference:

- `gentle-shell --version` -> `gentle-shell 3.5.1`, `pi 0.86.0`, `home isolated
  /Users/aytordev/.gentle-shell/agent`, exit 0.
- `gentle-shell --link --version` -> `home link /Users/aytordev/.pi/agent`, exit
  0, and `~/.gentle-shell` is still absent afterwards: `--link` resolves per run
  and persists nothing. Only `gentle-shell home <link|isolated|path>` writes the
  launcher config (`bin/gentle-shell.mjs`, `handleHomeCommand`), and `linkDir()` is
  `PI_CODING_AGENT_DIR || ~/.pi/agent`.
- The isolated-home claim rests on Pi's own resolution: `getAgentDir()` is
  `PI_CODING_AGENT_DIR || <home>/.pi/agent`, so redirecting that variable
  redirects `settings.json`, `skills/`, `extensions/` and `models.json`.
- `command -v gentle-shell` is empty, and the login `PATH` probed outside this
  agent's shell (`env -i /bin/zsh -lc`) carries no npm/node/agent entry;
  `~/.pi/agent/bin` does not exist; `npm prefix -g` is
  `/nix/store/…-nodejs-slim-24.20.0`, mode 0555, not writable.
- "The launcher first ships in 3.5.0" is a registry fact, reproducible with
  `npm view gentle-pi@3.4.0 bin` (empty) against `npm view gentle-pi@3.5.0 bin`
  (`{ 'gentle-shell': 'bin/gentle-shell.mjs' }`). The live machine cannot show it,
  since only 3.5.1 is installed.

### Recorded, not fixed

- **The operator still cannot type `gentle-shell`.** The command exists and runs,
  but nothing publishes `~/.pi/agent/npm/node_modules/.bin` on the login `PATH`.
  Closing it is a Nix change — a `home.sessionPath` entry on that directory, or a
  dedicated option — and it needs a `just darwin-switch wang-lin`. It was
  deliberately left out of this slice: it changes the pi module's surface, which
  `checks/module-contract` enumerates, and it is a separate decision from
  recording the pin. Until then only the absolute path works.
- **Upstream's documented primary install path does not apply here.**
  `npm i -g gentle-pi` cannot write to the Nix store prefix. Recorded in the
  README rather than worked around.
- **`npm/package.json` still declares `pi-mcp-adapter: ^2.6.0`** while the
  installed version stays 2.36.0. Pre-existing from the previous feature's sync,
  unchanged here.
- The README's "a versioned npm spec is skipped by `pi update`" is pre-existing
  and was not re-verified by this feature.

## Next step

The runtime is at 3.5.1, the repository records it, and eight checks are green.
Three commits — `a93e29f`, `fe650ca`, and this record's — live only on
`chore/upgrade-gentle-stack`; push and pull request remain the operator's
decisions.

Open decision: whether to publish the package `bin` directory on the login
`PATH`. That is the remaining step for `gentle-shell` to work as a typed command
outside Pi.
