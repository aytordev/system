# Flake Internal Configuration

This directory contains the core implementation of the system flake. It is structured to modularize the flake outputs and keep the top-level `flake.nix` clean.

## Directory Structure

```
flake/
├── configs/            # Parameterized configurations
├── dev/                # Development partition (separate lockfile)
├── home/               # Home Manager module integration
├── packages/           # System packages loader
├── overlays/           # Overlays loader
└── default.nix         # Entry point imported by root flake.nix
```

## How It Works

The root `flake.nix` imports `flake/default.nix`, which aggregates these modules. This "partitions" logic allows separating concerns:

- **dev**: Development environments (`devShells`, `checks`) are isolated in the `dev` directory with their own `flake.lock`. This prevents development dependencies (like language servers or formatters) from polluting the main system closure.
- **home/packages/overlays**: Logic to load and expose the system configuration components.
