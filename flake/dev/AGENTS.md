# Development Partition

This directory acts as a nested flake specifically for development inputs and outputs. It uses `flake-parts` partitioning to maintain a separate `flake.lock`.

## Directory Structure

```
flake/dev/
├── checks/             # Pre-commit checks loader
├── dev-shells/         # Auto-discovery for dev-shells
├── flake.lock          # Independent lockfile for dev tools
├── flake.nix           # Development inputs definition
└── default.nix         # Dev partition entry point
```

## Why Partitioning?

We partition the development configuration to:

1. **Reduce Bloat**: Development inputs (like `nixpkgs` for a specific Node version, or `treefmt`, `pre-commit`) don't bloat the main system lockfile.
2. **Independence**: You can update development tools (flake/dev/flake.lock) without forcing a rebuild of the entire system, and vice versa.

## Updating

To update the development dependencies (e.g., if a new Node.js version is needed):

```bash
nix flake update --flake ./flake/dev
```

## Components

- **dev-shells**: Contains the logic to load shells from `../../dev-shells`. It also handles platform-specific quirks (like disabling pre-commit on Darwin due to broken dependencies).
- **checks**: Loads checks from `../../checks` and defines the `pre-commit` configuration.
