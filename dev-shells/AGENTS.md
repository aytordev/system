# Dev Shells Configuration

Per-project development environments provided by Nix flakes. This directory contains the definitions for individual development shells available via `nix develop`.

## Directory Structure

```
dev-shells/
├── default/            # Fallback/generic shell
├── astro-hono/         # Astro + Hono + Bun stack
├── nix/                # Nix development tools
├── node-22-lts/        # Node.js 22 LTS
├── node-24-lts/        # Node.js 24 LTS
├── node-26/            # Node.js 26 (Current)
├── python/             # Python 3.13 + uv
├── react/              # React development
└── ...
```

**Usage:** `nix develop .#<shell-name>`

## Basic Structure

Each subdirectory must contain a `default.nix` file that exports a shell derivation.

```nix
{ pkgs, mkShell, ... }:

mkShell {
  packages = with pkgs; [
    nodejs
    yarn
    # ... other tools
  ];

  shellHook = ''
    echo "🔨 My custom shell"
  '';
}
```

## How It Works

These shells are automatically discovered and exposed by `flake/dev/devshells/default.nix`.

- The `mkShell` function passed to these files is a wrapper that injects common tools (git, htop, etc.) and handles pre-commit hooks integration.
- Common tools are defined in `flake/dev/devshells/default.nix`.
- Pre-commit configuration is in `flake/dev/checks/default.nix`.

## Creating a New Shell

1. Create a new directory in `dev-shells/` with the name of your shell (e.g., `python-data`).
2. Create a `default.nix` inside it.
3. Define your packages using `pkgs`.
4. (Optional) Add a custom `shellHook`.

**Example:**

```nix
{ pkgs, mkShell, ... }:

mkShell {
  packages = with pkgs; [
    python311
    python311Packages.pandas
    python311Packages.numpy
  ];

  shellHook = ''
    echo "🐍 Python Data Science Shell"
  '';
}
```

## Available Shells

- **default**: Generic tools.
- **astro-hono**: Astro + Hono + Bun stack with pnpm workspaces and TypeScript.
- **nix**: Tools for working with Nix code (just runner).
- **node-22-lts**: Node.js 22 environment.
- **node-24-lts**: Node.js 24 environment.
- **node-26**: Node.js 26 environment.
- **python**: Python 3.13 with uv package manager.
- **react**: Frontend development with Node, pnpm, yarn, bun, and TypeScript.

## Key Files

- `flake/dev/devshells/default.nix`: The "loader" logic. It iterates over this directory, imports each `default.nix`, and wraps it with `mkShell`.
- `flake/dev/checks/default.nix`: Defines the pre-commit checks that run in these shells (if enabled).

## Platform-Specific Notes

- **Darwin (macOS)**: Pre-commit hooks are currently disabled in dev shells on Darwin due to broken Swift dependencies in nixpkgs-unstable (required by dotnet-sdk, which pre-commit uses for tests).
