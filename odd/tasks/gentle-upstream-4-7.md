# gentle-upstream-4-7

Bump the two Nix-owned Gentle pins (Gentle AI engine, Engram engine) to their
current upstream releases and move the operator-owned Gentle Shell pin to 4.7.0,
keeping every version statement, patch contract, and check assertion honest.

## Specs

S1. Move `packages/gentle-ai/package.nix` from `4.3.1` to upstream release
`v4.4.0`, replacing all four per-platform SRI hashes with values derived from the
release's own `checksums.txt` and confirmed by prefetching each published
archive, and updating the provenance comment (installer cross-reference: the
tagged `gentle-shell` release that ships this engine).

S2. Move `packages/engram/package.nix` from `3.6.0` to upstream release `v3.7.0`,
replacing `hash` and `vendorHash`, and re-verifying — not copying — the two
carried comments (the `go 1.26.10` toolchain floor that `buildGo127Module`
satisfies, and the sandbox-incompatible loopback tests behind `doCheck = false`).

S3. Keep every version statement honest: the three assertions in
`checks/gentle-ai-engine/default.nix` (`4.3.1` twice — the `packageVersion`
regression and the `gentle-ai version` grep — and `3.6.0` at
`engramPackageVersion`) and the version prose in `modules/common/ai-tools/README.md`
(CLI, Engram, the Shell pin, and the paragraph stating which Shell releases bundle
which engine) must agree with the delivered pins.

S4. Move the operator-owned Shell pin from `npm:gentle-pi@4.3.0` to
`npm:gentle-pi@4.7.0` through upstream's documented path only — `pi install`,
then the version-keyed `npm install-scripts approve`, then `gentle-ai sync` run
from the bumped Nix CLI — and pair the Engram companion the released core
declares (`gentle-engram@0.7.0`), because Engram validates the core/companion
pair.

S5. Verify that this repository's own patches still match what Shell 4.7.0
ships, read from the installed package rather than from release prose:
`startup-header.nix`'s `^npm:gentle-pi(@.+)?$` source match and its
`!startup-banner.ts` filter target, and `agent-profiles.nix`'s envelope kind,
entry keys (`model`/`thinking`), `profiles.json` store shape and `active` marker.

S6. Deliver on one feature branch as reviewable work units, one commit per
upstream, with the check and README edits travelling with the pin that makes them
true. Push, PR and merge stay the operator's decisions.

## Tasks

- [x] **GU-1 — Bump gentle-ai to 4.4.0.** Route: inline (one package file plus its
  version statements). Commit: `chore(gentle-ai): bump to 4.4.0`. Surfaces:
  `packages/gentle-ai/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S1. Evidence: `nix build
  .#gentle-ai` realized `gentle-ai-4.4.0` and the binary reports `gentle-ai
  4.4.0`; all four SRIs agree between `checksums.txt`, `nix store prefetch-file`
  and installer `INSTALLER_VERSION 4.4.0` at gentle-shell `v4.7.0`.
- [x] **GU-2 — Bump engram to 3.7.0.** Route: inline, after GU-1 (shared check and
  README surfaces). Commit: `chore(engram): bump to 3.7.0`. Surfaces:
  `packages/engram/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S2. Evidence: `nix build .#engram`
  realized `engram-3.7.0` and the binary reports `engram 3.7.0`; `go.mod` and
  `go.sum` are byte-identical to v3.6.0's, which is why `vendorHash` is unchanged;
  `cmd/engram/autosync_e2e_test.go` still binds loopback through
  `httptest.NewTLSServer`, so `doCheck = false` still holds.
- [x] **GU-3 — Verify both builds and the engine check.** Route: parent, after
  GU-1/GU-2. Covers S1-S3. Evidence: `nix build .#gentle-ai` and
  `nix build .#engram` realize `4.4.0`/`3.7.0` with the expected `version`
  output; `nix build .#checks.aarch64-darwin.integration-gentle-ai-engine`
  exit 0; `just fmt-check` 0 changed.
- [x] **GU-4 — Move the Shell pin to 4.7.0.** Route: parent (operator-owned live
  profile; no Nix surface). Covers S4. Evidence: `pi install
  npm:gentle-pi@4.7.0` wrote the versioned pin and preserved the
  `!startup-banner.ts` filter; `npm install-scripts approve gentle-pi@4.7.0
  --allow-scripts-pin` replaced the stale `4.3.0` approval and the
  `npm rebuild gentle-pi` postinstall provisioned `.gentle-ai/v4.4.0/gentle-ai`
  (binary reports `gentle-ai 4.4.0`); `gentle-ai sync` from the bumped Nix CLI
  reported no managed actions and left `settings.json` byte-identical. A Pi
  restart is still required for the new Shell to load.
