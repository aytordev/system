## nix-darwin Module

**Impact:** HIGH

For macOS system configurations.

**Incorrect (Linux assumptions):**

```nix
{ config, lib, ... }:
let
  cfg = config.system.defaults.custom;
in
{
  options.system.defaults.custom.enable = lib.mkEnableOption "macOS tweaks";

  config = lib.mkIf cfg.enable {
    # Wrong: These are Linux-specific
    services.xserver.enable = true;
    boot.loader.systemd-boot.enable = true;
  };
}
```

**Correct (MacOS Defaults):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption types;
  cfg = config.system.defaults.custom;
in
{
  options.system.defaults.custom = {
    enable = mkEnableOption "macOS system tweaks";

    package = mkPackageOption pkgs "myTool" {};

    dockAutohide = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically hide and show the Dock";
    };
  };

  config = mkIf cfg.enable {
    # Package installation (nix-darwin ships environment.systemPackages)
    environment.systemPackages = [ cfg.package ];

    # macOS system defaults
    system.defaults = {
      dock = {
        autohide = cfg.dockAutohide;
        mru-spaces = false;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
      };

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    # macOS-specific services
    services.nix-daemon.enable = true;
  };
}
```
