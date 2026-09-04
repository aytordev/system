## Library Usage Rules

**Impact:** CRITICAL

NEVER use `with lib;` — it is completely banned. For 1-2 functions use `lib.` prefix inline. For 3+ functions use `inherit (lib)`. For aytordev helpers always use `inherit (lib.aytordev)`.

**Incorrect (with lib):**

```nix
{ config, lib, ... }:
with lib;
{
  # Where does mkIf come from? Unclear!
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
  };
  config = mkIf config.aytordev.foo.enable { };
}
```

**Correct (Explicit Access):**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.aytordev.foo;
in
{
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
    name = mkOption {
      type = types.str;
      default = "default";
      description = "Display name";
    };
  };

  config = mkIf cfg.enable {
    programs.bar = { enable = true; };
  };
}
```
