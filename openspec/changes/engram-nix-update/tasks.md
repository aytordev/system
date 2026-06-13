# Tasks: engram-nix-update

**Change:** engram-nix-update
**Date:** 2026-05-21
**Status:** ready

---

## Phase 1: Dev Tooling Setup

Add `nix-update` to the nix dev shell and a Justfile recipe so future version bumps require one command.

### 1.1 — Add `nix-update` to `dev-shells/nix/default.nix`

**File:** `dev-shells/nix/default.nix`

Add `nix-update` to the existing `with pkgs;` packages list alongside `just`:

```nix
packages = with pkgs; [
  just
  nix-update
];
```

**Acceptance:** `nix-update` present in the packages list; `nix eval .#devShells.aarch64-darwin.nix` resolves without error.

---

### 1.2 — Add `update-engram` recipe to `Justfile`

**File:** `Justfile`

Insert after the `upp` recipe (after line 22), inside the existing `[group('nix')]` section:

```just
# Update engram package to latest upstream release
[group('nix')]
update-engram:
    nix-update --flake engram --version latest
```

**Acceptance:** `just --list` shows `update-engram` in the nix group; file parses without error.

---

## Phase 2: Version Bump

Bump `packages/engram/package.nix` from v1.7.0 to v1.15.15.

### 2.1 — Run `just update-engram` inside the nix dev shell (primary path)

```bash
nix develop .#nix --command just update-engram
```

`nix-update` will resolve the latest tag, recompute `hash` and `vendorHash`, and patch `packages/engram/package.nix` in place.

If `nix-update` errors with an attribute-not-found message, try these attribute variations in order and use whichever resolves:
```bash
nix-update --flake engram --version latest
nix-update --flake packages.engram --version latest
nix-update --flake aytordev.engram --version latest
```

Update the Justfile recipe (task 1.2) with the working attribute once confirmed.

**Acceptance:** `packages/engram/package.nix` shows `version = "1.15.15"` with updated `hash` and `vendorHash`.

---

### 2.2 — Fallback: manual hash recomputation (if task 2.1 cannot resolve attribute)

**File:** `packages/engram/package.nix`

**Step A — Set new version and invalidate source hash:**

```nix
version = "1.15.15";
# in fetchFromGitHub:
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

Run `nix build .#engram`. Build fails with a hash mismatch. Copy the `got:` value into `hash`.

**Step B — Invalidate vendor hash:**

```nix
vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

Run `nix build .#engram` again. Build fails with a vendor hash mismatch. Copy the `got:` value into `vendorHash`. (If `go.mod`/`go.sum` are unchanged since v1.7.0, the existing `vendorHash` may still be valid — unlikely over 8 minor versions.)

**Acceptance:** `nix build .#engram` exits 0; `./result/bin/engram --version` reports `1.15.15`.

---

## Phase 3: Verification

### 3.1 — Verify engram binary builds and reports correct version

```bash
nix build .#engram
./result/bin/engram --version
```

**Acceptance:** Build exits 0; version output contains `1.15.15`.

---

### 3.2 — Run full home-manager dry-run

```bash
nix fmt && nix build .#homeConfigurations.aytordev.activationPackage --dry-run
```

**Acceptance:** Both commands exit 0 with no errors or warnings.
