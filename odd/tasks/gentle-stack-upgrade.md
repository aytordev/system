# Feature: gentle-stack-upgrade

## Objective

Advance the two upstream Gentle components this repository depends on: the
Nix-owned public **Gentle AI CLI** from 3.4.0 to **3.6.0**, and the native-owned
**Gentle Shell** package (npm `gentle-pi`) from 3.3.0 to **3.4.0**, with the
Shell version pinned rather than drifting.

## Problem

Both components are one or more releases behind, and Shell is not pinned at all.
Nix is the only permitted update path for the CLI (`GENTLE_AI_NO_SELF_UPDATE=1`),
so 3.4.0 cannot be upgraded in place; the pin in
`packages/gentle-ai/package.nix` is the update mechanism. Shell is installed by
the native installer into `~/.pi/agent/npm/` under the **unversioned** spec
`npm:gentle-pi`, which means `pi update --extensions` / `pi update --all` moves
it to the latest release at any time.

## Why

- `odd/tasks/custom-startup-header.md` records upstream shipping "roughly one
  release per day". An unversioned Shell spec is therefore active drift, not a
  theoretical risk.
- The banner filter that protects the custom header is applied by an activation
  merge and a runtime heal that both match the **literal** `npm:gentle-pi`. The
  moment that literal gains a version — by us, by the installer, or by a one-off
  `pi install` — the filter silently stops applying and upstream's banner
  competes for the single custom-header slot again.
- Gentle AI 3.5.0 flipped receipt-driven development to **on by default**, a
  behavior change that reaches this machine with the upgrade.

## Scope

- Advance the `packages/gentle-ai` pin to 3.6.0 with the release's own
  `checksums.txt` digests re-encoded as SRI.
- Generalize the Shell matcher in `startup-header.nix` (activation jq) and
  `startup-header/index.ts` (runtime heal) to accept `npm:gentle-pi` **and**
  `npm:gentle-pi@<spec>`, preserving whatever spec is present.
- Pin Shell 3.4.0 with the upstream-documented `pi install npm:gentle-pi@3.4.0`,
  and remove `npm:@juicesharp/rpiv-ask-user-question`, which 3.4.0 makes
  mandatory (see Constraints).
- Update the version statements in `modules/common/ai-tools/README.md`.
- Rebuild, switch, and run `gentle-ai sync`.

## Non-goals

- Not packaging Shell as a Nix derivation. `modules/common/ai-tools/README.md`
  assigns Shell to the native installer; a `buildNpmPackage` derivation would
  fight Pi's package manager for the same tree.
- Not touching the RDD switch: the new default (`on`) is adopted as-is.
- Not changing the `distributor`/`ai-skills` publication model.
- Not upgrading Engram, Pi, or any unrelated flake input.

## Constraints

- **`settings.json` is runtime-owned.** Pi, the Gentle AI installer and package
  installers rewrite it; the module deliberately does not declare it via
  `home.file`. The Shell pin therefore lives in a runtime file: it is *stable*,
  not *declarative*. Nix cannot guarantee it.
- **Shell 3.4.0 owns the `ask_user_question` tool name.** Release notes:
  "Pi intentionally refuses to load two extensions that register the same tool
  name." `npm:@juicesharp/rpiv-ask-user-question` is currently installed, so it
  must be removed before 3.4.0 can start. This is independent of the pin choice.
- **`fetchurl` verifies SHA-256 only**, not the release minisign signature. The
  digests come from the release manifest; the aarch64-darwin archive is
  independently verified by the Nix build on this host.
- **The extension has no automated test.** `checks/gentle-ai-engine` asserts the
  module surface (option names, package presence) and nothing executes the jq
  predicate or the TypeScript heal. The matcher change needs executed evidence
  against both entry shapes, not only a read.
- Shell 3.4.0 pins Gentle AI **v3.5.0** in its own package-local runtime. That is
  a separate binary from the Nix-owned public CLI at 3.6.0; only the CLI is our
  pin.

## Decisions

