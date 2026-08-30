# Checks Configuration

System-wide checks and validations. This directory contains Nix modules that
define checks run across the system and in CI.

## How It Works

Checks are automatically discovered by `flake/dev/checks/default.nix`, which
scans this directory for subdirectories containing a `default.nix` and imports
them. The loader assigns a verification-level prefix based on the check name.

## Verification Levels

- `unit-*`: Pure contracts, parsers, and architecture policies
  (`architecture-layers`, `file-parsers`, `input-policy`,
  `library-overlay`, `lua-shell-quoting`, `nix-unit`).
- `integration-*`: Synthetic Home Manager and system compositions
  (`home-bitwarden`, `home-identity`, `home-module`, `home-portability`,
  `module-contract`, `synthetic-darwin`, `synthetic-home`, `synthetic-nixos`,
  `system-common-suite`, `system-env`, `system-fonts`,
  `system-logging`, `system-nix-platforms`).
- `production-*`: Discovered real homes and systems; the loader also emits
  `production-home-*` and `production-darwin-*` for each discovered host
  (`home-integration`, `home-ssh`, `overlay-composition`).
- `package-builds`: Every package supported by the current platform.

The level is derived from a hardcoded allow-list in the loader; the other check
directories are treated as integration checks. Name check directories by the
behavior they test, not the level.

## Secrets Handling

The private `secrets` input is removed before checks are evaluated. `identity`
is rebuilt from the injected `secrets` and passed to checks that need host
metadata. CI instead substitutes `checks/fixtures/secrets` (see its README).

## Running Checks

```bash
nix flake check                # all checks on the current platform
nix flake check --all-systems  # both supported platforms
nix flake check --no-build     # evaluation only, skip finalization
nix flake check --override-input secrets path:./checks/fixtures/secrets
```

## Creating a New Check

1. Create a new directory for your check (e.g., `checks/security-audit/`).
2. Add a `default.nix` file.
3. Define your check derivation or module.

```nix
{ pkgs, ... }:
pkgs.runCommand "my-check" {} ''
  echo "Running check..."
  touch $out
''
```

Most checks that need to run code should build a completed target
(e.g. a synthetic home or system) and assert on its configuration in Nix, then
shell-validate generated artifacts in the `runCommand` body.