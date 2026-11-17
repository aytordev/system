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

- [x] **GU8-1 — Bump gentle-ai to 4.5.0.** Route: inline (one package file plus
  its version statements). Commit: `chore(gentle-ai): bump to 4.5.0`
  (`a5df7ed8`), plan `58b60abe`. Surfaces: `packages/gentle-ai/package.nix`,
  `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`.
  Covers S1 and its share of S3. Evidence: the four SRIs agree between the
  release `checksums.txt` and `nix store prefetch-file` of each published
  archive; `nix build .#gentle-ai` realized `gentle-ai-4.5.0` and the binary
  reports `gentle-ai 4.5.0` under an isolated HOME/XDG with no native
  onboarding profile created.
- [x] **GU8-2 — Bump engram to 3.7.2.** Route: inline, after GU8-1 (shared check
  and README surfaces). Commit: `chore(engram): bump to 3.7.2` (`ac9acb8b`).
  Surfaces: `packages/engram/package.nix`, `checks/gentle-ai-engine/default.nix`,
  `modules/common/ai-tools/README.md`. Covers S2 and its share of S3. Evidence:
  `nix build .#engram` realized `engram-3.7.2` and the binary reports
  `engram 3.7.2`; `go.sum` is byte-identical to v3.7.0's, so `vendorHash` is
  unchanged and only the source hash moved; `go.mod` rose from `go 1.26.10` to
  `go 1.26.11` (default Go in the pinned nixpkgs is now `1.26.10`), so
  `buildGo127Module` is still required; `cmd/engram/autosync_e2e_test.go` still
  opens `httptest.NewTLSServer`, so `doCheck = false` still holds.
- [x] **GU8-3 — Verify both builds and the checks.** Route: parent, after
  GU8-1/GU8-2. Covers S1-S3. Evidence: `nix build
  .#checks.aarch64-darwin.integration-gentle-ai-engine` exit 0 (it runs the real
  `gentle-ai version` grep and the profile-store merge over the real activation);
  `nix build .#checks.aarch64-darwin.integration-pi-theme` exit 0 after the
  comment edits; `nix flake check --all-systems --no-build --override-input
  secrets path:./checks/fixtures/secrets` ends `all checks passed!`; the
  repository formatter reports `0 changed` over 414 files.
- [x] **GU8-4 — Move the Shell pin to 4.8.0 and align the Engram pair.** Route:
  parent (operator-owned live profile; no Nix surface). Commit:
  `chore(pi): pin the Shell at 4.8.0 and pair engram 3.7.2` (`e2db19d9`).
  Covers S4. Evidence: `pi install npm:gentle-pi@4.8.0` wrote the versioned pin
  and preserved the `!startup-banner.ts` filter; `npm install-scripts approve
  gentle-pi@4.8.0 --allow-scripts-pin` replaced the stale `4.3.0` approval and
  `npm rebuild gentle-pi` provisioned `.gentle-ai/v4.5.0/gentle-ai`, which
  reports `gentle-ai 4.5.0` — the session engine and the Nix CLI now match.
  The 3.7.2 core's own `engram setup pi` added the `gentle-engram@0.8.0`
  companion and moved `npm/package.json` to `gentle-engram ^0.8.0`; the
  pre-existing bare `npm:gentle-engram` entry became a duplicate registration and
  was removed, leaving exactly one versioned entry. `gentle-ai sync` from the
  4.5.0 binary then reported `no managed sync actions needed`.
- [x] **GU8-5 — Verify the repository patches against installed 4.8.0.** Route:
  parent, after GU8-4. Commit:
  `chore(pi): name Shell 4.8.0 in the verified patch comments` (`75adc099`).
  Covers S5 and its share of S3. Contracts read from the installed package, not
  from release prose; evidence in L7.

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

L4 (GU8-2 source evidence): v3.7.2 differs from v3.7.0 in `go.mod` (`go
1.26.10` -> `go 1.26.11`) and in the companion installer pin; `go.sum` is
identical, and `cmd/engram/autosync_e2e_test.go` keeps four
`httptest.NewTLSServer` occurrences, so both carried comments were re-verified
rather than copied.

L5 (GU8-3 and GU8-4 observations): `sync --dry-run` predicted eight apply steps
before the real run, and the real run reported no managed actions; the sequence
that closed the gap was `approve` -> `npm rebuild`, whose postinstall is what
refreshes managed assets. `engram setup pi` warned that
`~/.pi/agent/mcp.json` still carries `mcpServers.engram`, so Pi exposes the same
server twice (`mcp__engram` tools beside the native `mem_*` tools) and upstream
does not guarantee native-only writes while that path remains. Removing only
`mcpServers.engram` is an operator decision for a later step; nothing was deleted
here.

