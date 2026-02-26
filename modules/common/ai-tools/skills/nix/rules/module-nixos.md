## NixOS System Module

**Impact:** HIGH

For system-level services (systemd, hardware, networking).

**Incorrect (Home-manager syntax):**

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.myService;
in
{
  options.services.myService.enable = lib.mkEnableOption "My Service";

  config = lib.mkIf cfg.enable {
    # Wrong: This is Home Manager syntax
    home.packages = [ pkgs.myService ];
    xdg.configFile."myservice/config".text = "example";
  };
}
```

**Correct (Systemd Service):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.myService;
in
{
  options.services.myService = {
    enable = mkEnableOption "My Service";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/myservice";
      description = "Directory for service data";
    };
  };

  config = mkIf cfg.enable {
    # System-level package installation
    environment.systemPackages = [ pkgs.myService ];

    # System user for the service
    users.users.myservice = {
      isSystemUser = true;
      group = "myservice";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.myservice = { };

    # Systemd service definition
    systemd.services.myservice = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "myservice";
        Group = "myservice";
        ExecStart = "${pkgs.myService}/bin/myservice --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "myservice";
        WorkingDirectory = cfg.dataDir;
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
```
