---
name: aytordev-options-design
description: "aytordev option namespacing and design patterns. Use when defining module options, accessing configuration values, or understanding the aytordev.* namespace convention."
---

# Options Design

## Namespace Convention

ALL options must be under `aytordev.*`:

```nix
options.aytordev.{category}.{module}.{option} = { ... };
```

### Examples

```nix
options.aytordev.programs.terminal.tools.git.enable = ...
options.aytordev.desktop.windowManagers.hyprland.enable = ...
options.aytordev.security.sops.enable = ...
options.aytordev.user.name = ...
```

## Standard Option Pattern

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aytordev.programs.myApp;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "My App";
  };

  config = mkIf cfg.enable {
    # configuration here
  };
}
```

## Accessing User Context

```nix
let
  inherit (config.aytordev) user;
in
{
  # Use user.name, user.email, user.fullName
  programs.git.userName = user.fullName;
}
```

## Reduce Repetition

Use shared top-level options:

```nix
# Define once at top level
options.aytordev.theme.name = mkOption { ... };

# Reference throughout
config = mkIf (cfg.theme.name == "catppuccin") { ... };
```

## Option Helpers

aytordev provides helpers in `lib.aytordev`:

```nix
inherit (lib.aytordev) mkOpt enabled disabled;

# Quick enable/disable
programs.git = enabled;   # { enable = true; }
programs.foo = disabled;  # { enable = false; }

# Custom option with default
userName = mkOpt types.str "default" "User name";
```

## osConfig Access

When home modules need system config:

```nix
{
  config,
  lib,
  osConfig ? { },  # With fallback
  ...
}:

# Always guard with fallback
config = lib.mkIf (osConfig.aytordev.security.sops.enable or false) {
  # ...
};
```
