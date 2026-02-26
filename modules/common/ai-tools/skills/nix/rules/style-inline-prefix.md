## Inline Prefix

**Impact:** MEDIUM

When using only 1 or 2 `lib` functions, just use the `lib.` prefix inline. It's explicit and avoids the boilerplate of a let block.

**Incorrect (Over-optimization):**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  config.foo = mkDefault "bar";
}
```

**Correct (Direct Access):**

```nix
{ config, lib, ... }:
{
  config.foo = lib.mkDefault "bar";
  config.baz = lib.mkForce "qux";
}
```
