# Feature: gentle-upstream-4-3

Reconcile the live Pi/Gentle stack with upstream: Shell `npm:gentle-pi`
4.1.0 -> 4.3.0 and the Gentle AI assets 4.1.1 -> 4.2.0. Pi stays at 1.2.0
because `nixos-unstable` (`fe132422`, 2026-10-15) still ships 1.2.0 while npm
already publishes 1.3.0.

## Specs

- **S1** (user, verbatim): "Hay que igualarlo al upstream" — align every
  runtime component with upstream, repository and machine together.
- **S2** (policy, `odd/tasks/upstream-version-alignment.md`): Pi stays owned by
  the `nixos-unstable` input. No `nixpkgs` master pin and no `pi-coding-agent`
  overlay, so Pi reaches 1.3.0 only when `nixos-unstable` advances.
- **S3** (policy, `modules/common/ai-tools/README.md`): the Shell pin remains
  versioned in `~/.pi/agent/settings.json` as `npm:gentle-pi@4.3.0` and the
  `!startup-banner.ts` extension filter is preserved.
- **S4** (safety): the install-script approval is pinned to the exact version
  (`gentle-pi@4.3.0`), never a blanket `--all` grant.

## Tasks

1. [x] Track: this file, the Engram mirror `odd/gentle-upstream-4-3/tasks`,
       and the visible todo list.
2. [x] Approve install scripts for `gentle-pi@4.3.0` (pinned) inside
       `~/.pi/agent/npm`.
3. [x] Install Shell 4.3.0 (`pi install npm:gentle-pi@4.3.0`) and verify the
       package version, the package-local engine 4.2.0, the versioned pin and
       the preserved banner filter.
4. [x] Run `gentle-ai sync` and verify `gentle-ai doctor` and
       `~/.gentle-ai/state.json`.
5. [x] Read back the whole stack (Pi channel included) and record the Pi 1.3.0
       channel block.
6. [x] Docs: evidence here, correction note in the closed alignment task, one
       work-unit commit on a branch. Delivered as `8b90baa4` (lock refresh) and
       `3c929ed9` (this record) on `feat/gentle-upstream-4-3`, PR #261, merged
       as `af643916`.
7. [ ] Independent verification, then the manual restart handoff. Verification
       ran on 2026-10-20 and passed; the restart handoff is the user's manual
       step, so this line stays open until it happens.

## Log

- L1 (user, verbatim): "Hay que igualarlo al upstream"
- L2 (user, verbatim, previous turn): "comprueba si estamos en el upstream de
  pi, gentle-ai y gentle-shell."
- L3 (evidence, 2026-10-19): upstream latest is Pi 1.3.0 (npm), Gentle AI
  v4.2.0 (2026-10-15), gentle-shell v4.3.0 / npm `gentle-pi` 4.3.0
  (2026-10-16). Live stack before this cycle: Pi 1.2.0, CLI 4.2.0, Shell 4.1.0
  with engine 4.1.1, Engram 0.4.2/3.1.0, GGA 2.10.1.
- L4 (evidence): the closed `upstream-version-alignment` task recorded
  `pi install npm:gentle-pi@4.3.0` + `gentle-ai sync` as done. The machine
  contradicts it: `pi list` reports `npm:gentle-pi@4.1.0`, only
  `.gentle-ai/v4.1.1` exists, `state.json` says `installed_binary_version`
  4.1.1 with `last_synced_at` 2026-10-13, and `gentle-ai doctor` reports the
  asset mismatch. The npm tree files are dated 2026-10-13 12:42, while the pin
  and `package-lock.json` were last written 2026-10-19 10:11-10:14.
- L5 (evidence): `nixos-unstable` tip `fe13242281a67641c0102cdb1087f0ebe586c7df`
  (2026-10-15) evaluates `pi-coding-agent` to 1.2.0, which is exactly the
  revision this flake already locks. Pi 1.3.0 is not reachable through the
  tracked channel today.
- L6 (evidence): `npm install-scripts ls` reports `gentle-pi@4.1.0` pending;
  `allowScripts` in `~/.pi/agent/npm/package.json` only approves
  `gentle-pi@4.0.0`. Node v24.21.0 and npm 11.19.0 satisfy the 4.3.0 engines
  floor (`>=22.19.0`), and Pi 1.2.0 satisfies its peer floor (`>=1.2.0`).
- L7 (user, verbatim, 2026-10-20): "commitea el progreso en work-unit, crea PR
  y mergeala a main"
- L8 (user, verbatim, 2026-10-20): "Lo de Bun debe ir en otra PR." — the
  `feat/b06-brain-devshell` commit that was sitting on the same worktree did
  not belong in this cycle's slice; it was delivered as its own PR #262.

## Evidence

### Order of operations (observed, not assumed)

