## Standard Module Structure

**Impact:** CRITICAL

Modules must follow the standard pattern: separate option declarations (`options`) from configuration implementation (`config`). Usage should always be guarded by a single `cfg.enable` flag.

**Incorrect (Mixing logic):**

```nix
{ config, lib, pkgs, ... }:
let
  myPackage = pkgs.hello;
in
{
  # No options defined
  # No enable flag

  environment.systemPackages = [ myPackage ];

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
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.myapp;
in
{
  options.services.myapp = {
    enable = mkEnableOption "My Application";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    configFile = mkOption {
      type = types.path;
      description = "Path to configuration file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myapp ];

    systemd.services.myapp = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myapp}/bin/myapp --port ${toString cfg.port} --config ${cfg.configFile}";
        Restart = "on-failure";
      };
    };
  };
}
```
