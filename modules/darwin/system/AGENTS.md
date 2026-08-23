# Darwin System Configuration

nix-darwin system modules for macOS, exposed under
`aytordev.system.*`. These are privileged system capabilities (platform
adapters); user-facing configuration belongs in `modules/home/` per the
home-first principle.

## Module Contract V1

- Capabilities expose `enable` (and `package` when they own a primary package),
  guarded with `lib.mkIf`.
- Suites/archetypes compose with `lib.mkDefault`, never `lib.mkForce`.
- Keep activation scripts idempotent and limited to system-level state.

See `docs/decisions/0008-module-contract-v1.md`.

## Directory

- `fonts/` — system font configuration
- `input/` — keyboard, mouse, trackpad
- `interface/` — dock, menu bar, finder
- `logging/` — log rotation via newsyslog
- `networking/` — network settings
- `env/` — macOS environment variables
- `rosetta/` — Rosetta 2 and x86_64 emulation

> Modules are auto-discovered by `modules/darwin` loaders; there is no parent
> index to update. Adding a new `default.nix` here exposes it automatically.

## Adding New Configurations

1. Create a directory if no existing module fits (or reuse the nearest one).
2. Add a `default.nix` exporting the module (options + guarded config).
3. Keep it system-privileged-only; move anything user-level to `modules/home/`.

## Platform Conditionals

Use `pkgs.stdenv.hostPlatform.isDarwin` for cross-platform logic — never the
deprecated `pkgs.stdenv.isDarwin`. All modules here are Darwin-only already.

## Verification

```bash
nix flake check                 # includes synthetic-darwin + system checks
nix build .#darwinConfigurations.wang-lin.system --no-link
```