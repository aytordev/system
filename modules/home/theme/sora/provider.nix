# Sora Theme Provider
# Returns theme data conforming to the provider contract.
# Sora ships only a dark palette; the light variant is a local synthetic
# companion (see variants/light.nix).
{
  mkColor,
  transparent,
  ...
}: {
  name = "sora";
  displayName = "Sora";

  defaultVariant = "dark";
  darkVariant = "dark";
  lightVariant = "light";

  # Native apps with a Sora resource: Ghostty and Zed. tmux (ukiyo) and VS Code
  # have none, so they require an explicit override.
  nativeApps = [
    "ghostty"
    "zed"
  ];

  variants = {
    dark = import ./variants/dark.nix {inherit mkColor transparent;};
    light = import ./variants/light.nix {inherit mkColor transparent;};
  };

  # Sora ships a single native theme name, independent of the (synthetic) variant.
  appTheme = _: {
    capitalized = "Sora";
    kebab = "sora";
    underscore = "sora";
    raw = "sora";
  };
}
