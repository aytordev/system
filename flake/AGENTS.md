# Flake Internal Configuration

This directory contains the core implementation of the system flake. It is structured to modularize the flake outputs and keep the top-level `flake.nix` clean.

## Directory Structure

```
flake/
├── apps/              # Flake apps loader
├── configs/           # Parameterized configurations
├── dev/               # Development partition (separate lockfile)
├── home/              # Home Manager module integration
├── overlays/          # Overlays loader
├── packages/          # System packages loader
├── tests/             # Library/unit test wiring
└── default.nix        # Entry point imported by root flake.nix
```

## How It Works

The root `flake.nix` imports `flake/default.nix`, which aggregates these modules. This "partitions" logic allows separating concerns:

- **dev**: Development environments (`devShells`, `checks`) are isolated in the `dev` directory with their own `flake.lock`. This prevents development dependencies (like language servers or formatters) from polluting the main system closure.
- **home/packages/overlays/apps**: Logic to load and expose the system configuration components.
