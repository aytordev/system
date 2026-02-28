## 7-Level Configuration Hierarchy

**Impact:** CRITICAL

The system uses a strict 7-level priority hierarchy. Higher levels override lower levels. Place configuration at the correct level to maintain overridability.

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
# Level 3 (module) — set overridable defaults
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

# Level 7 (user config) — per-user-per-host overrides
# homes/aarch64-darwin/aytordev@wang-lin/default.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.spotify ];
}
```
