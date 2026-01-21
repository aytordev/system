# Kanagawa Theme Library Functions
# Helper utilities for working with colors across different formats

{ lib }:

let
  inherit (lib) substring stringLength;
  inherit (builtins) floor;

  # Convert hex string to integer (for alpha manipulation)
  hexChars = {
    "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4;
    "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
    "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
  };

  hexToInt = hex:
    let
      chars = lib.stringToCharacters hex;
      len = builtins.length chars;
      convert = idx: char:
        hexChars.${char} * (lib.pow 16 (len - idx - 1));
    in
    lib.foldl' (acc: x: acc + x) 0 (lib.imap0 convert chars);

  # Convert integer to hex string (padded to 2 chars)
  intToHex = n:
    let
      hexDigits = "0123456789abcdef";
      high = floor (n / 16);
      low = n - (high * 16);
    in
    substring high 1 hexDigits + substring low 1 hexDigits;

in {
  # ─── Format Converters ────────────────────────────────────────────────────

  # Convert #RRGGBB to 0xffRRGGBB (sketchybar format)
  hexToSketchybar = hex:
    let
      raw = lib.removePrefix "#" hex;
    in
    "0xff${raw}";

  # Convert #RRGGBB to 0xAArrggbb with custom alpha (0-255)
  hexToSketchybarAlpha = hex: alpha:
    let
      raw = lib.removePrefix "#" hex;
      alphaHex = intToHex alpha;
    in
    "0x${alphaHex}${raw}";

  # Convert color attrset to just hex values
  toHexOnly = colorSet:
    lib.mapAttrs (_: color: color.hex or color) colorSet;

  # Convert color attrset to just sketchybar values
  toSketchybarOnly = colorSet:
    lib.mapAttrs (_: color: color.sketchybar or color) colorSet;

  # Convert color attrset to just raw values (RRGGBB without #)
  toRawOnly = colorSet:
    lib.mapAttrs (_: color: color.raw or (lib.removePrefix "#" (color.hex or color))) colorSet;

  # ─── Semantic Helpers ─────────────────────────────────────────────────────

  # Get the appropriate theme based on polarity
  # If polarity is "light", always use lotus regardless of variant
  getThemeForPolarity = { colors, variant, polarity }:
    if polarity == "light" then colors.lotus else colors.${variant};

  # Get the variant name suitable for application configs
  # Some apps use different naming (e.g., "Kanagawa Wave" vs "kanagawa-wave")
  variantToAppTheme = variant: style:
    let
      capitalized = {
        wave = "Wave";
        dragon = "Dragon";
        lotus = "Lotus";
      };
      kebab = {
        wave = "wave";
        dragon = "dragon";
        lotus = "lotus";
      };
    in
    if style == "capitalized" then "Kanagawa ${capitalized.${variant}}"
    else if style == "kebab" then "kanagawa-${kebab.${variant}}"
    else if style == "underscore" then "kanagawa_${kebab.${variant}}"
    else variant;

  # ─── Color Manipulation ───────────────────────────────────────────────────

  # Check if a variant is a light theme
  isLightTheme = variant: variant == "lotus";

  # Get contrasting foreground for a given variant
  getContrastFg = colors: variant:
    if variant == "lotus" then colors.lotus.lotusInk1.hex
    else colors.${variant}.fg.hex;
}
