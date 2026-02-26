## mkMerge - Combine Conditionals

**Impact:** HIGH

Use `lib.mkMerge` to combine multiple conditional blocks into a single definition. This is clearer than repeating `config = ...` multiple times or nesting if-else structures deeply.

**Incorrect (Nested spaghetti):**

Deeply nested `mkIf` calls or split config definitions that are hard to read.

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
    enableGit = mkEnableOption "git support";
    enableVim = mkEnableOption "vim support";
  };

  # Hard to read with deeply nested conditionals
  config = mkIf cfg.enable (
    if cfg.enableGit then
      {
        programs.bash.enable = true;
        programs.git.enable = true;
      } // (
        if cfg.enableVim then
          { programs.vim.enable = true; }
        else
          { }
      )
    else
      { programs.bash.enable = true; }
  );
}
```

**Correct (Clean Merge):**

Use `lib.mkMerge` to combine multiple conditional blocks cleanly.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableGit = mkEnableOption "git support";
    enableVim = mkEnableOption "vim support";
  };

  # Clean separation of concerns with mkMerge
  config = mkMerge [
    # Always enabled when module is active
    (mkIf cfg.enable {
      programs.bash.enable = true;
    })

    # Conditional git support
    (mkIf (cfg.enable && cfg.enableGit) {
      programs.git.enable = true;
    })

    # Conditional vim support
    (mkIf (cfg.enable && cfg.enableVim) {
      programs.vim.enable = true;
    })
  ];
}
```
