## Stylix Base Configuration

**Impact:** HIGH

Stylix provides the base theming substrate (Base16). Use it to set the global "mood" (polarity, wallpaper, base scheme).

**Incorrect:**

**Redundant Definitions**
Defining fonts and colors manually in every single module, ignoring the centralized Stylix configuration.

**Correct:**

**Centralized Base**
Configure Stylix once to propagate defaults everywhere.

```nix
stylix = {
  enable = true;
  image = ./wallpaper.png;
  base16Scheme = "catppuccin-mocha";
  polarity = "dark";
};
```
