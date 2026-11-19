# Feature: upstream-bump-4-6 — Gentle AI CLI 4.6.0 and Gentle Shell 4.9.0

Bump the pinned Gentle AI CLI to the latest upstream release and the documented
Gentle Shell pin to the release that bundles it, while recording that Engram and
Pi are already at their latest upstream versions.

## Specs

S1. (verbatim) "Actualiza al upstream gentle-ai, engram y gentle-shell y pi."

S2. (verbatim choice) "Repo + instalación en vivo" — repo pins plus
`pi install npm:gentle-pi@4.9.0` and `gentle-ai sync` in `~/.pi`, with a settings
backup first.

S3. Upstream state measured 2026-11-19, so two of the four need no change:
- Gentle AI CLI latest `v4.6.0` (published 2026-11-18T17:15:57Z); repo pins
  4.5.0.
- Engram latest `v3.7.2` (2026-11-14); repo already pins 3.7.2 — no change.
- Gentle Shell npm `gentle-pi` latest `4.9.0`; it bundles Gentle AI `v4.6.0`
  (`08317b958`) and moves the provider contract from 1.5.0 to `1.6.0`; repo
  documents 4.8.0 (which pins 4.5.0).
- Pi `@earendil-works/pi-coding-agent` latest `1.5.2`, and nixpkgs at the locked
  rev `04906337b6d53e8bb0eaf0470ae9f070a4d4eb55` provides 1.5.2 — no change.
  Pi stays owned by `nixos-unstable` (no overlay, no master pin).

S4. The four CLI hashes must equal the release's own `checksums.txt` for
`gentle-ai_4.6.0_<arch>.tar.gz`: darwin_amd64
`57cbb8e91fe80268b64eeeba9d1f3b8645d3a36db262cbf3220143a594bf214b`, darwin_arm64
`7e939ef7593b84e52ea8c563064c0ed0fdb228fc1b6378fa0c09676695c72aac`, linux_amd64
`c645e8551f6e3f79831b142a6b087795dc3217e02e9dafb5b701dc4373b33e7d`, linux_arm64
`ab5a2f55ff41281bc41baea2ec730dcb05e8f55f3a9eea201c001693be490d32`.

S5. Every site that repeats a bumped version agrees: `package.nix` version and
provenance comment, `checks/gentle-ai-engine` `packageVersion` and the
`gentle-ai version` grep, `modules/common/ai-tools/README.md` CLI line, Shell pin
line and engine-pairing paragraph.

S6. Version-provenance comments describe behavior, not a frozen upstream version
number, where the behavior is repository-owned (the `profiles.json` `workflow`
preservation stays true across Shell upgrades).

S7. Delivery: work-unit commits on a feature branch, PR via `ghp` (never `gh`),
merge `--merge` after CI. Host activation (`just darwin-switch`) stays the
operator's action.

S8. Live install order (prior gotcha): CLI first, then Shell; any `gentle-ai
install` rewrites the pinned `npm:gentle-pi@<version>` back to the bare
`npm:gentle-pi`, so the pin must be re-applied and verified afterwards.
`~/.pi/agent/settings.json` is native-owned: back it up before the install.

## Tasks

| ID | Task | Specs | Route | Commit |
| --- | --- | --- | --- | --- |
| T1 | Bump the CLI pin to 4.6.0 with the four published SRI hashes and refresh the provenance comment | S1, S4 | inline | |
| T2 | Align the assertion and documentation sites with 4.6.0 and provider contract 1.6.0 | S1, S5 | inline | |
| T3 | Move the documented Shell pin to 4.9.0 and make the `workflow` comments version-agnostic | S1, S6 | inline | |
| T4 | Record Engram 3.7.2 and Pi 1.5.2 as already latest with the evidence above | S1, S3 | inline | |
| T5 | Verify: `nix fmt`, `integration-gentle-ai-engine` (incl. the 4.6.0 binary grep), Darwin system build | S1, S5 | inline | |
| T6 | Deliver: commits, PR, CI, merge | S7 | inline + `ghp` | |
| T7 | Live install of Shell 4.9.0 with settings backup, install-script approval, pin re-application, `gentle-ai sync` | S2, S8 | inline | |

## Log

L1. (verbatim) "Actualiza al upstream gentle-ai, engram y gentle-shell y pi."

L2. (verbatim choice) "Repo + instalación en vivo" — bump CLI 4.5.0→4.6.0 and the
documented Shell pin 4.8.0→4.9.0, and additionally run `pi install
npm:gentle-pi@4.9.0` + `gentle-ai sync` in `~/.pi` with a settings backup.

L3. Evidence gathered before any write: `ghp api` for both release tags, the
4.6.0 `checksums.txt`, four `nix store prefetch-file --hash-type sha256`
prefetches cross-checked against it (S4), the npm registry `latest` for
`gentle-pi` and `@earendil-works/pi-coding-agent`, and the nixpkgs expression at
the locked rev for `pi-coding-agent` 1.5.2.

L4. Working tree already carried the uncommitted `just up` lock bump
(`mcp-servers-nix`, `treefmt-nix_2`) from the previous request; it stays out of
this feature's commits.

L5. T5 verification: `nix fmt` exit 0, 6 files formatted 0 changed;
`nix build --no-link --print-out-paths .#checks.aarch64-darwin.integration-gentle-ai-engine`
exit 0, built `gentle-ai-4.6.0` and ran the real binary under an isolated HOME
with the `grep -qx 'gentle-ai 4.6.0'` assertion passing
(`/nix/store/ml9hb09gi3a5iw1j65d78fgmacxqac1c-ai-native-ownership-check`);
`nix build --no-link --print-out-paths .#darwinConfigurations.wang-lin.system`
exit 0 (`/nix/store/1jz24w5q217jb38axynlfmlk01v0v03d-darwin-system-26.11.ff0e21a`);
`nix eval --raw .#darwinConfigurations.wang-lin.system.drvPath` exit 0
(`/nix/store/wags4cbby2wilqrql4wxy9z9bbnm1aq6-...drv`); `nix path-info -r` on the
system out path grep-matched `gentle-ai-4.6.0` in the host closure
(`/nix/store/n5grlk2zdb2aqjz8ji5jwhf59jrkpf6z-gentle-ai-4.6.0`) plus its fish
completions.
