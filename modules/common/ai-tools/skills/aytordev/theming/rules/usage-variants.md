## App Themes & Variants

**Impact:** HIGH

For applications that need a named theme (e.g., "Kanagawa Wave" vs "kanagawa-wave"), use the convenience accessors in `config.aytordev.theme.appTheme`. For apps that need both dark and light theme names, use `appThemeLight`.

**Incorrect:**

**String Interpolation**
Manually constructing theme names like `"Kanagawa ${config.aytordev.theme.variant}"`.

**Correct:**

**Standardized Names**
Use the pre-calculated formats provided by the module.

```nix
# Active theme name in various formats
theme = config.aytordev.theme.appTheme.capitalized;  # "Kanagawa Wave"
theme = config.aytordev.theme.appTheme.kebab;         # "kanagawa-wave"
theme = config.aytordev.theme.appTheme.underscore;     # "kanagawa_wave"
theme = config.aytordev.theme.appTheme.raw;            # "kanagawa/wave" (for plugin paths)

# Light variant name (for apps needing both dark and light)
lightTheme = config.aytordev.theme.appThemeLight.capitalized;  # "Kanagawa Lotus"
```
