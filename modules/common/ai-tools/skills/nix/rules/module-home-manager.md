## Home Manager Module

**Impact:** HIGH

For user-level applications and dotfiles.

**Incorrect (System-level syntax):**

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myApp;
in
{
  options.programs.myApp.enable = lib.mkEnableOption "My App";

  config = lib.mkIf cfg.enable {
    # Wrong: These are system-level options
    environment.systemPackages = [ pkgs.myApp ];
    networking.hostName = "my-host";
  };
}
```

**Correct (User Application):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption types;
  cfg = config.aytordev.programs.myApp;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "My App";

    package = mkPackageOption pkgs "myApp" {};

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Settings passed to the myApp Home Manager module";
    };
  };

  config = mkIf cfg.enable {
    # Prefer the Home Manager module when it exists (it installs the package).
    programs.myApp = {
      enable = true;
      inherit (cfg) package;
      settings = cfg.settings;
    };

    # Only when there is no `programs.myApp` HM module, fall back to manual
    # installation and config (home.packages = [ cfg.package ] / a hand-built
    # xdg.configFile, as shown above).
  };
}
```
