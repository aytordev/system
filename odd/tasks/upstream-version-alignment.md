# Feature: upstream-version-alignment

## Objective

Align the three components of the local Gentle/Pi stack with the current
upstream line, repository and machine together:

| Component | Where it is owned | Before | Target |
| --- | --- | --- | --- |
| Pi (`pi-coding-agent`) | nixpkgs input (no overlay) | 1.0.3 | **1.3.0** |
| Gentle AI CLI (`packages/gentle-ai`) | Nix pin in this repository | 4.1.1 | **4.2.0** |
| Gentle Shell (`npm:gentle-pi`) | upstream-owned native install | 3.5.1 | **4.3.0** |

## Authorization

User authorized this cycle on 2026-10-17, answering two explicit questions:

- **Scope:** align every version with the latest upstream, repository and
  machine together.
- **Lock refresh scope:** every input of the flake — a full `nix flake update`,
  not a nixpkgs-only refresh.
- **Machine closure:** the operator runs the interactive `sudo` activation when
  asked and this session waits; the native runtime steps continue afterwards.

Not authorized: Engram bumps, Impeccable pins, model/provider/permission
changes, persona changes, secrets, and any push, pull request, or merge.

Branch: `feat/upstream-version-alignment`, from `main` (`dacc4f62`).

## Upstream facts (inspected, not assumed)

| Fact | Value | Evidence |
| --- | --- | --- |
| Pi latest on npm | **1.3.0**, 2026-10-15T19:13:30Z | `registry.npmjs.org/@earendil-works/pi-coding-agent` `dist-tags.latest` |
| Pi in nixpkgs master | **1.3.0** | `NixOS/nixpkgs` master `pkgs/by-name/pi/pi-coding-agent/package.nix:18` |
| Pi in pinned nixpkgs | 1.0.3 | `nix eval` on the flake's `nixpkgs` input |
| Gentle AI latest release | **v4.2.0**, 2026-10-15T16:59:42Z | GitHub releases API |
| Gentle AI previous | v4.1.1 (`898d3976`), release target `4acaf42` | v4.2.0 release notes |
| Provider contract | `1.3.0` -> **`1.4.0`** (adds `routing`) | v4.2.0 release notes |
| Gentle Shell latest | **v4.3.0** (`d5d692a6`), 2026-10-16T11:04:39Z | GitHub releases API |
| Shell v4.3.0 private engine | Gentle AI **v4.2.0** (`4acaf42`) | v4.3.0 release notes |
| Shell Pi floor | **>=1.2.0** (npm `peerDependencies`) | `registry.npmjs.org/gentle-pi/4.3.0` `peerDependencies` |
| Shell Node floor | >=22.19.0 | same `engines` field |
| Installed Shell on this host | 3.5.1 (engine 3.5.0) | `~/.pi/agent/settings.json`, `~/.pi/agent/npm/node_modules/gentle-pi/package.json` |

## Constraint graph

```
Pi floor comes ONLY from the nixpkgs pin (no pi-coding-agent overlay:
odd/tasks/gentle-upstream-v4.md:29)

STEP 1  full `nix flake update` (root) + `nix flake update root` (flake/dev)
        -> pi 1.3.0. Head of the graph: Pi >=1.2.0 blocks Shell >=4.2.0.
STEP 2  re-measure the bump debt at the new revision: parse-lix cache for
        aarch64-darwin, overlay-composition contract, herdr substitutability.
STEP 3  gentle-ai 4.1.1 -> 4.2.0 pin + fresh hashes + engine check
        expectations 168/333 in the SAME commit (RED/GREEN protocol).
STEP 4  operator: activation (`just darwin-switch wang-lin`).
STEP 5  runtime: `npm install-scripts approve gentle-pi@4.3.0` ->
        `pi install npm:gentle-pi@4.3.0` -> `gentle-ai sync`.
STEP 6  docs: version statements, Pi floor 0.99.1 -> 1.2.0, contract 1.4.0.
```

What blocks what:

1. **Pi >=1.2.0 blocks Shell >=4.2.0**, and Pi is reachable only through the
   nixpkgs lock (an overlay is explicitly rejected in-repo).
2. **The gentle-ai pin and its two engine-check expectations are one atomic
   work unit.** `checks/gentle-ai-engine/default.nix:168` (eval-time
   `packageVersion`) and `:333` (build-time `gentle-ai 4.1.1` stdout) fail the
   moment `packages/gentle-ai/package.nix:7` moves.
