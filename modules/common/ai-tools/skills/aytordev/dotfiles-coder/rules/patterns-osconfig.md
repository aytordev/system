## osConfig Usage

**Impact:** HIGH

Add `osConfig ? { }` to function args ONLY when a home module needs to read system configuration. Always guard access with `or` fallback to prevent eval errors when Home Manager runs standalone.

**Incorrect (Unsafe Access):**

```nix
{ config, lib, osConfig, ... }:
let
  cfg = config.aytordev.programs.myApp;
in
{
  config = lib.mkIf cfg.enable {
    # Crashes if osConfig is missing (standalone HM)
    programs.myApp.sopsEnabled = osConfig.aytordev.security.sops.enable;
  };
}
```

**Correct (Guarded Access):**

```nix
{
  config,
  lib,
  osConfig ? { },  # Default to empty set
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.aytordev.programs.myApp;
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "my app";
  };

  config = mkIf cfg.enable {
    programs.myApp.extraConfig = optionalString sopsEnabled ''
      secrets-backend = sops
    '';
  };
}
```
