# Kanagawa Theme Library Functions
# Helper utilities for theme variant selection and naming

_:

{
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

  # ─── Theme Helpers ─────────────────────────────────────────────────────────

  # Check if a variant is a light theme
  isLightTheme = variant: variant == "lotus";

  # Get contrasting foreground for a given variant
  getContrastFg = colors: variant:
    if variant == "lotus" then colors.lotus.lotusInk1.hex
    else colors.${variant}.fg.hex;
}
