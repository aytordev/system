# Catppuccin Frappe - muted dark variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#f2d5cf";
    flamingo = mkColor "#eebebe";
    pink = mkColor "#f4b8e4";
    mauve = mkColor "#ca9ee6";
    red = mkColor "#e78284";
    maroon = mkColor "#ea999c";
    peach = mkColor "#ef9f76";
    yellow = mkColor "#e5c890";
    green = mkColor "#a6d189";
    teal = mkColor "#81c8be";
    sky = mkColor "#99d1db";
    sapphire = mkColor "#85c1dc";
    blue = mkColor "#8caaee";
    lavender = mkColor "#babbf1";
    text = mkColor "#c6d0f5";
    subtext1 = mkColor "#b5bfe2";
    subtext0 = mkColor "#a5adce";
    overlay2 = mkColor "#949cbb";
    overlay1 = mkColor "#838ba7";
    overlay0 = mkColor "#737994";
    surface2 = mkColor "#626880";
    surface1 = mkColor "#51576d";
    surface0 = mkColor "#414559";
    base = mkColor "#303446";
    mantle = mkColor "#292c3c";
    crust = mkColor "#232634";
  };
  # Upstream ansiColors (catppuccin/palette palette.json). Bright entries are
  # upstream-only, so they are created here rather than taken from `raw`.
  ansi = {
    normal = {
      black = raw.surface1;
      inherit (raw) red;
      inherit (raw) green;
      inherit (raw) yellow;
      inherit (raw) blue;
      magenta = raw.pink;
      cyan = raw.teal;
      white = raw.subtext0;
    };
    bright = {
      black = raw.surface2;
      red = mkColor "#e67172";
      green = mkColor "#8ec772";
      yellow = mkColor "#d9ba73";
      blue = mkColor "#7b9ef0";
      magenta = mkColor "#f2a4db";
      cyan = mkColor "#5abfb5";
      white = raw.subtext1;
    };
  };
in {
  isLight = false;
  rawColors = raw;
  inherit ansi;
  palette = (import ../palette.nix {inherit transparent;}) raw ansi;
}
