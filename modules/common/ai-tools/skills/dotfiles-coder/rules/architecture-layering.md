## Configuration Layering

**Impact:** CRITICAL

Configuration flows in one direction (ADR-0001): reusable modules define
capabilities under `aytordev.*`, suites compose them into policy, homes and
systems select suites and provide concrete values, and builders assemble modules
without choosing policy. Put policy at the layer that owns it so the next layer
can override it.

**Incorrect (Wrong Level):**

```nix
# Defining user-specific packages in a shared common module
# modules/common/tools/default.nix
{ pkgs, ... }:
{
  # BAD: This forces spotify on ALL users on ALL hosts
  home.packages = [ pkgs.spotify ];
  programs.git.userName = "aytordev";
}
```

**Correct (Proper Layering):**

```nix
# Module layer — set overridable defaults
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.terminal.tools.git;
  user = config.aytordev.user;
in
{
  options.aytordev.programs.terminal.tools.git = {
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = lib.mkDefault user.fullName;
      userEmail = lib.mkDefault user.email;
    };
  };
}

# Home entry-point layer — per-user-per-host overrides
# homes/aarch64-darwin/aytordev@wang-lin/default.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.spotify ];
}
```
