## Package Options

**Impact:** MEDIUM

Use `lib.mkPackageOption` for options that accept a package. It automatically searches `pkgs` and generates a good default description.

**Incorrect (Manual Default):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.myEditor = {
    enable = lib.mkEnableOption "My Editor";

    # Works but verbose
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vim;
      description = "The vim package to use";
    };
  };

  config = lib.mkIf config.programs.myEditor.enable {
    environment.systemPackages = [ config.programs.myEditor.package ];
  };
}
```

**Correct (Helper):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.programs.myEditor;
in
{
  options.programs.myEditor = {
    enable = mkEnableOption "My Editor";

    # Cleaner and generates better documentation
    package = mkPackageOption pkgs "git" { };

    # Can specify alternative package names
    compiler = mkPackageOption pkgs "gcc" {
      default = "clang";
      example = "gcc13";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      cfg.compiler
    ];
  };
}
```
