# Exploration: engram-nix-update

**Change:** engram-nix-update
**Date:** 2026-05-20
**Status:** complete

---

## Executive Summary

Engram is already fully integrated into this dotfiles repo as a custom
`buildGoModule` derivation in `packages/engram/package.nix`, exposed as
`pkgs.aytordev.engram` via the auto-discovery overlay, wired as an MCP server,
and enabled by the development suite when `aiEnable = true`. The sole problem is
version drift: the repo is pinned to `v1.7.0` while upstream has released
`v1.15.15` (8 minor versions ahead). There is no automated update mechanism —
updates require manually editing `version`, `hash`, and `vendorHash` in the
derivation file. The recommended path is a version bump to `v1.15.15` combined
with adding a `just update-engram` Justfile target powered by `nix-update` to
prevent future drift.

---

## Detailed Report

### 1. Existing Engram References

| File | Role |
|------|------|
| `packages/engram/package.nix` | Custom `buildGoModule` derivation, pinned to `v1.7.0` |
| `modules/home/programs/terminal/tools/engram/default.nix` | HM module under `aytordev.programs.terminal.tools.engram`, installs `pkgs.aytordev.engram` |
| `modules/home/programs/terminal/tools/mcp/default.nix` | Wires engram as MCP server (`command = getExe pkgs.aytordev.engram`, `args = ["mcp"]`, `ENGRAM_DATA_DIR` env var) |
| `modules/home/suites/development/default.nix:161` | `engram.enable = mkDefault cfg.aiEnable` — enabled as part of AI tool suite |
| `flake.nix` | No engram flake input — source fetched inline via `fetchFromGitHub` |
| `flake.lock` | No engram entry — not tracked in lock file |

The integration is complete and idiomatic. No missing wiring; the only issue is
the stale version.

### 2. How Other MCP Servers and AI Tools Are Packaged

Three distinct patterns exist in this repo:

**Pattern A — nixpkgs direct** (`pkgs.mcp-nixos`):
Used when the package exists in nixpkgs. Zero maintenance overhead.

**Pattern B — flake input packages** (`inputs.mcp-servers-nix.packages.${system}`):
Used for `mcp-server-filesystem`. The `mcp-servers-nix` flake provides
pre-packaged MCP servers. Updates via `nix flake update mcp-servers-nix`.

**Pattern C — custom `packages/` derivation** (`pkgs.aytordev.*`):
Used for `engram`, `agentapi`, `meridian-plugin-opencode-scrub`. Applied when the
tool is not in nixpkgs or any tracked flake. Auto-discovered by
`lib.filesystem.packagesFromDirectoryRecursive` in `flake/packages/default.nix`.
Exposed as `pkgs.aytordev.{name}`. Updates are fully manual.

Engram correctly falls into Pattern C. All Pattern C packages pin a version with
hardcoded hashes — this is the established convention.

### 3. Nix Packaging Options for Engram

| Option | Feasibility | Notes |
|--------|-------------|-------|
| Custom `buildGoModule` (current) | Already done | Standard Go binary, works perfectly |
| nixpkgs package | Not available | Engram is not in nixpkgs as of 2026-05-20 |
| Flake input (`flake = false`) | Possible | Tracks source in `flake.lock`; `vendorHash` still manual |
| Upstream flake input | Unknown | Need to verify if upstream has `flake.nix` |
| npm2nix / node2nix | Not applicable | Engram is a Go binary, not Node.js |

The current `buildGoModule` approach is the correct and complete solution.
No re-packaging needed.

### 4. Current Update Mechanism and Limitations

**Mechanism:** Fully manual. To update engram:
1. Edit `version` string in `packages/engram/package.nix`
2. Update `hash` (source hash via `nix-prefetch-github` or `nix build`)
3. Update `vendorHash` (Go vendor hash — only changes when `go.mod`/`go.sum` change)

**Limitations:**
- No automation — no `nix flake update` command available (engram is not a flake input)
- Easy to fall behind: currently `v1.7.0` vs upstream `v1.15.15` (8 minor releases)
- Hash recomputation requires trial-and-error or separate tooling
- No CI check for upstream version drift

### 5. Approaches Compared

#### Approach A — Manual version bump (keep current pattern)