- [x] **GU-5 — Verify the repository patches against installed 4.7.0.** Route:
  parent, after GU-4, plus the README prose and one source fix. Covers S3 and S5.
  Commit: `fix(pi): keep the runtime workflow key when merging profiles` plus the
  README pin statements. Evidence in L5.
- [ ] **GU-6 — Align the live Engram pair.** Route: blocked on the operator's
  activation, which needs the sudo password this session does not have. Covers
  S4's pairing clause.

## Log

L1 (operator, verbatim): "actualiza el upstream de gentle-i

actualiza el upstream de gentle-ai, gentle-shell y engram".

L2 (parent evidence, upstream state at plan time, 2026-11-07): `gentle-ai` latest
`v4.4.0` (2026-11-07T17:38:21Z, provider contract byte-frozen at 1.4.0); `engram`
latest `v3.7.0` (2026-11-07T18:08:38Z, pairs with `gentle-engram` 0.7.0, `go
1.26.10` in `go.mod`); `gentle-shell` latest `v4.7.0` (2026-11-07T18:26:21Z),
published to npm as `gentle-pi@4.7.0`, pinning Gentle AI `v4.4.0` and bundled Pi
1.5.0. Repository pins at that moment: `packages/gentle-ai` `4.3.1`,
`packages/engram` `3.6.0`, live Shell `npm:gentle-pi@4.3.0`, live companion
`npm:gentle-engram@0.1.14`, Nix Pi (`pi-coding-agent`) 1.5.0 on PATH.

L3 (parent evidence, shells skipped by the jump 4.3.0 → 4.7.0): 4.4.0/4.5.x add
the reviewed gentle-pi supplier list and `gs` on Windows; 4.5.0 retires
`/gentle:models` in favour of `/gentle:profiles` and 4.5.1 treats `effort` as the
legacy spelling of `thinking`; 4.6.0 adds the fullscreen IDE chrome, model
fallback chains and moves bundled installs to Pi 1.5.0 while keeping engine
4.3.1; 4.7.0 pins engine 4.4.0, adds the `organic`/`full-delegation` orchestrator
`workflow` key in `profiles.json`, and declares "no breaking changes" while
defaulting the fullscreen surface to transparent with minimal cards.

L4 (GU-5 evidence, contracts read from the installed 4.7.0 package, not from
release prose): `lib/agent-profiles.ts` keeps `PROFILES_KIND
"gentle-pi.agent_model_profiles"`, `PROFILE_EXPORT_KIND
"gentle-pi.agent_model_profile"` and `version 1`, and `AgentRoutingEntry` still
accepts `model`/`thinking`; `lib/agents-config.ts:251` still reads
`entry.effort ?? entry.thinking`, so this repository's `subagents.json`
`effort` spelling stays valid; per-profile fallback chains moved to their own
`profile-fallbacks.json`, which this repository never writes; `assets/agents/`
still ships exactly the ten roles `checks/gentle-ai-engine` asserts;
`extensions/startup-banner.ts` still exists for the `!startup-banner.ts` filter,
and the filtered entry's `source` is still `npm:gentle-pi@<version>`.

L5 (GU-5 finding and correction, RED then GREEN): 4.7.0 added an optional
top-level `workflow` map to `profiles.json` (`{[profile]:
{orchestratorMode: "organic"|"full-delegation"}}`, set with `w` in
`/gentle:profiles`). `agent-profiles.nix` rebuilt that document from
`{kind, version, profiles, active}`, so the next activation would have reset
every profile to the organic mode silently. RED: the new regression block in
`checks/gentle-ai-engine` sources the real activation against a seeded store and
failed on `workflow == None`. GREEN: the merge now carries `workflow` through,
the same check passes, and it also pins the preserved `active` marker and the
idempotent no-rewrite path. `just fmt-check` 0 changed;
`integration-pi-theme` exit 0.

L6 (GU-6 blocker): the live Engram pair cannot be completed from this session.
`sudo -n true` exits 1, so `just darwin-switch wang-lin` needs the operator's
password, and the live `ENGRAM_BIN` therefore still resolves to 3.6.0. Upstream
pairs core v3.7.0 with `gentle-engram@0.7.0` and says to upgrade both together,
so the companion was deliberately left at 0.1.14 rather than creating a
companion-new/core-old window. After the switch: `engram setup pi` (or
`pi install npm:gentle-engram@0.7.0`) and keep exactly one versioned entry.
