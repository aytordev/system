## Module Organization & Platform Separation

**Impact:** CRITICAL

Modules are strictly separated by platform. Never mix platform-specific code across directories. Auto-discovery via `importModulesRecursive` means you only need to place files correctly.

**Incorrect (Mixed Platforms):**

```nix
# Putting macOS config in nixos directory
# modules/nixos/services/yabai/default.nix  <-- WRONG
{ config, lib, ... }:
{
  # yabai is macOS-only, doesn't belong in nixos/
  services.yabai.enable = true;
  system.defaults.dock.autohide = true;
}
```

**Correct (Strict Isolation):**

```nix
# Platform-correct placement:
# modules/nixos/   → NixOS system-level (Linux only)
# modules/darwin/  → macOS system-level (nix-darwin)
# modules/home/    → Home Manager user-space (cross-platform)
# modules/common/  → Shared functionality (imported by others)

# modules/darwin/services/yabai/default.nix  <-- CORRECT
{ config, lib, ... }:
let
  cfg = config.aytordev.services.yabai;
in
{
  options.aytordev.services.yabai = {
    enable = lib.mkEnableOption "yabai window manager";
  };

  config = lib.mkIf cfg.enable {
    services.yabai.enable = true;
  };
}
```