- **3.6.0, not 3.5.0** (user's choice): `gentle-ai update` reports 3.6.0 as
  latest, it declares no breaking changes and keeps the provider contract
  byte-frozen at `1.2.0`. Skipping a release also avoids syncing assets twice.
- **Pin Shell and generalize the matcher** (user's choice, over runtime-only or
  documentation-only): it is the upgrade path upstream documents, it removes the
  drift, and it closes the latent header fragility in the same pass. The cost is
  one extra rebuild we were already paying.
- **Report, then verify on the real file**: the pin changes the literal, so the
  activation merge that runs during `darwin-switch` is itself the proof that the
  generalized matcher works.
- **RDD stays on** (user's choice): adopt the new upstream default rather than
  disabling it.

## Progress

Branch `chore/upgrade-gentle-stack`, from `main`.

### Evidence gathered before writing

- Active CLI is Nix-owned: `/nix/store/zgd3zfdmf0sbdf7m3vv6jj1qzddl28r6-gentle-ai-3.4.0/bin/gentle-ai`,
  and `gentle-ai --help` reports `(3.4.0)`.
- `gentle-ai review mode status` reports `off (decided by default)`, with
  `global: unset` and `clone-local: unset`.
- Shell is 3.3.0 in Pi's store: `npm ls --prefix ~/.pi/agent/npm` shows
  `gentle-pi@3.3.0`; `pi list` shows `npm:gentle-pi (filtered)`.
- `~/.pi/agent/settings.json` carries the object entry
  `{source: "npm:gentle-pi", extensions: ["!startup-banner.ts"]}` plus
  `"npm:@juicesharp/rpiv-ask-user-question"`.
- Release `checksums.txt` fetched for both v3.5.0 and v3.6.0; only the 3.6.0
  digests are used.

### Work unit 1 (WU1) — commit `6fc1784 chore(gentle-ai): pin the public CLI to
3.6.0`, 1 file, 5 insertions, 5 deletions: `packages/gentle-ai/package.nix`
(version + four SRI hashes).

Verified: `nix build .#gentle-ai` builds on aarch64-darwin — which proves the
`darwin_arm64` digest matches the published archive, not just the manifest — and
the built binary reports `gentle-ai 3.6.0`. The other three platform digests are
read from the release manifest and are not independently exercised on this host.

### Work unit 2 (WU2) — commit `b6b441e fix(pi): match a version-pinned
gentle-pi source in the banner filter`, 3 files, 63 insertions, 15 deletions:
`startup-header.nix`, `startup-header/index.ts` and the ai-tools README.

Executed evidence, not inspection:

- The shipped jq program, extracted from the file, on the bare string entry, the
  pinned object entry, the already-filtered entry (a strict no-op under
  `jq -S | cmp`), the `npm:gentle-pi-tools` lookalike, and a malformed entry list
  (`{extensions: []}`, `null`, `42`) — no error, exit 0.
- `alejandra --check` clean on the module; `nix fmt` reports 0 changed.
- An independent verifier reproduced all of the above and re-ran four checks to
  green: `integration-gentle-ai-engine`, `integration-docs-generation`,
  `integration-module-contract`, `integration-home-module`. `flake.lock` and
  `flake/dev/flake.lock` unmodified.

Two findings from that verification are recorded rather than fixed:

- **The jq anchor is escape-sensitive.** `test("…\z")` does not compile in jq
  (`Invalid escape`, exit 3) and would have silently disabled the activation
  merge; the jq source must carry `\\z`. Proven at byte level. The instruction
  that produced the first draft got this wrong; the writer caught it.
- **A residual, unreachable divergence.** Oniguruma's `.` matches a raw CR,
  U+2028 and U+2029 inside the `@.+` region, ECMAScript's does not, so an entry
  like `npm:gentle-pi@a\rb` would be filtered by the activation and not by the
  heal. Such a `source` cannot be a resolvable package spec. Closing it needs
  `\u2028`-class escapes in jq source — the same escape chain just proven
  treacherous — so it is documented in both files and deliberately left open.
- **Pre-existing, out of scope.** For an object entry whose `extensions` is a
  non-array, non-null value, jq errors out and leaves the file untouched while
  the extension coerces to `[]` and writes the filter. This predates the change
  and was not introduced by it; the jq path fails safe.
- **Tooling observation, out of scope.** treefmt 2.6.0's `--ci` and
  `--fail-on-change` write in place in this toolchain, so the repository's
  `just fmt-check` is not a non-writing check. Use `alejandra --check` when a
  read-only format check is required.

### Work unit 3 (WU3) — the runtime pin, no repository change

Applied with upstream's documented path, after backing up `settings.json` and the
npm manifest:

- `pi remove npm:@juicesharp/rpiv-ask-user-question` (2 packages removed).
- `pi install npm:gentle-pi@3.4.0`.

Resulting state: `settings.json` carries
`{source: "npm:gentle-pi@3.4.0", extensions: ["!startup-banner.ts"]}` — the pin
landed **and** the filter survived the rewrite; `pi list` reports
`npm:gentle-pi@3.4.0 (filtered)`; `npm ls` reports `gentle-pi@3.4.0`.

Load evidence, since the Shell half of WU2 has no test runner: a fresh Pi process
completed a turn (`pi -p --no-session`, no load errors), and the proof that Gentle
Shell itself registered is that `pi --help` lists its own extension flag
`--no-skill-registry`, whose only owner across every installed package is
`gentle-pi/extensions/skill-registry.ts`. No package other than `gentle-pi`
registers `ask_user_question` after the removal, so the conflict 3.4.0's release
notes warn about cannot occur.

Known limitation, pre-existing and not introduced here: npm's `allowScripts` gate
blocks gentle-pi's `postinstall` (`scripts/install-gentle-ai.mjs`), so the
package-local Gentle AI runtime is not provisioned by that script. The same was
true for 3.3.0, and the public Nix CLI is the runtime in use, so nothing changed;
it is recorded because it is the step a future reader would expect to have run.

### Switch and sync (operator-run activation)

`just darwin-switch wang-lin` needs `sudo`, so the operator ran it against the
`./result` produced above. Afterwards: `gentle-ai --version` reports 3.6.0 from
`/nix/store/…-gentle-ai-3.6.0/bin/gentle-ai`, and `gentle-ai review mode status`
reports `on (decided by default)` with no global or clone-local override — the
3.5.0 default adopted by decision.

`gentle-ai sync` then reported 6 changed files (`persona.json`, `settings.json`,
`npm/package.json`, `mcp.json`, `~/.config/gga/config`, `~/.config/gga/AGENTS.md`).
The interesting part is what survived it: `settings.json` still carries
`{source: "npm:gentle-pi@3.4.0", extensions: ["!startup-banner.ts"]}`, so the pin
and the banner filter both outlived a native whole-file rewrite, and
`~/.pi/agent/models.json` is still the Home Manager store symlink rather than a
regular file.

### Final verification (independent, live system)

- CLI 3.6.0 from an immutable store path; RDD `on`, no override.
- `pi list` → `npm:gentle-pi@3.4.0 (filtered)`; installed `gentle-pi@3.4.0`.
- `@juicesharp/rpiv-ask-user-question` absent from settings, from the npm
  manifest and from `node_modules`.
- **The activated matcher, run end to end.** The jq program was extracted from
  the *installed* home-manager activation script, not the worktree, and run
  against `/tmp` copies of the real `settings.json`: a strict semantic no-op on
  the verbatim file (`jq -S | cmp` exit 0); `!startup-banner.ts` re-added when the
  filter is emptied or the key removed, with `source` kept exactly
  `npm:gentle-pi@3.4.0`; and a bare `"npm:gentle-pi"` string converted to an
  object carrying the filter. The real file's sha256 and mtime were unchanged by
  the probe.
- A fresh Pi process completed a turn, and Gentle Shell registered: the sole
  owner of the `--no-skill-registry` extension flag across every installed
  package is `gentle-pi/extensions/skill-registry.ts`.

**The Shell upgrade did not invalidate the filter's target.** This was the one
real risk the upgrade introduced and it is now closed with evidence: in 3.4.0,
`ctx.ui.setHeader` — the single custom-header slot — is called only by
`extensions/startup-banner.ts`, the very file the filter excludes. The banner did
not move to `gentle-shell.ts` or anywhere else, so no timing competition remains.

Recorded, not fixed:

- **`gentle-ai sync` rewrote a declared range.** `npm/package.json` now declares
  `pi-mcp-adapter: ^2.6.0` where it declared `^2.36.0`. The *installed* version is
  unchanged at 2.36.0 and `^2.6.0` satisfies it, so this is not a current-state
  defect; it is a lower floor for a future resolution. `package-lock.json` still
  pins 2.36.0, so the risk is small. Manual repair would be undone by the next
  `sync`, since that file is native-owned; the durable repair is
  `pi install npm:pi-mcp-adapter@2.36.0` if it ever resolves older.
- An empty `~/.pi/agent/npm/node_modules/@juicesharp/` directory survives the
  package removal. Cosmetic.
- Not verifiable without a pty: that the live render actually suppresses the
  upstream banner, and that `ask_user_question` is single-owner at runtime. Only
  static evidence was obtainable.

## Next step

Nothing is pending on this machine: both components are pinned, active and
verified. The four commits live only on `chore/upgrade-gentle-stack`; push and
pull request remain the operator's decisions.
