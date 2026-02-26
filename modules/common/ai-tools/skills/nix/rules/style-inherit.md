## Inherit Pattern

**Impact:** HIGH

When using 3 or more `lib` functions, use `inherit (lib) ...` in a `let` block. This keeps the scope clean while reducing verbosity.

**Incorrect (Repetitive Prefixing):**

```nix
{ config, lib, pkgs, ... }:
{
  options.myModule = {
    enable = lib.mkEnableOption "My Module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
  };

  config = lib.mkIf config.myModule.enable {
    services.foo = lib.mkDefault { };
  };
}
```

**Correct (Clean Inherit):**

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption mkDefault types;
in
{
  options.myModule = {
    enable = mkEnableOption "My Module";
    name = mkOption {
      type = types.str;
      default = "default";
    };
  };

  config = mkIf config.myModule.enable {
    services.foo = mkDefault { };
  };
}
```
