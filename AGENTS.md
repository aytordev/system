# Aytordev System Constitution

**Flake-based NixOS/nix-darwin configuration using Home Manager and
flake-parts.**

## Core Principles

1. **Modular Architecture**: Configuration split by platform and concern
   (`modules/common`, `modules/darwin`, `modules/home`, `libraries`,
   `checks`).
2. **Namespace Scoping**: All options under `aytordev.*`.
3. **Home-First**: Prefer home-manager modules over system modules when
   possible.
4. **Functional Style**: Pure functions, minimal side effects.
5. **Module Contract V1**: Classify modules (foundational, capability, platform
   adapter, suite, archetype, pure data) before adding outputs. See
   `docs/decisions/0008-module-contract-v1.md`.

## Platforms

- Built for `x86_64-linux` and `aarch64-darwin`.
- No concrete NixOS host is configured yet; the only active host is
  `aarch64-darwin/wang-lin` (`systems/` + `homes/`).

## Essential Commands

- **Format**: `nix fmt`
- **Check build**:
  `nix build .#darwinConfigurations.wang-lin.system`
- **Run all checks**: `nix flake check`
- **CI-style check (no secrets)**:
  `nix flake check --override-input secrets path:./checks/fixtures/secrets`
- **Rebuild (Darwin)**: `just darwin-switch wang-lin`
- **Rebuild (NixOS, when a host exists)**: `sudo nixos-rebuild switch --flake .#${host}`

## Universal Style Rules

- **No `with lib;`** - use `inherit (lib)` or inline `lib.` prefix.
- **Naming**: camelCase (vars), kebab-case (files/dirs).
- **Options**: Always `aytordev.*` namespaced.
- **Conditionals**: Prefer `lib.mkIf` over `if then else`.
- **Platform conditionals**: use `pkgs.stdenv.hostPlatform.isDarwin` /
  `isLinux`, never deprecated `pkgs.stdenv.isDarwin`.

## Directory Structure

```
modules/
├── common/     # Shared cross-platform modules
├── darwin/     # nix-darwin system configuration (macOS)
└── home/       # Home Manager user configuration
libraries/      # Custom lib functions (flake.lib)
packages/       # Custom package derivations
overlays/       # nixpkgs overlays
dev-shells/     # Per-project dev environments (flake/dev partition)
templates/      # Project templates (nix flake init)
systems/        # Host-specific system config (per platform)
homes/          # Per-user Home Manager config summary (per platform)
checks/         # Verification checks (loaded by flake/dev)
docs/decisions/ # Architecture Decision Records (ADRs)
flake/          # Internal flake implementation + dev partition
```

## Secrets

- The private `secrets` flake is the only source of personal identity and SOPS
  documents. Reusable modules must never receive it; only host/home entry
  points consume `identity`.
- CI substitutes `checks/fixtures/secrets` (test double). See
  `checks/fixtures/secrets/README.md`.

## Context Loading

Agents load AGENTS.md files recursively. Each subdirectory has focused context:
- Working in `modules/darwin/`? Load nix-darwin patterns.
- Working in `modules/home/`? Load Home Manager + Module Contract patterns.
- Working in `modules/common/`? Load shared abstractions and the ai-tools
  workflow.
- Working in `checks/`? Load verification levels and loader logic.

**See subdirectory AGENTS.md files for domain-specific guidance.**