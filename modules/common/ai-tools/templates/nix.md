# Nix Project

## Stack

- **Language:** Nix (flakes enabled)
- **Formatter:** nixfmt
- **Linter:** statix, deadnix

## Style Rules

- Never use `with lib;` -- use `inherit (lib) mkIf mkOption;` or inline `lib.`
- Prefer `let...in` over nested `rec` attrsets
- Use `mkIf` for conditional config, not `if...then...else`
- Prefer `lib.mkDefault` for overridable defaults in suites/archetypes
- Use `inherit` to pass identical bindings (e.g., `inherit (cfg) host port;`)
- Group `home.*` attributes under a single `home = { ... }` block (avoid repeated keys)

## File Conventions

- `kebab-case/` directories, `default.nix` entry points
- Follow `folder/default.nix` pattern for importModulesRecursive auto-discovery
- Never add explicit `imports` for sibling submodules; let the import system discover them
- Options always namespaced under `aytordev.*`

## Module Structure

```nix
{
  config, lib, pkgs, ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.aytordev.<namespace>.<name>;
in {
  options.aytordev.<namespace>.<name> = {
    enable = mkEnableOption "description";
    # ... other options
  };
  config = mkIf cfg.enable {
    # ... implementation
  };
}
```

## Testing

- `nix flake check` for full validation
- `nix build .#<config>.config.system.build.toplevel` to test builds
- `statix check <file>` for lint
- `deadnix <file>` for unused code detection

## AI Agent Notes

- Run `nix fmt` and `statix check` before committing
- Check `flake.nix` inputs for available packages and overlays
- Use `nix repl` to evaluate expressions interactively
- Respect the layering: common > darwin/nixos > home > suites > hosts
