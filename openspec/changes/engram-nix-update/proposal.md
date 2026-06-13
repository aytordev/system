# Proposal: engram-nix-update

**Date:** 2026-05-20
**Status:** draft

---

## Intent

Bump the engram MCP server from v1.7.0 to v1.15.15 (8 minor versions of drift) and add `nix-update` tooling so future version bumps require a single command instead of manual hash recomputation.

## Scope

### In Scope
- Update `version`, `hash`, and `vendorHash` in `packages/engram/package.nix` to v1.15.15
- Add `nix-update` to the dev shell (`dev-shells/`)
- Add `just update-engram` target to `Justfile`

### Out of Scope
- `modules/home/programs/terminal/tools/engram/default.nix` — HM module unchanged
- `modules/home/programs/terminal/tools/mcp/default.nix` — MCP wiring unchanged
- `modules/home/suites/development/default.nix` — suite integration unchanged
- `flake.nix` / `flake.lock` — engram stays as inline `fetchFromGitHub` (no flake input)
- Migrating to Approach B (flake input) — rejected; adds inconsistency for marginal benefit

## Capabilities

> This section is the CONTRACT between proposal and specs phases.
> The sdd-spec agent reads this to know exactly which spec files to create or update.

### New Capabilities
None — version bump and dev tooling addition with no behavioral changes.

### Modified Capabilities
None — MCP server interface, HM options, and suite wiring remain unchanged.

## Approach

Apply Approaches A + C from exploration in a single change:

1. **Version bump (A):** Edit `packages/engram/package.nix` — update `version` to `"1.15.15"`, recompute `hash` (source) and `vendorHash` (Go vendor). Use a failed build to surface the correct hashes, or run `just update-engram` once tooling is in place.
2. **Dev tooling (C):** Add `pkgs.nix-update` to the dev shell. Add `update-engram` Justfile target invoking `nix-update engram --version latest` with the correct flake attribute path.

Approach B (flake input with `flake = false`) rejected: it would be the only non-inline-fetch custom package in the repo, and `vendorHash` still requires manual recomputation — inconsistency for no net gain.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `packages/engram/package.nix` | high | `version`, `hash`, `vendorHash` updated to v1.15.15 |
| `Justfile` | low | Add `update-engram` target |
| `dev-shells/` | low | Add `pkgs.nix-update` package |

## Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `vendorHash` changed across 8 minor versions | High | Expected — recompute from failed build output; `nix-update` automates this |
| Breaking MCP API change in v1.15.x | Low | `args = ["mcp"]` interface is stable; verify `engram mcp` starts after build |
| `nix-update` attribute path mismatch | Low | Test `nix-update engram --version latest` dry-run; adjust attr flag if needed |

## Rollback Plan

`git revert` or `git checkout HEAD -- packages/engram/package.nix` restores the prior `version`/`hash`/`vendorHash` triple. The Justfile and dev shell additions are inert if not used and carry zero rollback risk. HM module, MCP wiring, and suite require no rollback action.

## Dependencies

- `pkgs.nix-update` — available in nixpkgs; no additional flake input required

## Success Criteria

- [ ] `nix build .#engram` succeeds and produces a v1.15.15 binary
- [ ] `nix fmt && nix build .#homeConfigurations.aytordev.activationPackage --dry-run` passes
- [ ] `just update-engram` runs without error inside the dev shell
- [ ] `engram mcp` starts without error after home activation
