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
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.programs.myApp;
in
{
  options.programs.myApp = {
    enable = mkEnableOption "My App";

    theme = mkOption {
      type = types.enum [
        "light"
        "dark"
      ];
      default = "dark";
      description = "Color theme for the application";
    };
  };

  config = mkIf cfg.enable {
    # User-level package installation
    home.packages = [ pkgs.myApp ];

    # XDG configuration file
    xdg.configFile."myapp/config.toml".text = ''
      theme = "${cfg.theme}"
      auto_save = true
    '';

    # Environment variables
    home.sessionVariables = {
      MYAPP_CONFIG = "${config.xdg.configHome}/myapp/config.toml";
    };
  };
}
```
