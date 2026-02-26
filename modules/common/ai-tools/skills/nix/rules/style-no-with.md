## Avoid High-Scope With

**Impact:** CRITICAL

Avoid using `with lib;` at the top of a module or file. It breaks static analysis, IDE autocompletion, and makes the origin of symbols unclear. Use it ONLY for tight, single-line scopes.

**Incorrect (Global With):**

```nix
{ config, lib, ... }:
with lib;
{
  # types, mkIf, etc. are now magical
  options.example = mkOption {
    type = types.str;
  };

  config = mkIf config.example.enable {
    # Where does mkIf come from? Unclear!
  };
}
```

**Correct (Safe With):**

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
in
{
  options.example = mkOption {
    type = types.str;
  };

  config = mkIf config.example.enable {
    # Single-line usage for lists is acceptable
    environment.systemPackages = with pkgs; [ git vim curl ];
  };
}
```
