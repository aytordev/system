# Kanagawa Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  capitalize,
}: {
  name = "kanagawa";
  displayName = "Kanagawa";

  defaultVariant = "dragon";
  darkVariant = "dragon";
  lightVariant = "lotus";

  # Native apps with a Kanagawa resource.
  nativeApps = [
    "ghostty"
    "zed"
    "vscode"
    "tmux"
  ];

  variants = {
    wave = import ./variants/wave.nix {inherit mkColor transparent;};
    dragon = import ./variants/dragon.nix {inherit mkColor transparent;};
    lotus = import ./variants/lotus.nix {inherit mkColor transparent;};
  };

  # App theme name formatting per variant
  appTheme = variant: {
    capitalized = "Kanagawa ${capitalize variant}";
    kebab = "kanagawa-${variant}";
    underscore = "kanagawa_${variant}";
    raw = "kanagawa/${variant}";
  };
}
