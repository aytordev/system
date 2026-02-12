## Color Formats

**Impact:** MEDIUM

Each color in the semantic palette provides four output formats: `.hex` (`#RRGGBB`), `.rgb` (`rgb(r, g, b)`), `.sketchybar` (`0xffRRGGBB`), and `.raw` (`RRGGBB`). Use the appropriate format for your target application instead of manual string manipulation.

**Incorrect:**

**String Manipulation**
Manually replacing `#` with `0xff` or extracting RGB components from hex strings.

**Correct:**

**Built-in Formats**
Access the pre-computed format directly from the palette.

```nix
let
  palette = config.aytordev.theme.palette;
in
{
  # Each color has all four formats
  hexColor = palette.accent.hex;         # "#7e9cd8"
  sketchyColor = palette.accent.sketchybar; # "0xff7e9cd8"
  rgbColor = palette.accent.rgb;         # "rgb(126, 156, 216)"
  rawColor = palette.accent.raw;         # "7e9cd8"
}
```
