## Code Quality Tools

**Impact:** MEDIUM

Use `treefmt` with `nixfmt`, `statix`, and `deadnix` for automated code health. Run `nix fmt` before committing. Validate builds with `nix flake check`.

**Incorrect (No Tooling):**

```nix
# Committing unformatted code with unused variables
{config,lib,pkgs,...}:
let
  unused_var = "never used";
  cfg=config.aytordev.foo;
in {
  options.aytordev.foo={
    enable=lib.mkEnableOption "foo";
  };
  config=lib.mkIf cfg.enable {
      programs.git.enable=true;
  };
}
```

**Correct (Formatted & Clean):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.foo;
in
{
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;
  };
}
```
