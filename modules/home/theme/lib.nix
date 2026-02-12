# Theme Library Functions
# Generic helpers for color format conversion
{lib}: let
  inherit (lib) stringToCharacters removePrefix;

  # Hex digit to integer lookup table
  hexDigitToInt = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };

  # Convert a hex string (e.g. "1f") to an integer
  hexToInt = s: let
    chars = stringToCharacters s;
  in
    lib.foldl' (acc: c: acc * 16 + hexDigitToInt.${c}) 0 chars;
in {
  # Create a color attrset from a hex string (#RRGGBB)
  # Derives all 4 output formats from the single hex value
  mkColor = hex: let
    raw = removePrefix "#" hex;
    r = hexToInt (builtins.substring 0 2 raw);
    g = hexToInt (builtins.substring 2 2 raw);
    b = hexToInt (builtins.substring 4 2 raw);
  in {
    inherit hex raw;
    rgb = "rgb(${toString r}, ${toString g}, ${toString b})";
    sketchybar = "0xff${raw}";
  };

  # Transparent color (special case — 8-digit hex with alpha)
  transparent = {
    hex = "#00000000";
    rgb = "rgba(0, 0, 0, 0)";
    sketchybar = "0x00000000";
    raw = "00000000";
  };

  # Capitalize first letter of a string
  capitalize = s: let
    len = lib.stringLength s;
  in
    if len == 0
    then ""
    else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 len s);
}
