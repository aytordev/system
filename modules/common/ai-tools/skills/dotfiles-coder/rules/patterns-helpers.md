## Helper Patterns

**Impact:** HIGH

Use `enabled`/`disabled` shorthands instead of `{ enable = true; }`. Use `mkOpt` instead of verbose `mkOption`. Combine with `mkDefault`/`mkForce` when needed.

**Incorrect (Verbose):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.dev;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = { enable = true; };
    programs.vim = { enable = true; };
    programs.tmux = { enable = false; };

    # Verbose option definition
    options.aytordev.programs.dev.port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Development server port";
    };
  };
}
```

**Correct (Helpers):**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault mkForce;
  inherit (lib.aytordev) mkOpt enabled disabled;
  cfg = config.aytordev.programs.dev;
in
{
  options.aytordev.programs.dev = {
    enable = mkEnableOption "dev tools";
    port = mkOpt lib.types.port 8080 "Development server port";
  };

  config = mkIf cfg.enable {
    programs.git = enabled;
    programs.vim = enabled;
    programs.tmux = disabled;

    # Override patterns
    programs.bash = mkDefault enabled;   # User can override
    programs.zsh = mkForce enabled;      # Cannot override
  };
}
```
