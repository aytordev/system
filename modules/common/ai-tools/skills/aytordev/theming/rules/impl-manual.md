## Manual Theme Paths

**Impact:** MEDIUM

For applications without module support, rely on standard XDG paths and conditional sourcing.

**Incorrect:**

**Absolute Paths**
Linking to files outside the nix store or using non-reproducible paths.

**Correct:**

**Conditional Source**
Select the correct source file based on the system polarity.

```nix
xdg.configFile."app/theme.conf".source =
  if config.stylix.polarity == "dark"
  then ./themes/dark.conf
  else ./themes/light.conf;
```
