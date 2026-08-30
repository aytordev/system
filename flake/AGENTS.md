# Flake Internal Configuration

This directory contains the core implementation of the system flake. It is structured to modularize the flake outputs and keep the top-level `flake.nix` clean.

## Directory Structure

```
flake/
├── apps/              # Flake apps loader
├── configs/           # Parameterized configurations
├── dev/               # Development partition (separate lockfile)
├── docs/              # aytordev.* option docs generation
├── home/              # Home Manager module integration
├── overlays/          # Overlays loader
├── packages/          # System packages loader
└── default.nix        # Entry point imported by root flake.nix
```

## How It Works

The root `flake.nix` imports `flake/default.nix`, which aggregates these modules. This "partitions" logic allows separating concerns:

- **dev**: Development environments (`devShells`, `checks`) are isolated in the `dev` directory with their own `flake.lock`. This prevents development dependencies (like language servers or formatters) from polluting the main system closure.
- **home/packages/overlays/apps**: Logic to load and expose the system configuration components.
- **docs**: Renders the `aytordev.*` option surface (darwin + home) as CommonMark
  using synthetic arguments so no secrets are required.
  `packages.docs-options` exposes the markdown plus a compact per-option index
  (`##` headers, stable vs store paths); `packages.docs-html` builds a
  searchable **mdbook** from the same markdown and `apps.docs-html` opens it in
  the browser. On Linux both packages no-op so CI never evaluates darwinSystem.
  `generate.nix` is the shared implementation reused by
  `checks/docs-generation`, which validates index drift AND gates the mdbook
  build on darwin.
