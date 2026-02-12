## Centralized SOT (Source Of Truth)

**Impact:** CRITICAL

The `aytordev.theme` module is the single source of truth for all theming data. It abstracts the underlying theme (Kanagawa, or any future theme) and provides a unified semantic palette API for all other modules to consume. Never hardcode colors or imports in individual modules.

**Incorrect:**

**Fragmented definitions**
Importing `colors.nix` directly in module files, defining local color variables like `blue = "#..."`, or using variant-specific color names with `or` fallback chains.

**Correct:**

**Provider Consumption**
Consume `config.aytordev.theme` to access all theme data. The semantic palette provides theme-agnostic color names that work regardless of which theme or variant is active.

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.theme;
in
{
  # Access semantic colors through the central config
  programs.foo.color = cfg.palette.accent.hex;
  programs.foo.errorColor = cfg.palette.red.hex;
  programs.foo.bgColor = cfg.palette.bg.sketchybar;
}
```
