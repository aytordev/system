## optionals - Conditional List Items

**Impact:** HIGH

Use `lib.optionals` (plural) to conditionally include a list of items. It returns an empty list `[]` if the condition is false, making it safe to concatenate `++`.

**Incorrect (Ternary for lists):**

Using if-then-else for lists is verbose and error-prone.

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
    enableTools = mkEnableOption "development tools";
  };

  config = mkIf cfg.enable {
    # Verbose and hard to read
    home.packages = [ pkgs.coreutils ]
      ++ (if cfg.enableTools then [ pkgs.ripgrep pkgs.fd ] else [ ])
      ++ (if pkgs.stdenv.hostPlatform.isLinux then [ pkgs.strace ] else [ ]);
  };
}
```

**Correct (optionals):**

Use `lib.optionals` for clean conditional list concatenation.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionals;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableTools = mkEnableOption "development tools";
  };

  config = mkIf cfg.enable {
    # Clean and readable with optionals
    home.packages = [
      pkgs.coreutils
    ]
    ++ optionals cfg.enableTools [
      pkgs.ripgrep
      pkgs.fd
    ]
    ++ optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.strace
    ];
  };
}
```
