## Standard Module Structure

**Impact:** CRITICAL

All modules must follow the standard pattern: function args with destructuring, `let` bindings for cfg, separate `options` and `config` blocks, guard with `mkIf cfg.enable`.

**Incorrect (No Structure):**

```nix
{ config, lib, pkgs, ... }:
{
  # No options, no enable guard, hardcoded values
  environment.systemPackages = [ pkgs.hello ];
  services.myapp = {
    enable = true;
    config = "hardcoded";
  };
}
```

**Correct (Standard Pattern):**

```nix
{
  config,
  lib,
  pkgs,
  osConfig ? { },  # Only when home module needs system config
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.aytordev) mkOpt enabled;

  cfg = config.aytordev.{namespace}.{module};
in
{
  options.aytordev.{namespace}.{module} = {
    enable = mkEnableOption "{description}";
  };

  config = mkIf cfg.enable {
    # All configuration here
  };
}
```
