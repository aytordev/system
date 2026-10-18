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

1. [x] Create this feature document, its Engram mirror, and the visible todo list.
2. [x] Full lock refresh: `nix flake update` in the root, then
       `nix flake update root` in `flake/dev`; record the new revisions and the
       Pi version they resolve to.
3. [x] Re-measure the bump debt at the new revision: `parse-lix` cache
       availability for `aarch64-darwin`, the `overlay-composition` contract
       (`chromaprint`/`kvazaar`/`protonmail-bridge`), and `herdr`. Change an
       exclusion or overlay only when the measurement demands it.
4. [x] Gentle AI 4.2.0 pin: derive the four SRI hashes three ways (publisher
       installer at the matching `gentle-shell` tag, the release
       `checksums.txt`, a local download), bump `packages/gentle-ai/package.nix`,
       and update `checks/gentle-ai-engine/default.nix:168` and `:333` in the
       same commit.
5. [x] Verify: `nix flake check --override-input secrets
       path:./checks/fixtures/secrets` and a build of the Darwin system.
6. [x] Doc alignment: `modules/common/ai-tools/README.md` (CLI 4.2.0, Shell pin
       4.3.0, Pi floor 1.2.0, contract 1.4.0) and this task file's evidence.
7. [x] Operator activation, then runtime: `npm install-scripts approve
       gentle-pi`, `pi install npm:gentle-pi@4.3.0`, `gentle-ai sync`, and
       readback of the engine path and version.
8. [x] Native review inspect on the delivered work units, then close.

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

### Task 5 - verification (done)

The first `nix flake check` run (CI secrets fixture) went red, and the failure
was a **regression introduced by the bump**, not by this cycle's edits:

```
error: unknown field `osx_info_plist_exts`, expected one of `name`, `identifier`, `icon`, ...
```

`zed-editor` 1.23.2 (the version `55bfb4d7` carries) has an `installPhase` that
renames `[package.metadata.bundle-stable]` to `[package.metadata.bundle]` but
leaves the macOS keys in cargo-bundle's old schema, so `cargo bundle` aborts and
takes `production-darwin-*`, `home-manager-*`, and `activation-script` with it.
The previous pin carried zed 1.22.0 and never hit this.

Timeline, from the nixpkgs history:

| nixpkgs | zed-editor | macOS installPhase |
| --- | --- | --- |
| `151fa4e8` (previous pin) | 1.22.0 | works |
| `55bfb4d7` (nixos-unstable HEAD) | 1.23.2 | **broken**: `92b0c84387` bumped the version, `913a51e7e0` fixed the keys |
| from `913a51e7e0` (2026-10-15 08:56) | 1.24.2 | works |

`nixos-unstable` HEAD is still `55bfb4d7` (2026-10-14), so the revision that
brings Pi 1.2.0 is exactly the one that brings the broken Zed. This blocks
activation on the Darwin host, not only the check suite.

Operator decision (2026-10-17): keep tracking `nixos-unstable` and apply the
same key rename upstream used, through a Darwin-only local overlay, instead of
pinning a master commit that Hydra has not built.

Work unit `b9dc4313` adds `overlays/zed-editor/default.nix`, which migrates the
three legacy keys in `postPatch` and rewrites the pinned `installPhase` to build
with `--format osx`; pins both sides of the contract in
`checks/overlay-composition/default.nix` — the Darwin migration present, the
Linux derivation byte-identical — and updates the overlay inventory in
`overlays/AGENTS.md`.

The overlay took three iterations, and each one is worth recording because the
build is expensive and the failure modes are invisible until `installPhase`:

1. Migrating only `osx_info_plist_exts` in `installPhase` got past that key and
   failed on the next one, `osx_minimum_system_version`.
2. Migrating all three keys in `postPatch` cleared the schema and then failed
   producing a `.dmg`: the pinned `installPhase` runs a bare `cargo bundle
   --release`, which builds every format and needs `hdiutil`, absent in the
   sandbox.
3. Upstream's full fix is three key migrations **plus** `--format osx`. With
   both, zed builds.

Final evidence at `b9dc4313` (the overlay work unit):

| Check | Result |
| --- | --- |
| `production-overlay-composition` | green |
| `zed-editor` build | `/nix/store/x5v5wx0a82wv5f2kqr2ff5frifx51zi9-zed-editor-1.23.2`, `versionCheckPhase` reports `Zed 1.23.2`, bundle output is `Zed.app` only |
| `nix flake check --override-input secrets path:./checks/fixtures/secrets` | **all checks passed** (x86_64-linux omitted: incompatible with this host) |
| `nix build .#darwinConfigurations.wang-lin.system` | `/nix/store/kgx5raad3z8s6l4b09a4bfsdj3a57443-darwin-system-26.11.4cff07d` |
| closure readback | carries `pi-coding-agent` 1.2.0, `gentle-ai` 4.2.0, `zed-editor` 1.23.2, `engram` 3.1.0 |

### Lock refresh to `fe132422`

A follow-up refresh moved nixpkgs (root and dev follower) from `55bfb4d7`
(2026-10-14) to `fe132422` (nixos-unstable HEAD, 2026-10-15). It brings
zed-editor 1.24.2, satisfying the overlay's recorded retirement condition, and
simultaneously fixed the lix 2.95.4 mimalloc failure (unknown meson option
`mimalloc`) that had failed CI on x86_64-linux, via upstream `8d8ca25b2e` — no
lix overlay needed.

## Follow-ups (not in this cycle)

