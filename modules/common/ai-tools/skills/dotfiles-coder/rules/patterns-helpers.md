## Helper Patterns

**Impact:** HIGH

Use `enabled`/`disabled` shorthands instead of `{ enable = true; }`. Use `lib.mkOption` instead of verbose `mkOption`. Combine with `mkDefault` for overridable defaults (never `lib.mkForce`).

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
  inherit (lib) mkIf mkEnableOption mkDefault;
  inherit (lib.aytordev) enabled disabled;
  cfg = config.aytordev.programs.dev;
in
{
  options.aytordev.programs.dev = {
    enable = mkEnableOption "dev tools";
    package = lib.mkPackageOption pkgs "dev" {};
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Development server port";
    };
  };

  config = mkIf cfg.enable {
    programs.git = enabled;
    programs.vim = enabled;
    programs.tmux = disabled;

    # Override patterns
    programs.bash = mkDefault enabled;   # User can override
    programs.zsh = mkDefault enabled;    # Never mkForce — mkDefault lets hosts override
  };
}
```