3. **Shell 4.3.0 no longer needs a separate engine decision:** its private
   engine is 4.2.0, so Step 3 + Step 5 make the PATH CLI and the session engine
   converge for the first time.
4. **A green `nix flake check` does not prove activation.** The recorded failure
   mode (`odd/tasks/java-dev-shells.md:163-183`) is a revision that passes
   sandbox-free CI and breaks a workstation with `sandbox = relaxed`.
5. **Ordering in Step 5 is load-bearing:** the native package swap runs last,
   and the session that performed it must not run native capture, delegation, or
   review until Pi restarts.

## Tasks

1. [ ] Create this feature document, its Engram mirror, and the visible todo list.
2. [ ] Full lock refresh: `nix flake update` in the root, then
       `nix flake update root` in `flake/dev`; record the new revisions and the
       Pi version they resolve to.
3. [ ] Re-measure the bump debt at the new revision: `parse-lix` cache
       availability for `aarch64-darwin`, the `overlay-composition` contract
       (`chromaprint`/`kvazaar`/`protonmail-bridge`), and `herdr`. Change an
       exclusion or overlay only when the measurement demands it.
4. [ ] Gentle AI 4.2.0 pin: derive the four SRI hashes three ways (publisher
       installer at the matching `gentle-shell` tag, the release
       `checksums.txt`, a local download), bump `packages/gentle-ai/package.nix`,
       and update `checks/gentle-ai-engine/default.nix:168` and `:333` in the
       same commit.
5. [ ] Verify: `nix flake check --override-input secrets
       path:./checks/fixtures/secrets` and a build of the Darwin system.
6. [ ] Doc alignment: `modules/common/ai-tools/README.md` (CLI 4.2.0, Shell pin
       4.3.0, Pi floor 1.2.0, contract 1.4.0) and this task file's evidence.
7. [ ] Operator activation, then runtime: `npm install-scripts approve
       gentle-pi`, `pi install npm:gentle-pi@4.3.0`, `gentle-ai sync`, and
       readback of the engine path and version.
8. [ ] Native review inspect on the delivered work units, then close.

## Recorded decisions

- **No `pi-coding-agent` overlay.** Pi stays owned by nixpkgs; an overlay would
  cost `hash`, `npmDepsHash`, and `modelData.hash` on every Pi release
  (`odd/tasks/gentle-upstream-v4.md:29`).
- **Full input refresh, per the operator's answer.** The alternative
  (nixpkgs-only) was offered with its smaller blast radius and declined.
- **The Shell pin stays prose + native.** This repository must not declare
  `npm:gentle-pi@<version>` as a Nix surface; `settings.json` is upstream-owned.

## Evidence log

### Task 1 — tracked plan

`odd/tasks/upstream-version-alignment.md` + Engram mirror
`odd/upstream-version-alignment/tasks` + the visible todo projection. Branch
`feat/upstream-version-alignment` from `main` `dacc4f62`.

### Task 2 — full lock refresh (done)

`nix flake update` in the root, then `nix flake update` in `flake/dev`.

| Input | Before | After |
| --- | --- | --- |
| nixpkgs (root and dev follower) | `151fa4e8` (2026-10-06) | `55bfb4d7` (2026-10-14) |
| home-manager | `fae6e9e4` | `64072597` |
| sops-nix | `dcd241ba` | `44931708` |
| nvf | `b5a8011d` | `a736b60b` |
| mcp-servers-nix | `94f673a0` | `1cba7df1` |
| nix-index-database | `e740bc4e` | `9a2dd407` |
| git-hooks-nix (dev) | `a0e4241b` | `1ba1dbfe` |
| treefmt-nix (dev) | `03d8ee1b` | `0d6d739a` |

`flake-parts`, `nix-darwin`, `nix-rosetta-builder`, `aytordev-nvim`, and
`secrets` resolved to their existing revisions. Diff: 36 lines changed in each
lock, nothing else.

**Pi resolves to 1.2.0, not 1.3.0.** `nixos-unstable` at `55bfb4d7` is from
2026-10-14, one day before the 1.3.0 release reached nixpkgs; 1.3.0 exists only
on `nixpkgs` master. Recorded decision: stay on the branch this flake tracks
(`nixos-unstable`) instead of pinning a master commit, which is unbuilt by Hydra
and would contradict the declared input URL. 1.2.0 clears Shell's `>=1.2.0`
floor, which is the actual blocker. Pi 1.3.0 becomes a plain lock refresh once
`nixos-unstable` advances.