L6 (GU8-3 risk note): the assess call on this candidate returned
`nativeRisk: unassessable` with reason `package-local-binary-missing`,
`changedPaths: 0`, `rddLine: unknown` and writer profile `large` from runtime
evidence. Shell 4.8.0's postinstall replaced `.gentle-ai/`, so the running Shell
4.3.0 can no longer resolve its own engine until Pi restarts. The returned plan
asked for writer self-verification only and escalated no Task Size high-risk
item; no independent verifier ran and no native review is claimed.

L7 (GU8-5 evidence, contracts read from the installed 4.8.0 tree):
`lib/agent-profiles.ts` keeps `PROFILES_KIND "gentle-pi.agent_model_profiles"`,
`PROFILE_EXPORT_KIND "gentle-pi.agent_model_profile"` and `version 1`;
`lib/agent-profile-pin.ts` keeps `PROFILE_PIN_KIND
"gentle-pi.agent_model_profile_pin"`; the store still lives at
`<configHome>/profiles.json`; routing entries still carry `model`/`thinking`;
the per-profile `workflow.orchestratorMode` sibling and the `active` marker are
still there, so the `workflow` carry-over this repository added for 4.7.0 stays
necessary; `assets/agents/` still ships exactly the ten roles
`checks/gentle-ai-engine` asserts; `extensions/startup-banner.ts` still exists,
so the `!startup-banner.ts` filter still releases a real banner slot, and the
filtered entry's `source` is still `npm:gentle-pi@<version>`. The
`engramPackageVersion` rationale was rewritten because its old wording named the
plugin at `0.2.0` and two capabilities (`/projects`, `sync_target_closed_space`)
that neither the 0.7.0 nor the 0.8.0 plugin tree contains; the surviving gate,
`capabilities.isolated_session_registration` read from the engine's `/health`, is
present in both trees.

L8 (operator actions that remain, none of them repository state): `sudo -n true`
exits 1 on this host, so `just darwin-switch` cannot run from this session and
PATH still reports `gentle-ai 4.4.0` and `engram 3.7.0` until the operator
activates the reviewed generation; Pi must be restarted for Shell 4.8.0 and the
native runtimes to load; and the `mcpServers.engram` duplicate path from L5 is
the operator's decision.

L9 (operator decision on L5, verbatim: "3. Hazlo." — remove only the duplicate
`mcpServers.engram` path): `~/.pi/agent/mcp.json` had exactly two servers,
`context7` and `engram`. Only `engram` was removed; `context7` and the
`mcpServers` shape are untouched, the file stays valid JSON with the same
formatting, and the previous bytes are backed up outside the repository. The
native `gentle-engram@0.8.0` plugin is what serves the `mem_*` tools, so no
capability is lost: `pi list` reports four packages — `npm:gentle-pi@4.8.0`
(filtered), `npm:pi-web-access`, `npm:pi-btw`, `npm:gentle-engram@0.8.0` — and
the `mcp__engram` duplicate disappears on the next Pi restart.

L10 (delivery evidence, authorized by the operator with "haz PR y pushealo a main
cuando este en vered"): published through the repository's personal-identity
wrapper `ghp` (actor `aytordev`, scopes `repo`, `workflow`, `read:org`), never
through the work-account `gh`. Approved issue #286 (`status:approved`,
`type:chore`) and PR #287 (`Closes #286`, `type:chore`) at head `8df9fa9a`, whose
body carried the version table, the verification list and the `Risk: item 5`
line. CI at that head: `Check expressions` pass (30s), `Check x86_64-linux` pass
(3m12s), `Check aarch64-darwin` pass (18m28s), `label` pass (7s) — no failures.
Merged with `ghp pr merge 287 --merge --match-head-commit 8df9fa9a…` after
confirming `mergeable: MERGEABLE` and `mergeStateStatus: CLEAN`; merge commit
`d05ba1140eebf0583da36573fd214e0c25605d04` at 2026-11-17T13:19:49Z, issue #286
closed, branch kept (no deletion). Local `main` fast-forwarded to the merge
commit over the personal credential route
(`credential.helper='!ghp auth git-credential'` against the HTTPS remote) because
the ambient SSH agent fetch failed with "Could not read from remote repository";
that is a credential-route observation for future Git network operations, not a
repository defect.
