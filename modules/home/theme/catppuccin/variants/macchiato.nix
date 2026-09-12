# Catppuccin Macchiato - medium dark variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#f4dbd6";
    flamingo = mkColor "#f0c6c6";
    pink = mkColor "#f5bde6";
    mauve = mkColor "#c6a0f6";
    red = mkColor "#ed8796";
    maroon = mkColor "#ee99a0";
    peach = mkColor "#f5a97f";
    yellow = mkColor "#eed49f";
    green = mkColor "#a6da95";
    teal = mkColor "#8bd5ca";
    sky = mkColor "#91d7e3";
    sapphire = mkColor "#7dc4e4";
    blue = mkColor "#8aadf4";
    lavender = mkColor "#b7bdf8";
    text = mkColor "#cad3f5";
    subtext1 = mkColor "#b8c0e0";
    subtext0 = mkColor "#a5adcb";
    overlay2 = mkColor "#939ab7";
    overlay1 = mkColor "#8087a2";
    overlay0 = mkColor "#6e738d";
    surface2 = mkColor "#5b6078";
    surface1 = mkColor "#494d64";
    surface0 = mkColor "#363a4f";
    base = mkColor "#24273a";
    mantle = mkColor "#1e2030";
    crust = mkColor "#181926";
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
      red = mkColor "#ec7486";
      green = mkColor "#8ccf7f";
      yellow = mkColor "#e1c682";
      blue = mkColor "#78a1f6";
      magenta = mkColor "#f2a9dd";
      cyan = mkColor "#63cbc0";
      white = raw.subtext1;
    };
  };
in {
  isLight = false;
  rawColors = raw;
  inherit ansi;
  palette = (import ../palette.nix {inherit transparent;}) raw ansi;
}