Update `version`, `hash`, and `vendorHash` in `packages/engram/package.nix`.

**Pros:**
- Zero structural change to the repo
- Perfectly consistent with `agentapi`, `meridian-plugin-opencode-scrub`
- `nix build .#engram` and all downstream consumers work unchanged
- Reproducible and hermetic

**Cons:**
- Fully manual — relies on developer remembering to update
- Hash recomputation friction (requires `nix-prefetch` or failed build)
- Will drift again without a process change

**Effort:** ~5 minutes per update

---

#### Approach B — Flake input with `flake = false`

Add to `flake.nix`:
```nix
engram = {
  url = "github:Gentleman-Programming/engram/v1.15.15";
  flake = false;
};
```
Replace `fetchFromGitHub` in `package.nix` with `src = inputs.engram`.

**Pros:**
- Source version tracked in `flake.lock`
- `nix flake update engram` bumps the source hash automatically
- Explicit version pinning visible in lock file

**Cons:**
- `vendorHash` still requires manual update when Go deps change (the harder part)
- Adds a flake input for a non-flake source — inconsistent with repo pattern
- All other custom packages use `fetchurl`/`fetchFromGitHub` — this would be the only exception
- Version appears in two places (`flake.nix` URL and derivation `version` var)

**Effort:** ~15 minutes to set up; ~2 minutes per update (source only)

---

#### Approach C — `nix-update` + Justfile target (recommended addition)

Keep Approach A's pattern, but add automation via `nix-update`:
```bash
# Justfile target
update-engram:
    nix-update pkgs.aytordev.engram --version latest
```

`nix-update` automatically:
- Fetches the latest GitHub release tag
- Recomputes `hash` and `vendorHash`
- Patches `packages/engram/package.nix` in place

**Pros:**
- One command to fully update engram including vendor hash
- Consistent with existing `packages/` pattern — zero structural change
- Automatable in CI/cron if desired
- `nix-update` is the standard tool for this exact use case in the Nix ecosystem

**Cons:**
- Requires `nix-update` in the dev shell (`devShells`)
- Still a manual trigger (unless wired to CI)
- First-time setup requires adding `nix-update` to dev dependencies

**Effort:** ~10 minutes to set up; ~1 minute per update

---

## Recommended Approach

**Immediate: Approach A** — bump `packages/engram/package.nix` to `v1.15.15`.
This is the smallest correct change with zero risk and resolves the current drift.

**Structural: Approach C** — add `nix-update` to the dev shell and a `just update-engram`
Justfile target. This prevents future drift without breaking the repo's established
`packages/` pattern. Approach B is not recommended because it introduces an
inconsistency for marginal benefit (`vendorHash` is still manual, and all other
custom packages use inline fetch).

**Combined scope:**
1. Update `packages/engram/package.nix`: `version`, `hash`, `vendorHash` → `v1.15.15`
2. Add `nix-update` to dev shell (check `dev-shells/` structure)
3. Add `just update-engram` target to `Justfile`

---

## Artifacts

- `packages/engram/package.nix` — derivation to update
- `modules/home/programs/terminal/tools/engram/default.nix` — HM module (no changes needed)
- `modules/home/programs/terminal/tools/mcp/default.nix` — MCP wiring (no changes needed)
- `modules/home/suites/development/default.nix` — suite integration (no changes needed)
- `flake/packages/default.nix` — auto-discovery mechanism (no changes needed)
- `Justfile` — add update target
- `dev-shells/` — add `nix-update` dependency

---

## Risks

| Risk | Severity | Notes |
|------|----------|-------|
| `vendorHash` changed between `v1.7.0` and `v1.15.15` | Likely | Go deps almost certainly changed over 8 minor versions; will need correct `vendorHash` |
| Breaking API changes in engram `v1.15.x` | Low | MCP server interface is stable; `args = ["mcp"]` pattern unlikely to change |
| `nix-update` not finding package path | Low | May need `--attr pkgs.aytordev.engram` flag tuning |

---

## Next Recommended Phase

**`sdd-propose`** — the scope is clear and bounded. Proposal should cover:
- Version bump to `v1.15.15`
- `nix-update` dev shell integration
- Justfile update target

No design phase needed (trivial change). Can go directly to `sdd-tasks` after proposal.
