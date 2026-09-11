# Theme Library Functions
# Generic helpers for color format conversion and provider validation.
{lib}: let
  inherit (lib) stringToCharacters removePrefix;

  hexDigits = "0123456789abcdef";

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
  hexToInt = s: lib.foldl' (acc: c: acc * 16 + hexDigitToInt.${c}) 0 (stringToCharacters s);

  # Render a 0-255 integer as a two-digit lowercase hex byte.
  toHexByte = n: let
    hi = n / 16;
    lo = n - hi * 16;
  in "${builtins.substring hi 1 hexDigits}${builtins.substring lo 1 hexDigits}";

  # Parse and validate a `#RRGGBB` or `#RRGGBBAA` literal.
  parseHex = value: let
    raw = removePrefix "#" value;
    length = lib.stringLength raw;
    wellFormed = builtins.match "[0-9a-fA-F]+" raw != null;
  in
    if !(lib.hasPrefix "#" value)
    then throw "theme.mkColor: expected '#RRGGBB' or '#RRGGBBAA', got '${value}'"
    else if length != 6 && length != 8
    then throw "theme.mkColor: expected '#RRGGBB' or '#RRGGBBAA', got '${value}'"
    else if !wellFormed
    then throw "theme.mkColor: '${value}' contains non-hexadecimal characters"
    else {
      red = hexToInt (builtins.substring 0 2 raw);
      green = hexToInt (builtins.substring 2 2 raw);
      blue = hexToInt (builtins.substring 4 2 raw);
      alpha =
        if length == 8
        then hexToInt (builtins.substring 6 2 raw)
        else 255;
      inherit raw;
    };

  # Provider fields every theme family must publish.
  requiredProviderFields = [
    "name"
    "displayName"
    "defaultVariant"
    "darkVariant"
    "lightVariant"
    "variants"
    "appTheme"
  ];

  # Validate a provider attrset against the shared contract.
  # Returns the provider unchanged or throws with every discovered problem.
  validateProvider = provider: let
    missingFields = builtins.filter (field: !(provider ? ${field})) requiredProviderFields;
    variants = provider.variants or {};
    variantNames = builtins.attrNames variants;

    checkVariantRef = field: let
      value = provider.${field} or null;
    in
      if value == null
      then "missing '${field}'"
      else if !(builtins.hasAttr value variants)
      then "'${field}' = '${value}' is not one of [${lib.concatStringsSep " " variantNames}]"
      else null;

    checkPolarity = field: expected: let
      value = provider.${field} or null;
      variant = variants.${value} or null;
    in
      if variant == null
      then null
      else if variant.isLight != expected
      then "'${field}' must have isLight = ${lib.boolToString expected}"
      else null;

    errors =
      lib.optional (
        missingFields != []
      ) "missing required fields: [${lib.concatStringsSep " " missingFields}]"
      ++ lib.optional (variantNames == []) "no variants defined"
      ++ lib.optionals (missingFields == []) (
        lib.filter (error: error != null) (
          map checkVariantRef [
            "defaultVariant"
            "darkVariant"
            "lightVariant"
          ]
          ++ [
            (checkPolarity "darkVariant" false)
            (checkPolarity "lightVariant" true)
          ]
        )
      );
  in
    if errors != []
    then throw "theme provider '${provider.name or "<unnamed>"}' is invalid: ${lib.concatStringsSep "; " errors}"
    else provider;
in {
  inherit validateProvider;

  # Create a color attrset from a hex literal (#RRGGBB or #RRGGBBAA).
  # Derives all output formats from the single hex value.
  mkColor = value: let
    parsed = parseHex value;
    rgbHex = builtins.substring 0 6 parsed.raw;
    opaque = parsed.alpha == 255;
  in {
    hex = "#${parsed.raw}";
    inherit (parsed) raw;
    rgb =
      if opaque
      then "rgb(${toString parsed.red}, ${toString parsed.green}, ${toString parsed.blue})"
      else "rgba(${toString parsed.red}, ${toString parsed.green}, ${toString parsed.blue}, ${
        if parsed.alpha == 0
        then "0"
        else toString (parsed.alpha / 255.0)
      })";
    sketchybar = "0x${toHexByte parsed.alpha}${rgbHex}";
  };

  # Transparent color (special case — 8-digit hex with zero alpha)
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
