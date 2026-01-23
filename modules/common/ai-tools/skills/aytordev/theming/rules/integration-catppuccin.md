## Catppuccin Module Overrides

**Impact:** HIGH

Many apps have dedicated Catppuccin modules that offer better fidelity than Stylix's generic Base16 generation. When available, prefer the native Catppuccin module and disable Stylix for that specific target.

**Incorrect:**

**Double Theming**
Enabling both Stylix and the Catppuccin module for the same app, causing conflicts or unpredictable behavior.

**Correct:**

**Exclusive Override**
Enable the specific module, disable the generic one.

```nix
programs.kitty = {
  enable = true;
  catppuccin.enable = true;  # Use dedicated module
};

# Explicitly disable stylix for this target
stylix.targets.kitty.enable = false;
```
