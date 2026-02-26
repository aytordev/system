## Attribute Organization

**Impact:** MEDIUM

Organize module attributes logically: `imports`, `options`, then `config`. Inside `config`, group settings by module. Use the `cfg` pattern.

**Incorrect (Scattered configs):**

```nix
{ config, lib, pkgs, ... }:
{
  options.services.myService.enable = lib.mkEnableOption "My Service";

  home.packages = [ pkgs.git ];

  options.services.myService.port = lib.mkOption {
    type = lib.types.port;
  };

  programs.vim.enable = true;

  config = lib.mkIf config.services.myService.enable {
    home.packages = [ pkgs.curl ];
  };
}
```

**Correct (Structured):**

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
  imports = [
    ./submodule.nix
  ];

  options.services.myService = {
    enable = mkEnableOption "My Service";
    port = mkOption {
      type = types.port;
      default = 8080;
    };
  };

  config = mkIf cfg.enable {
    # Group related settings together
    programs.git.enable = true;
    programs.vim.enable = true;

    # Keep package lists consolidated
    home.packages = with pkgs; [
      curl
      wget
    ];

    # Service-specific config
    systemd.services.my-service = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.myService}/bin/start --port ${toString cfg.port}";
    };
  };
}
```
