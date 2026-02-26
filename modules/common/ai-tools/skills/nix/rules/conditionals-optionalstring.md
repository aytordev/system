## optionalString - Conditional Strings

**Impact:** MEDIUM

Use `lib.optionalString` to generate a string only if a condition is true. Returns `""` otherwise. Ideal for shell scripts or config files.

**Incorrect (If-then-else null):**

Using null or if-then-else for strings causes type errors.

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
    enableAliases = mkEnableOption "shell aliases";
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      export EDITOR=vim
    ''
    # This throws type error - cannot concatenate null to string
    + (if cfg.enableAliases then ''
      alias ll='ls -la'
      alias gs='git status'
    '' else null);
  };
}
```

**Correct (optionalString):**

Use `lib.optionalString` for clean conditional string concatenation.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableAliases = mkEnableOption "shell aliases";
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      export EDITOR=vim
    ''
    + optionalString cfg.enableAliases ''
      alias ll='ls -la'
      alias gs='git status'
    '';
  };
}
```