### Task 3 — bump debt re-measured (done)

| Surface | Verdict | Evidence |
| --- | --- | --- |
| `parse-lix` (Darwin) | **stays excluded** | lix `2.95.4` outPath `/nix/store/addq3f76z4lqrgg73mj7ddm2jc4m4xjr-lix-2.95.4` → 404 on `cache.nixos.org` and 404 on the nix-community cache |
| `overlay-composition` | **green** | `.#checks.aarch64-darwin.production-overlay-composition` builds; all 11 in-file assertions hold at `55bfb4d7` |
| `herdr` 0.9.3 | **substitutable** | outPath `/nix/store/0gvmv7dkn7624v2m7bh859bx6x42xv1d-herdr-0.9.3` → 200 on `cache.nixos.org`. The old sandbox blocker does not fire |
| `chromaprint` overlay | **provable no-op** | nixpkgs 1.6.1 now sets `doCheck = !isDarwin`; the override produces a byte-identical drvPath (`3wjq80v1…`) |
| `kvazaar` overlay | **still an override, cause looks fixed** | un-overlaid, checks-enabled outPath `hjp4h31j…` is cached; a from-source re-verification was not run |
| `engram` `doCheck = false` | **stays** | the cause is the sandbox forbidding a loopback bind in `net/http/httptest`; revision-independent |

Correction recorded, not rewritten into history: `odd/tasks/java-dev-shells.md:291`
claims lix `2.95.3` is absent from the cache. It is present now (HTTP 200), so
that premise has expired. The exclusion still holds, but on `2.95.4` instead.

Scope decision: retiring `overlays/chromaprint/default.nix` is a real, provable
cleanup, but it is **not** part of this cycle — it changes the overlay set and
`checks/overlay-composition`, and the recorded repo precedent is to retire a
workaround as its own work unit. Recorded as a follow-up below.

### Task 4 — gentle-ai 4.2.0 pin (done)

Digests confirmed three ways: a local download of all four archives, the
release's own `checksums.txt`, and the publisher installer at `gentle-shell` tag
`v4.3.0`, whose `INSTALLER_VERSION` is `4.2.0`. All four agree.

| System | sha256 |
| --- | --- |
| x86_64-darwin | `8f6a91e0…12f8` |
| aarch64-darwin | `d5e9a652…7f37` |
| x86_64-linux | `552c1642…defc` |
| aarch64-linux | `2bebe91b…1a7a` |

Archive layout unchanged: root entries are `gentle-ai`, `LICENSE`, `README.md`
plus `contracts/` and `docs/`, so `installPhase` stays as-is. `gentle-pi@4.3.0`
ships exactly the ten agent ids listed in `checks/gentle-ai-engine/default.nix`
`shippedAgents`, so that list is untouched.

Verification: `nix eval` prints `4.2.0`; the package builds to
`/nix/store/j1szyqr5m4bckc0hbfz9gvsx543kvqkc-gentle-ai-4.2.0` and the isolated
binary prints exactly `gentle-ai 4.2.0`; the engine check
(`integration-gentle-ai-engine`) is green; `nix fmt` reports no changes.

### Task 6 — documentation (done)

`modules/common/ai-tools/README.md`: CLI `4.1.1` -> `4.2.0`, Shell pin
`4.1.0` -> `4.3.0`, Pi floor `0.99.1` -> `1.2.0` (with the 4.0 value kept as
history), and a new paragraph recording Shell 4.3's private engine `4.2.0` and
the review provider contract move to `1.4.0`.

## Follow-ups (not in this cycle)

1. **Retire `overlays/chromaprint/default.nix`** — provable no-op at the new
   revision (identical drvPath). Needs its own work unit because it also edits
   `checks/overlay-composition/default.nix` and the overlay inventory docs.
2. **Re-verify the `kvazaar` overlay** with a from-source, checks-enabled
   Darwin build: `nix build --rebuild --no-link --impure --expr '... .kvazaar'`.
   Its cached un-overlaid output suggests the `signal 9` cause is gone.
3. **Pi 1.3.0** — take it with a later `nix flake update` once
   `nixos-unstable` includes it (~2026-10-15+), no code change needed.
4. **Stale premise in `odd/tasks/java-dev-shells.md:291`** about lix `2.95.3`
   cache availability; correct the record if that file is next touched.
