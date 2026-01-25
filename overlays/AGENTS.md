# Overlays Configuration

Nixpkgs overlays. This directory contains overlays that modify or extend the package set (`pkgs`).

## Directory Structure

```
overlays/
├── google-chrome-dev/      # Example overlay
│   └── default.nix         # Overlay definition
└── ...
```

## How It Works

The overlays are automatically discovered by `flake/overlays/default.nix`. It scans this directory for subdirectories containing a `default.nix` file and imports them.

## Creating a New Overlay

1. Create a new directory in `overlays/` (e.g., `overlays/my-fix/`).
2. Create a `default.nix` file inside it.
3. Define the overlay function: `final: prev: { ... }`.

**Example:**

```nix
final: prev: {
  my-package = prev.my-package.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./fix.patch ];
  });
}
```

## Loader Logic

The auto-discovery logic resides in `flake/overlays/default.nix`. It scans the directory, filters for subdirectories, and imports them as keys in `flake.overlays`.

## Usage

These overlays are typically consumed by `flake/overlays/default.nix` or directly in the system configuration to apply globally or per-project.
