## Common Errors

**Impact:** MEDIUM

Recognize common errors like missing semicolons, undefined variables (often missing `lib` argument), or infinite recursion in `rec` sets.

**Incorrect (Infinite Recursion):**

Creating circular dependencies in `rec` attribute sets.

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

  # Infinite recursion - x depends on y, y depends on x
  settings = rec {
    x = y;
    y = x;
  };

  # Another common mistake - self-referencing in rec
  paths = rec {
    prefix = "/usr/local";
    binDir = "${prefix}/bin";
    # This creates infinite recursion
    fullPath = "${fullPath}/extra";
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.variables.PATH = paths.fullPath;
  };
}
```

**Correct (Broken Cycle):**

Use let bindings or fix the circular reference.

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

  # Fixed - no circular dependency
  settings = {
    x = "value";
    y = "value";
  };

  # Fixed - use let binding for dependent values
  paths =
    let
      prefix = "/usr/local";
    in
    {
      inherit prefix;
      binDir = "${prefix}/bin";
      libDir = "${prefix}/lib";
      # Build path without self-reference
      fullPath = "${prefix}/bin:${prefix}/lib";
    };

  # Or avoid rec entirely by using explicit references
  otherPaths = {
    prefix = "/usr/local";
    binDir = "${otherPaths.prefix}/bin";  # Reference outer attribute
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.variables.PATH = paths.fullPath;

    # Other common error - missing semicolon
    programs.git.enable = true;  # Don't forget the semicolon

    # Undefined variable - forgot to add lib to function args
    # Would fail with: undefined variable 'lib'
    # Fix: Add lib to function arguments at top
  };
}
```
