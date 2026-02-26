## mkIf - Conditional Config Blocks

**Impact:** CRITICAL

Use `lib.mkIf` for conditional configuration blocks. It pushes the condition down to the leaves of the configuration, allowing accurate merging. Avoid Python-style `if condition then { ... } else { ... }` for top-level config blocks, as it breaks module merging.

**Incorrect (Top-level if-else):**

Wraps the entire config set in a conditional, preventing other modules from merging into it unless the condition matches perfectly for everyone.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = lib.mkEnableOption "example module";
  };

  # This breaks merging - other modules cannot add to programs.git if this condition is false
  config = if cfg.enable then {
    programs.git.enable = true;
    programs.git.userName = "user";
  } else {
    programs.git.enable = false;
  };
}
```

**Correct (mkIf):**

Use `lib.mkIf` to guard the configuration.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  # This allows proper merging - other modules can still contribute to programs.git
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "user";
    };
  };
}
```
