## Using the Palette

**Impact:** HIGH

The palette is exposed at `config.aytordev.theme.palette`. It provides 26 semantic colors that are resolved based on the active theme and variant. Always use semantic color names (`red`, `green`, `accent`, `bg`, etc.) — never reference theme-specific color names (like `autumnRed`, `dragonBlue`, `lotusGreen`).

**Incorrect:**

**Variant-specific fallback chains**
Using `palette.autumnRed or palette.dragonRed or palette.lotusRed` or switching on variants inside modules.

**Correct:**

**Semantic Access**
Trust `theme.palette` to provide the correct color for any theme/variant combination.

```nix
# BAD — theme-specific, breaks with other themes
color = (palette.autumnRed or palette.dragonRed or palette.lotusRed).hex;

# BAD — manual variant switching
color = if config.aytordev.theme.variant == "lotus" then "#..." else "#...";

# GOOD — semantic palette access
color = config.aytordev.theme.palette.red.hex;
```

Available semantic colors: `bg`, `bg_dim`, `bg_gutter`, `bg_float`, `bg_visual`, `fg`, `fg_dim`, `fg_reverse`, `accent`, `accent_dim`, `border`, `selection`, `overlay`, `red`, `red_bright`, `red_dim`, `green`, `yellow`, `yellow_bright`, `blue`, `blue_bright`, `orange`, `violet`, `pink`, `cyan`, `transparent`.

Each color provides four formats: `.hex`, `.rgb`, `.sketchybar`, `.raw`.
