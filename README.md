<h3 align="center">
Nix Config for <a href="https://github.com/aytordev">aytordev</a>
</h3>

<p align="center">
 <a href="https://github.com/aytordev/system/stargazers"><img src="https://img.shields.io/github/stars/aytordev/system?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
 <a href="https://github.com/aytordev/system/commits"><img src="https://img.shields.io/github/last-commit/aytordev/system?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
 <a href="https://github.com/aytordev/system/actions"><img src="https://img.shields.io/github/actions/workflow/status/aytordev/system/check.yml?colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

Personal Nix configuration built with [flake-parts](https://github.com/hercules-ci/flake-parts), covering macOS via
[nix-darwin](https://github.com/LnL7/nix-darwin) and user environments via
[Home Manager](https://github.com/nix-community/home-manager).

## Table of Contents

1. [Getting Started](#getting-started)
2. [Features](#features)
3. [Private Profile Contract](#private-profile-contract)
4. [Customization](#customization)
5. [Exported Packages](#exported-packages)
6. [Verification](#verification)
7. [Contributing and Agent Guidance](#contributing-and-agent-guidance)
8. [Resources](#resources)

## Getting Started

Requires Nix with flakes enabled (see the
[NixOS Flakes wiki](https://wiki.nixos.org/wiki/Flakes)). On macOS you
additionally need nix-darwin.

```bash
git clone https://github.com/aytordev/system.git
cd system

# macOS (default host)
just darwin-build wang-lin        # build without switching
just darwin-switch wang-lin       # build and switch

# NixOS (when a Linux host exists)
sudo nixos-rebuild switch --flake .#<hostname>
```

> The flake targets `x86_64-linux` and `aarch64-darwin`. Only the macOS host
> `wang-lin` is currently configured.

## Features

- **Modular configuration**: shared (`modules/common`), macOS system
  (`modules/darwin`), and Home Manager (`modules/home`), all under the
  `aytordev.*` option namespace and governed by Module Contract V1
  ([ADR-0008](docs/decisions/0008-module-contract-v1.md)).
- **Home-First**: user programs and services live in Home Manager; system modules
  are reserved for privileged capabilities. See
  [ADR-0007](docs/decisions/0007-gui-service-ownership.md).
- **SOPS integration**: secrets managed through the private `secrets` flake and
  consumed only at the host/home boundary. CI uses a non-sensitive test double.
- **Dev partition**: development shells, formatters, and checks are isolated in
  `flake/dev` with their own lockfile, keeping the system closure clean
  ([ADR-0002](docs/decisions/0002-development-partition.md)).
- **Verification**: unit, integration, and production checks validate the
  configuration; see [ADR-0005](docs/decisions/0005-verification-levels.md).
- **Theme system**: pure-data Kanagawa palette (`aytordev.theme`) consumed by
  themed applications.
- **Custom packages and overlays**: portable nixpkgs-compatible derivations and
  overlays.
- **Project templates**: `nix flake init -t .#node`.
- **AI tooling**: agents, slash commands, and skills for agentic coding
  workflows in `modules/common/ai-tools`.

## Private Profile Contract

The private `secrets` flake is the single source of truth for personal identity
and encrypted SOPS documents. Its identity outputs are intentionally plain
metadata:

- `username`
- `useremail`
- `userfullname`

The root flake validates these fields once and passes a normalized `identity`
argument to concrete host and home configurations. Reusable modules do not
receive the private input. CI substitutes a non-sensitive test double documented
in [`checks/fixtures/secrets`](checks/fixtures/secrets/README.md).

## Customization

The configuration is split by concern:

- **`modules/common`**: reusable cross-platform modules (capabilities, suites,
  AI tooling).
- **`modules/darwin`**: nix-darwin system configuration (macOS only).
- **`modules/home`**: Home Manager user configuration (programs, services,
  suites, theme).
- **`libraries`**: custom Nix functions exported under `flake.lib`.
- **`packages`**: custom package derivations (see [Exported
  Packages](#exported-packages)).
- **`overlays`**: nixpkgs customizations via overlays.
- **`dev-shells`**: per-project development environments.
- **`templates`**: project initialization templates.
- **`systems`** and **`homes`**: per-host, per-user entry points (currently the
  single `wang-lin` host).
- **`checks`**: verification derivations (loaded by `flake/dev`).
- **`docs/decisions`**: Architecture Decision Records.

Modules are auto-managed by flake-parts and loaded from the `flake/` directory,
keeping the root `flake.nix` minimal.

## Exported Packages

Run a package directly:

```bash
nix run .#packages.aarch64-darwin.engram
```

Or reference inside a flake:

```nix
inputs.system.packages."${system}".engram
```

Available packages (built per platform in `packages/`):

- `agentapi`
- `engram`
- `luaposix`
- `meridian-plugin-opencode-scrub`
- `pencil-dev`
- `sketchybar-app-font`

## Verification

```bash
nix fmt                    # alejandra + linting (treefmt)
nix flake check            # all checks on aarch64-darwin
nix flake check --all-systems --no-build   # evaluation on both platforms
```

CI runs `nix flake check` on `x86_64-linux` and `aarch64-darwin` with the
`secrets` input substituted by the fixture. Check levels are described in
[`checks/AGENTS.md`](checks/AGENTS.md).

## Contributing and Agent Guidance

- `CONTRIBUTING.md` describes the change workflow.
- `AGENTS.md` files throughout the repository provide agent-specific context and
  the Module Contract rules.

## Resources

Other configurations that inspired this one:

- [aytordev/khanelinix](https://github.com/aytordev/khanelinix) _Original architecture_
- [JakeHamilton/config](https://github.com/jakehamilton/config)
- [FelixKrats/dotfiles](https://github.com/FelixKratz/dotfiles)
- [Fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [NotAShelf/nyx](https://github.com/NotAShelf/nyx)