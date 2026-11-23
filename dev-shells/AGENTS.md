# Dev Shells Configuration

Per-project development environments provided by Nix flakes. This directory contains the definitions for individual development shells available via `nix develop`.

## Directory Structure

```
dev-shells/
├── default/            # Fallback/generic shell
├── nix/                # Nix development tools (only shell that installs Git hooks)
├── node-22-lts/        # Node.js 22 LTS
├── node-24-lts/        # Node.js 24 LTS
├── node-26/            # Node.js 26 Current
├── node-27/            # Node.js 27 Current, pre-release in nixpkgs
├── java-17/            # Java 17 LTS + Maven + Gradle
├── java-21/            # Java 21 LTS + Maven + Gradle
├── java-25/            # Java 25 LTS + Maven + Gradle
├── python/             # Python 3.13 + uv
├── python-314/         # Python 3.14 + uv only (direct mkShellNoCC)
└── go/                 # Go (single supported nixpkgs toolchain, from the catalog)
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

- The `mkShell` function passed to these files is a wrapper that injects common tools (git, htop, etc.). Git hook installation is NOT a per-shell choice: centrally, the wrapper installs the pre-commit hooks only for the shell named `nix`; every other wrapper shell leaves the consumer checkout untouched. Reusable minimal shells such as `python-314` use direct `pkgs.mkShellNoCC` while still selecting their language catalog toolchain.
- The `nix` shell's installation runs behind a fail-safe guard (`aytordev_should_install_git_hooks` in the wrapper): an existing user hook or a custom `core.hooksPath` makes the installer SKIP, leaving the checkout exactly as it was; only a clean checkout gets hooks. `just install-hooks` routes to the same `.#nix` path.
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
- **nix**: Tools for working with Nix code (just runner). The only shell that installs consumer Git hooks on entry.
- **node-22-lts**: Node.js 22 environment. Common tools, no Git hook installation.
- **node-24-lts**: Node.js 24 environment. Common tools, no Git hook installation.
- **node-26**: Node.js 26 environment. Common tools, no Git hook installation.
- **node-27**: Node.js 27 environment (Current line; the pinned nixpkgs carries a pre-release build). Common tools, no Git hook installation.
- **java-17**: Java 17 LTS with Maven and Gradle.
- **java-21**: Java 21 LTS with Maven and Gradle.
- **java-25**: Java 25 LTS with Maven and Gradle.
- **python**: Python 3.13 with uv package manager.
- **python-314**: Python 3.14 and uv from the catalog, using direct `pkgs.mkShellNoCC` without common tools or Git hook installation.
- **go**: Go from the language catalog (nixpkgs carries a single supported toolchain, so the catalog entry is unversioned and the shell passes `null`). Common tools, no Git hook installation.

## Key Files

- `flake/dev/dev-shells/default.nix`: The "loader" logic. It iterates over this directory, imports each `default.nix`, and wraps it with `mkShell`.
- `flake/dev/checks/default.nix`: Defines the pre-commit checks that run in these shells (if enabled).

## Platform-Specific Notes

- **Darwin (macOS)**: Only the `nix` shell installs local pre-commit hooks on shell entry, and only on a clean checkout — existing user hooks and custom `core.hooksPath` routing are skipped, never overwritten. Only the `pkgs.pre-commit` package injection is Linux-only; the installation script also runs on Darwin. Entering the `nix` shell can create `.pre-commit-config.yaml` and a hook in the consuming Git checkout. Every other shell (`mkShell`, `pkgs.mkShellNoCC`) never does.
