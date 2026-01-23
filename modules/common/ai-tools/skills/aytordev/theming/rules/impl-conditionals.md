## Theme-Aware Conditionals

**Impact:** MEDIUM

Use `config.stylix.polarity` to drive logic for apps that need manual handling (e.g., loading different config files or setting flags based on "dark" vs "light").

**Incorrect:**

**Hardcoded Themes**
Hardcoding "dark" values in logic, requiring a code rewrite to switch to light mode.

**Correct:**

**Dynamic Logic**
Derive state from `config.stylix.polarity` using standard lib functions.

```nix
let
  isDark = config.stylix.polarity == "dark";
in
{
  # Dynamically switch theme string
  programs.bat.config.theme = lib.mkIf isDark "Catppuccin-mocha";
}
```
