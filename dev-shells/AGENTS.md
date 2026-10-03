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
├── java-17/            # Java 17 LTS + Maven + Gradle
├── java-21/            # Java 21 LTS + Maven + Gradle
├── java-25/            # Java 25 LTS + Maven + Gradle
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
    echo "My custom shell"
  '';
}
```

## How It Works

These shells are automatically discovered and exposed by `flake/dev/dev-shells/default.nix`.

- The `mkShell` function passed to these files is a wrapper that injects common tools (git, htop, etc.) and handles pre-commit hooks integration.
- Common tools are defined in `flake/dev/dev-shells/default.nix`.
- Pre-commit configuration is in `flake/dev/checks/default.nix`.

## Language Shells Read the Catalog

A shell for a programming language must not list its own JDK, Node or Python
packages. The versions and the build tools live in the language catalog, and the
shell only selects one:

```nix
{ pkgs, mkShell, ... }: let
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  inherit (pkgs) lib;
in
  mkShell {
    packages = catalog.java.toolchain "21";
  }
```

`catalog.<lang>.toolchain <version>` returns the full development set and
`catalog.<lang>.runtime <version>` the minimum. The catalog also owns the JDK
pinning that keeps Maven and Gradle on the shell's own JDK. See
`modules/common/languages/AGENTS.md` and
[ADR-0018](../../docs/decisions/0018-language-pack-class.md).

`default` and `nix` are not language shells, so the catalog has nothing to say
about their packages.

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
    echo "Python Data Science Shell"
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
- **java-17**: Java 17 LTS with Maven and Gradle.
- **java-21**: Java 21 LTS with Maven and Gradle.
- **java-25**: Java 25 LTS with Maven and Gradle.
- **python**: Python 3.13 with uv package manager.
- **react**: Frontend development with Node, pnpm, yarn, bun, and TypeScript.

## Key Files

- `flake/dev/dev-shells/default.nix`: The "loader" logic. It iterates over this directory, imports each `default.nix`, and wraps it with `mkShell`.
- `flake/dev/checks/default.nix`: Defines the pre-commit checks that run in these shells (if enabled).

## Platform-Specific Notes

- **Darwin (macOS)**: Pre-commit hooks are currently disabled in dev shells on Darwin due to broken Swift dependencies in nixpkgs (required by dotnet-sdk, which pre-commit uses for tests).