1. [x] **Retire `overlays/zed-editor/default.nix`** — done: the lock refresh
   to `fe132422` carries zed-editor 1.24.2, and the overlay was removed because
   its `--replace-fail` substitutions would fail against the migrated source
   (nixpkgs `913a51e7e0` already applied the same key migration and
   `--format osx`).
2. **Retire `overlays/chromaprint/default.nix`** — provable no-op at the new
   revision (identical drvPath). Needs its own work unit because it also edits
   `checks/overlay-composition/default.nix` and the overlay inventory docs.
3. **Re-verify the `kvazaar` overlay** with a from-source, checks-enabled
   Darwin build: `nix build --rebuild --no-link --impure --expr '... .kvazaar'`.
   Its cached un-overlaid output suggests the `signal 9` cause is gone.
4. **Pi 1.3.0** — take it with a later `nix flake update` once
   `nixos-unstable` includes it (nixpkgs master got it on 2026-10-15), no code
   change needed.
5. **Stale premise in `odd/tasks/java-dev-shells.md:291`** about lix `2.95.3`
   cache availability; correct the record if that file is next touched.

## Runtime and review outcome

### Native review: blocked by consent-binding expiry

The repository side is verified, so the cycle attempted the native review on the
candidate it produces: base `dacc4f62`, six commits, nine paths. `inspect`
returned `status: ready` with `fresh_target_ready`, target
`sha256:0bcbae9751ce955992136a41218e14aaaa77ee14ecf52d8290fe027f2fee1663`.

`START` never produced a usable consent envelope. Four attempts, in order:

1. `native-operation-failed` — the candidate-view `checkout-index` timed out at
   10 s. `lineage_created: false`, `mutation_performed: false`.
2. `consent-binding-stale` — binding `28eb1901-2b12-4788-ad00-797ee17d9eab`
   reported as "expired after 10 minutes without an answer".
3. `consent-binding-stale` — binding `74fc10cc-d8d0-48e7-8db5-e72bf25d2bf0`
   reported with the same message, seconds after it was issued.
4. After the two documentation commits changed the candidate to
   `sha256:24b07b96c08d2bb21891edcfb65bd8cd0285e0ccf89d19a74b745f0ad3e0dad4`
   (lineage `review-3104018e59856a5c`), `consent-binding-stale` again: binding
   `d7836f57-2baa-4b3f-a9f5-df84b8f6b071`, reported expired on issue, with
   `native_invocation_attempted: false`.

A binding that expires immediately is not a human timeout: it is the recorded
harness/provider skew. This session runs the pre-swap stack (Shell package
3.5.1, package-local engine 3.5.0) against a provider contract the engine has
already moved past. No consent envelope ever reached the relay, so there was no
human decision to record. Nothing was created and nothing was mutated:
`lineage_created: false` on all four attempts.

The resolution is the pending steps below, in this order: activation (Pi 1.2.0),
Shell 4.3.0, `gentle-ai sync`, Pi restart. The candidate identity is stable, so
the review can be started fresh after the restart against the same commit range
without redoing any work.

### Runtime steps (done)

Executed in this order, after the operator ran `just darwin-switch wang-lin`:

1. `just darwin-switch wang-lin` (operator; interactive `sudo`). Activated
   generation `xn279jym…`, whose path differs from the fixture build
   (`kgx5raad…`) because the real secrets input is used.
2. `npm install-scripts approve gentle-pi`, run inside `~/.pi/agent/npm`.
   **Correction to the original plan:** pi 1.2.0 has no `install-scripts`
   subcommand; the postinstall gate belongs to npm. Without this step the
   postinstall (`node scripts/install-gentle-ai.mjs`) never runs and the private
   engine is never installed.
3. `pi install npm:gentle-pi@4.3.0`, which keeps the versioned spec and the
   `!startup-banner.ts` filter (`pi list` reports
   `npm:gentle-pi@4.3.0 (filtered)`).
4. `gentle-ai sync`, which changed three files (Pi `settings.json`, the npm
   `package.json`, `~/.config/gga/config`) across the persona, engram, context7,
   gga, and skills components.
5. Readback: the package-local engine reports `gentle-ai 4.2.0`, identical to
   the Nix-owned CLI. The two executables converge for the first time.
6. Pi restarted; the session now runs Shell 4.3.0 with engine 4.2.0.

`gentle-ai doctor` reports 7 passed, 1 failed, 1 warning: `gga` is not on PATH
(a managed component new in 4.2.0 that this flake does not provide) and
`pi:mcp` warns that the pre-existing `-builtin:mcp` entry disables built-in MCP
while `pi-mcp-adapter` is undeclared. Both are separate findings.

### Native review: approved

The pre-swap attempts below never produced a lineage. After the restart the
same candidate started cleanly on the first try, which is the practical proof
that the harness/provider skew was the cause.

| Field | Value |
| --- | --- |
| Lineage | `review-6498b7f47335124f` |
| Target | `sha256:12d08dc7…` (base `dacc4f62`, 9 paths, 488 lines) |
| Tier / lens | `medium` / `review-reliability` |
| Forecast | 1 model run, `pi_host_relay`, acknowledged |
| Outcome | **approved** |
| Findings | `R3-001`, `checks/overlay-composition/default.nix:30`, severity `SUGGESTION`, disposition `informational` |
| Acknowledgement | `authority: burned`, `gentle-ai.review-acknowledged/v1` |

Delivery stays under ordinary repository policy: nothing is pushed, opened, or
merged by this cycle.
