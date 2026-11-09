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
- [ ] **GU-2 — Bump engram to 3.7.0.** Route: inline, after GU-1 (shared check and
  README surfaces). Commit: `chore(engram): bump to 3.7.0`. Surfaces:
  `packages/engram/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S2.
- [ ] **GU-3 — Verify both builds and the engine check.** Route: parent, after
  GU-1/GU-2. Covers S1-S3.
- [ ] **GU-4 — Move the Shell pin to 4.7.0 and pair gentle-engram 0.7.0.** Route:
  parent (operator-owned live profile; no Nix surface). Covers S4.
- [ ] **GU-5 — Verify the repository patches against installed 4.7.0.** Route:
  parent, after GU-4, plus the README Shell prose. Covers S3 and S5.
- [ ] **GU-6 — Commit the Shell pin statements and close.** Route: parent. Covers
  S3 and S6.

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
