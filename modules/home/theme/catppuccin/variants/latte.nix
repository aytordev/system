# Catppuccin Latte - light variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#dc8a78";
    flamingo = mkColor "#dd7878";
    pink = mkColor "#ea76cb";
    mauve = mkColor "#8839ef";
    red = mkColor "#d20f39";
    maroon = mkColor "#e64553";
    peach = mkColor "#fe640b";
    yellow = mkColor "#df8e1d";
    green = mkColor "#40a02b";
    teal = mkColor "#179299";
    sky = mkColor "#04a5e5";
    sapphire = mkColor "#209fb5";
    blue = mkColor "#1e66f5";
    lavender = mkColor "#7287fd";
    text = mkColor "#4c4f69";
    subtext1 = mkColor "#5c5f77";
    subtext0 = mkColor "#6c6f85";
    overlay2 = mkColor "#7c7f93";
    overlay1 = mkColor "#8c8fa1";
    overlay0 = mkColor "#9ca0b0";
    surface2 = mkColor "#acb0be";
    surface1 = mkColor "#bcc0cc";
    surface0 = mkColor "#ccd0da";
    base = mkColor "#eff1f5";
    mantle = mkColor "#e6e9ef";
    crust = mkColor "#dce0e8";
  };
in {
  isLight = true;
  rawColors = raw;
  palette = (import ../palette.nix {inherit transparent;}) raw;
}
