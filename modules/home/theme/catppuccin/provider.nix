# Catppuccin Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  capitalize,
}: {
  name = "catppuccin";
  displayName = "Catppuccin";

  defaultVariant = "mocha";
  darkVariant = "mocha";
  lightVariant = "latte";

  variants = {
    latte = import ./variants/latte.nix {inherit mkColor transparent;};
    frappe = import ./variants/frappe.nix {inherit mkColor transparent;};
    macchiato = import ./variants/macchiato.nix {inherit mkColor transparent;};
    mocha = import ./variants/mocha.nix {inherit mkColor transparent;};
  };

  # App theme name formatting per variant
  appTheme = variant: {
    capitalized = "Catppuccin ${capitalize variant}";
    kebab = "catppuccin-${variant}";
    underscore = "catppuccin_${variant}";
    raw = "catppuccin/${variant}";
  };
}
