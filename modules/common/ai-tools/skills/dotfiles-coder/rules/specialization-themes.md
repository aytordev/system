## Theme System

**Impact:** HIGH

`aytordev.theme` is the single source of truth for all theming. Use the semantic palette API (`cfg.palette.accent.hex`, `cfg.palette.red.rgb`). Never hardcode colors or use variant-specific color names. Use `appTheme` accessors for named themes.

**Incorrect (Hardcoded Colors):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
in
{
  config = lib.mkIf cfg.enable {
    # BAD: hardcoded colors
    programs.myApp.accentColor = "#7e9cd8";

    # BAD: variant-specific names
    programs.myApp.theme =
      if config.aytordev.theme.variant == "wave"
      then "Kanagawa Wave"
      else "Kanagawa Lotus";
  };
}
```

**Correct (Semantic Palette):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
  theme = config.aytordev.theme;
in
{
  config = lib.mkIf cfg.enable {
    programs.myApp = {
      # Semantic colors — work with any theme/variant
      accentColor = theme.palette.accent.hex;
      errorColor = theme.palette.red.hex;
      bgColor = theme.palette.bg.hex;

      # Pre-calculated theme name formats
      theme = theme.appTheme.capitalized;  # "Kanagawa Wave"

      # Polarity detection
      lightMode = theme.isLight;
    };
  };
}
```
