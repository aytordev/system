## Polarity Logic

**Impact:** MEDIUM

When you explicitly need to know if the theme is light or dark (e.g. for boolean flags), use `config.aytordev.theme.isLight`. This is derived from the active variant's metadata — each variant declares whether it's light or dark.

**Incorrect:**

**Fragile Checks**
Checking variant names directly to determine polarity (e.g., `variant == "lotus"`).

**Correct:**

**Computed Boolean**
Use the robust computed value.

```nix
programs.bat.config = {
  # Some apps need a boolean flag for light mode
  "--light" = lib.mkIf config.aytordev.theme.isLight;
};
```
