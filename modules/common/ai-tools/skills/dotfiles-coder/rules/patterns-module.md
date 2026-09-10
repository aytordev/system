## Standard Module Structure

**Impact:** CRITICAL

Every module is a function `args → attrset` with three invariants: destructured
args, a `cfg` binding, and separate `options` (the declared state) from `config`
(a pure derivation of it). All outputs are guarded by a single `mkIf cfg.enable`.

> **Note:** `lib.aytordev.mkModule` is a TEST-ONLY helper (used only by
> `tests/default.nix`). Real modules are authored by hand in the `args → attrset`
> shape shown here.

**Incorrect (No Structure):**

```nix
{ config, lib, pkgs, ... }:
{
  # No options, no enable guard, hardcoded (non-replaceable) package
  environment.systemPackages = [ pkgs.hello ];
  services.myapp = {
    enable = true;
    config = "hardcoded";
  };
}
```

**Correct (Canonical Capability — the default shape):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  # `inherit (lib)` for 3+ symbols; `lib.` inline for 1-2. Never `with lib;`.
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption types;
  cfg = config.aytordev.programs.terminal.tools.<tool>;
in {
  options.aytordev.programs.terminal.tools.<tool> = {
    enable = mkEnableOption "<tool>";

    # Only if this module owns a primary package (ADR-0008). Otherwise omit it
    # and register in checks/module-contract only when package-owning. Use the
    # manual form when the default is conditional (pi, bitwarden-cli):
    #   package = lib.mkOption { type = lib.types.package; default = ...;
    #     defaultText = lib.literalExpression "..."; };
    package = mkPackageOption pkgs "<tool>" {};

    # `lib.mkOption` directly — `mkOpt`/`mkBoolOpt` are for foundational modules.
    setting = mkOption {
      type = types.bool;
      default = false;
      description = "...";
    };
  };

  config = mkIf cfg.enable {
    # Prefer the Home Manager module when it exists (it already installs the
    # package). If there is no `programs.<tool>` module, use `home.packages`.
    programs.<tool> = {
      enable = true;
      inherit (cfg) package;
    };

    # Configure via `programs.<tool>.settings` (attrset) or `lib.generators.toYAML`.
    # Hand-built `xdg.configFile` strings are only for bash/conf.d drop-ins or
    # apps without a Home Manager module.
  };
}
```

## Variants by Module Class

The class drives the shape; choose one before writing outputs
(ADR-0008). A capability is the most common; the others differ in a few keys:

| Class | `enable` + `package` | Guard | Outputs |
|---|---|---|---|
| Capability | both | `mkIf cfg.enable` | owns the program/service |
| Foundational | neither | `mkIf cfg.enable` | publishes identity/metadata only |
| Platform adapter | both | `mkIf cfg.enable` **+** `isDarwin`/`isLinux` | bridges a capability to one platform |
| Suite | neither | `mkIf cfg.enable` | composes capabilities with **`lib.mkDefault`** |
| Archetype | neither | `mkIf cfg.enable` | composes suites with `lib.mkDefault` |
| Pure data | neither | **no `enable`** | computes values (`theme`, `shells.enabledNames`) |

Reference real examples instead of synthesizing: `modules/home/theme`,
`modules/home/user`, `modules/darwin/archetypes/personal`,
`modules/home/suites/development`.

## Style Rules

- `options` then `config`, separated; `cfg` is always the module's config binding.
- `let-in`, never `rec`; kebab-case files, camelCase attrs.
- Namespace `aytordev.{category}.{subcategory}.{module}`; the directory's
  `default.nix` is the only discovered module and owns the namespace — split
  helpers into sibling files and `import` them.
- Platform-only outputs guard with `pkgs.stdenv.hostPlatform.isDarwin` or
  `isLinux` (never the deprecated `stdenv.isDarwin`); prefer `lib.mkIf`.
- Conditions use `lib.mkIf` over `if-then-else`; lists use `optionals`, sets use
  `optionalAttrs`.
- Suites/archetypes compose with `lib.mkDefault` (never `lib.mkForce`) so hosts
  can override every choice.

## Optional Sections

Not canonical, but common enough that add them only when needed:

- `home.sessionVariables` — env the tool needs.
- `home.shellAliases` — use `lib.getExe cfg.package` for the binary; values must
  be a single command (no `;`/`$(`/`command `/pipeline) and must not duplicate a
  bash `conf.d` drop-in.
- `home.activation.<name>Dir` — `mkdir -p` + `chmod 700` for privacy-sensitive
  data dirs, guarded with `$DRY_RUN_CMD`.
- `assertions = [ { assertion = ...; message = "..."; } ]` — invariants
  (signing key set, env-name validity).
- Shell integration — only if the Home Manager module exposes `enable*Integration`;
  prefer exposing them as `aytordev.*` options defaulting to
  `(lib.aytordev.shellIntegration config).shellEnabled "<shell>"` (starship,
  atuin) over the blind `// flags` merge. Some tools intentionally exclude a
  shell (eza keeps nushell's built-in `ls`).
- `osConfig? {}` / `inputs` / `system` args — only when the module needs system
  config or flake inputs (suites, ai-tools).

## Sources

- `docs/decisions/0008-module-contract-v1.md` — the module contract and class table.
- `checks/module-contract` — register a capability there when it owns a package.
