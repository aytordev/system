# gentle-upstream-4-8

Move the three Gentle components to the current upstream line: the two Nix-owned
pins (Gentle AI CLI, Engram engine) and the operator-owned Gentle Shell pin
(`npm:gentle-pi`), keeping every version statement, patch contract, and check
assertion honest.

## Specs

S1. Move `packages/gentle-ai/package.nix` from `4.4.0` to upstream release
`v4.5.0`, replacing all four per-platform SRI hashes with values derived from the
release's own `checksums.txt` and confirmed by prefetching each published
archive, and updating the provenance comment (installer cross-reference: the
tagged `gentle-shell` release that ships this engine).

S2. Move `packages/engram/package.nix` from `3.7.0` to upstream release `v3.7.2`,
replacing `hash` and `vendorHash`, and re-verifying — not copying — the two
carried comments (the `go` toolchain floor that `buildGo127Module` satisfies, and
the sandbox-incompatible loopback tests behind `doCheck = false`).

S3. Keep every version statement honest: the three assertions in
`checks/gentle-ai-engine/default.nix` (`4.4.0` twice — the `packageVersion`
regression and the `gentle-ai version` grep — and `3.7.0` at
`engramPackageVersion`), the `gentle-pi` version named in the profiles.json
regression comment, and the version prose in `modules/common/ai-tools/README.md`
(CLI, Engram, the Shell pin, and the paragraph stating which Shell releases bundle
which engine) must agree with the delivered pins.

S4. Move the operator-owned Shell pin from `npm:gentle-pi@4.3.0` to
`npm:gentle-pi@4.8.0` through upstream's documented path only — `pi install`,
then the version-keyed `npm install-scripts approve`, then `gentle-ai sync` — and
pair the Engram companion the released core declares (`gentle-engram@0.8.0`),
because Engram validates the core/companion pair. Record every step that cannot
be completed in-session (activation, restart) instead of claiming it.

S5. Verify that this repository's own patches still match what Shell 4.8.0 ships,
read from the installed package rather than from release prose:
`startup-header.nix`'s `^npm:gentle-pi(@.+)?$` source match and its
`!startup-banner.ts` filter target, and `agent-profiles.nix`'s envelope kind,
entry keys (`model`/`thinking`), `profiles.json` store shape, `workflow` sibling
and `active` marker.

S6. Deliver on one feature branch as reviewable work units, one commit per
upstream, with the check and README edits travelling with the pin that makes them
true. Push, PR and merge stay the operator's decisions.

## Tasks

- [ ] **GU8-1 — Bump gentle-ai to 4.5.0.** Route: inline (one package file plus
  its version statements). Commit: `chore(gentle-ai): bump to 4.5.0`. Surfaces:
  `packages/gentle-ai/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S1 and its share of S3.
- [ ] **GU8-2 — Bump engram to 3.7.2.** Route: inline, after GU8-1 (shared check
  and README surfaces). Commit: `chore(engram): bump to 3.7.2`. Surfaces:
  `packages/engram/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S2 and its share of S3.
- [ ] **GU8-3 — Verify both builds and the checks.** Route: parent, after
  GU8-1/GU8-2. Covers S1-S3.
- [ ] **GU8-4 — Move the Shell pin to 4.8.0 and align the Engram pair.** Route:
  parent (operator-owned live profile; no Nix surface). Covers S4.
- [ ] **GU8-5 — Verify the repository patches against installed 4.8.0.** Route:
  parent, after GU8-4. Covers S5 and its share of S3.

## Log

L1 (operator, verbatim): "gentle-ai, engram y gentle-pi al upstream"

L2 (parent evidence, upstream state at plan time, 2026-11-14): `gentle-ai` latest
`v4.5.0` (2026-11-13T23:11:41Z, release target `f2f7d7b1`, provider contract
`1.5.0` — additive stop reason; review integration contract stays `v2`,
capability identity stays `capabilities/v2.6`, module path stays `/v4`); `engram`
latest `v3.7.2` (2026-11-14T00:26:08Z, packaging-only patch pairing with
`gentle-engram@0.8.0`, `go 1.26.11` in `go.mod`); `gentle-shell` latest `v4.8.0`
(2026-11-14T02:35:05Z), published to npm as `gentle-pi@4.8.0`, pinning Gentle AI
`v4.5.0`, bundling Engram core `3.7.2` with the `gentle-engram@0.8.0` companion,
`engines.node ^22.19.0 || >=23.6.0` and peer
`@earendil-works/pi-coding-agent >=1.2.0`.

L3 (parent evidence, this host's live state before the change — machine
`civislend`): `gentle-ai 4.4.0`, `engram 3.7.0`, `pi 1.5.0`,
`~/.pi/agent/settings.json` pin `npm:gentle-pi@4.3.0` with the
`!startup-banner.ts` filter, installed `gentle-pi@4.3.0`, installed
`gentle-engram@0.7.0`, package-local engine `.gentle-ai/v4.2.0`. The README
already claimed `npm:gentle-pi@4.7.0`; that statement was true of the delivered
pin on the other host, not of this profile, and GU8-4 is what makes it true here.
