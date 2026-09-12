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
  # Upstream ansiColors (catppuccin/palette palette.json). Bright entries are
  # upstream-only, so they are created here rather than taken from `raw`.
  ansi = {
    normal = {
      black = raw.subtext1;
      inherit (raw) red;
      inherit (raw) green;
      inherit (raw) yellow;
      inherit (raw) blue;
      magenta = raw.pink;
      cyan = raw.teal;
      white = raw.surface2;
    };
    bright = {
      black = raw.subtext0;
      red = mkColor "#de293e";
      green = mkColor "#49af3d";
      yellow = mkColor "#eea02d";
      blue = mkColor "#456eff";
      magenta = mkColor "#fe85d8";
      cyan = mkColor "#2d9fa8";
      white = raw.surface1;
    };
  };
in {
  isLight = true;
  rawColors = raw;
  inherit ansi;
  palette = (import ../palette.nix {inherit transparent;}) raw ansi;
}