`npm install-scripts approve gentle-pi@4.3.0` fails with `ENOMATCH` while that
version is not installed, so the approval cannot precede the install. The
observed sequence was therefore: `pi install npm:gentle-pi@4.3.0`, then
`npm install-scripts approve gentle-pi@4.3.0 --allow-scripts-pin`, then the
postinstall effect review. The install printed the expected gate warning
(`gentle-pi@4.3.0 (postinstall: node scripts/install-gentle-ai.mjs)` not yet
covered by `allowScripts`), yet `.gentle-ai/v4.2.0/` already existed when the
approval ran; the private engine is installed by the Shell package itself, not
only by the gated postinstall. The stale `v4.1.1` directory is gone.

### Shell 4.3.0 (S1, S3, S4)

| Check | Observed |
| --- | --- |
| `pi install` | `changed 1 package, and audited 275 packages`, exit 0, `Installed npm:gentle-pi@4.3.0` |
| Package version | `node_modules/gentle-pi/package.json` → `4.3.0` |
| `pi list` | `npm:gentle-pi@4.3.0 (filtered)` |
| Pin and filter | `source: npm:gentle-pi@4.3.0` with `extensions: ["!startup-banner.ts"]` |
| Install-script approval | `allowScripts: {"gentle-pi@4.3.0": true}`; `install-scripts ls` → none unreviewed; stale `gentle-pi@4.0.0` entry removed |
| Package-local engine | `.gentle-ai/v4.2.0/gentle-ai --version` → `gentle-ai 4.2.0` |
| Engine integrity | `integrity.json` `binarySha256` `8ea490287ef796848b0d305cf2b26265e360d3f400efc016972844498fb87097` equals the local `shasum -a 256` |
| Provider contract | `contracts/review-provider-contract-mirror/v1.4.0/bundle/manifest.json` → `contract_semver: 1.4.0` |

### Gentle AI assets (S1)

`gentle-ai sync` exited 0 with `no managed sync actions needed` / `All managed
assets are already up to date. No files changed.` — the asset installation had
already happened during the Shell install. `~/.gentle-ai/state.json` now reports
`installed_binary_version: 4.2.0` and `last_synced_at: 2026-10-19T08:26:05Z`
with a new `managed_asset_digest`. `gentle-ai doctor` moved from degraded
(asset mismatch, 8 passed/1 warning) to **9 passed, 0 failed, 0 warnings,
healthy**, including `installed:asset_version` and `pi:mcp`.

### Whole-stack readback (S2)

Pi 1.2.0 · operator CLI 4.2.0 · Shell 4.3.0 · package-local engine 4.2.0 ·
Engram npm 0.4.2 / binary 3.1.0 · GGA 2.10.1 · Node v24.21.0 · npm 11.19.0.

**Pi stays at 1.2.0 (S2).** Upstream npm publishes 1.3.0, but the tracked
channel does not carry it: the `nixos-unstable` tip is
`fe13242281a67641c0102cdb1087f0ebe586c7df` (2026-10-15T20:04:02Z), the exact
revision this flake already locks, and it evaluates `pi-coding-agent` to
1.2.0. Reaching 1.3.0 would need a `nixpkgs` master pin or an overlay, both
decided against in `odd/tasks/upstream-version-alignment.md`. Pi 1.3.0 becomes
a plain `nix flake update` once `nixos-unstable` advances.

### Session skew (restart required)

The session that wrote this record loaded Shell 4.1.0 assets and the mirrored
provider bundle `1.3.0` while the installed Shell was 4.3.0 with contract
`1.4.0`, so it attempted no native review, capture, or delegated write.

That skew is gone after the restart: the session that delivered this record
started 2026-10-20T10:00 and mirrors bundle `1.4.0` against Shell 4.3.0. Native
assessment of the delivery candidate returned medium risk, `reviewDue: false`
(`under_budget`), no Task Size high-risk escalation, and no independent
verifier; verification therefore stayed with the writer, the local
`nix flake check`, and the PR CI run.

### Delivery (2026-10-20)

| Evidence | Observed |
| --- | --- |
| Work units | `8b90baa4` lock refresh, `3c929ed9` documentation, on `feat/gentle-upstream-4-3` |
| PR and merge | PR #261, merge commit `af643916`; 4 files, +142/−9 |
| Local check | `nix flake check --override-input secrets path:./checks/fixtures/secrets` on aarch64-darwin: `all checks passed!`; the first attempt failed on this host's Darwin sandbox limit (`data object length 79212 exceeds maximum (65535)`), which is why the run needs `--option sandbox false`, as the Darwin justfile recipes already do |
| PR checks | `Check x86_64-linux` 3m7s, `Check aarch64-darwin` 48m11s, `Build dev shells` on both systems, `Check expressions`, `label` — all pass |
| Separate work unit | the Bun-only brain shell went out as PR #262 (merge `ae7f2113`) instead of riding along here |
