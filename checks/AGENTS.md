# Checks Configuration

System-wide checks and validations. This directory contains Nix modules that define checks to be run across the system or in CI.

## Directory Structure

```
checks/
├── my-check/         # Example check directory
│   └── default.nix   # Check definition
└── ...
```

## How It Works

The checks are automatically discovered by `flake/dev/checks/default.nix`. It scans this directory for subdirectories containing a `default.nix` file and imports them.

## Verification Levels

- `unit-*`: Pure contracts, parsers, and architecture policies.
- `integration-*`: Synthetic Home Manager and system compositions.
- `production-*`: Discovered real homes and systems.
- `package-builds`: Every package supported by the current platform.

The loader assigns prefixes. Check directories should describe behavior rather
than repeat the level in their name.

## Creating a New Check

1. Create a new directory for your check (e.g., `checks/security-audit/`).
2. Add a `default.nix` file.
3. Define your check derivation or module.

**Example:**

```nix
{ pkgs, ... }:

pkgs.runCommand "my-check" {} ''
  echo "Running check..."
  touch $out
''
```

## Loader Logic

The auto-discovery logic resides in `flake/dev/checks/default.nix`. It uses `builtins.readDir` to find all subdirectories and `builtins.pathExists` to verify the presence of `default.nix`, then imports them.
