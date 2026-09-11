# Checks Configuration

System-wide checks and validations. This directory contains Nix modules that
define checks run across the system and in CI.

## How It Works

Checks are automatically discovered by `flake/dev/checks/default.nix`, which
scans this directory for subdirectories containing a `default.nix` and imports
them. The loader assigns the prefix from a hardcoded allow-list (unit/production);
any other check directory becomes integration.

## Verification Levels

- `unit-*`: Pure contracts, parsers, and architecture policies
  (`ai-tools-inventory`, `architecture-layers`, `file-parsers`,
  `home-users-contract`, `input-policy`, `library-exports`,
  `library-overlay`, `lua-shell-quoting`, `nix-unit`, `parse-lix`,
  `parse-nix`).
- `integration-*`: Synthetic Home Manager and system compositions
  (`docs-generation`, `home-bitwarden`, `home-identity`, `home-module`,
  `home-portability`,
  `module-contract`, `shell-init-uniqueness`, `shell-runtime-syntax`,
  `shell-history-privacy`, `shell-closure`, `activation-dry-run`,
  `shell-platform-consistency`, `sketchybar-theme`, `synthetic-darwin`,
  `synthetic-home`,
  `synthetic-nixos`, `system-common-suite`, `system-env`, `system-fonts`,
  `system-logging`, `system-nix-platforms`).
- `production-*`: Discovered real homes and systems; the loader also emits
  `production-home-*` and `production-darwin-*` for each discovered host
  (`home-integration`, `home-ssh`, `overlay-composition`).
- `package-builds`: Every package supported by the current platform.

The level is derived from a hardcoded allow-list in the loader; the other check
directories are treated as integration checks. Name check directories by the
behavior they test, not the level.

> `integration-docs-generation` additionally **builds `packages.docs-html`**
> (the searchable mdbook of the `aytordev.*` surface) on darwin, so CI
> validates both the committed option-index snapshot and the mdbook build.

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
4. To publish a check as `unit-*` or `production-*`, add its directory name to
   `unitCheckNames`/`productionCheckNames` in `flake/dev/checks/default.nix`;
   by default new checks are `integration-*`.

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