# Kanagawa Lotus - light variant
# Based on rebelot/kanagawa.nvim
{
  mkColor,
  transparent,
}: let
  raw = {
    # ─── White (Background shades) ─────────────────────────────────────────
    lotusWhite0 = mkColor "#d5cea3";
    lotusWhite1 = mkColor "#dcd5ac";
    lotusWhite2 = mkColor "#e5ddb0";
    lotusWhite3 = mkColor "#f2ecbc";
    lotusWhite4 = mkColor "#e7dba0";
    lotusWhite5 = mkColor "#e4d794";

    # ─── Shared with Wave ──────────────────────────────────────────────────
    sumiInk3 = mkColor "#1f1f28";

    # ─── Ink (Foreground shades) ───────────────────────────────────────────
    lotusInk1 = mkColor "#545464";
    lotusInk2 = mkColor "#43436c";
    lotusGray = mkColor "#dcd7ba";
    lotusGray2 = mkColor "#716e61";
    lotusGray3 = mkColor "#8a8980";

    # ─── Syntax Colors ─────────────────────────────────────────────────────
    lotusViolet1 = mkColor "#a09cac";
    lotusViolet2 = mkColor "#766b90";
    lotusViolet3 = mkColor "#c9cbd1";
    lotusViolet4 = mkColor "#624c83";
    lotusBlue1 = mkColor "#c7d7e0";
    lotusBlue2 = mkColor "#b5cbd2";
    lotusBlue3 = mkColor "#9fb5c9";
    lotusBlue4 = mkColor "#4d699b";
    lotusBlue5 = mkColor "#5d57a3";
    lotusCyan = mkColor "#d7e3d8";
    lotusGreen = mkColor "#6f894e";
    lotusGreen2 = mkColor "#6e915f";
    lotusGreen3 = mkColor "#b7d0ae";
    lotusPink = mkColor "#b35b79";
    lotusOrange = mkColor "#cc6d00";
    lotusOrange2 = mkColor "#e98a00";
    lotusYellow = mkColor "#77713f";
    lotusYellow2 = mkColor "#836f4a";
    lotusYellow3 = mkColor "#de9800";
    lotusYellow4 = mkColor "#f9d791";
    lotusRed = mkColor "#c84053";
    lotusRed2 = mkColor "#d7474b";
    lotusRed3 = mkColor "#e82424";
    lotusRed4 = mkColor "#d9a594";
    lotusAqua = mkColor "#597b75";
    lotusAqua2 = mkColor "#5e857a";
    lotusTeal1 = mkColor "#4e8ca2";
    lotusTeal2 = mkColor "#6693bf";
    lotusTeal3 = mkColor "#5a7785";
  };
in {
  isLight = true;
  rawColors = raw;
  # Upstream term[] order from rebelot/kanagawa.nvim themes.lua.
  ansi = {
    normal = {
      black = raw.sumiInk3;
      red = raw.lotusRed;
      green = raw.lotusGreen;
      yellow = raw.lotusYellow;
      blue = raw.lotusBlue4;
      magenta = raw.lotusPink;
      cyan = raw.lotusAqua;
      white = raw.lotusInk1;
    };
    bright = {
      black = raw.lotusGray3;
      red = raw.lotusRed2;
      green = raw.lotusGreen2;
      yellow = raw.lotusYellow2;
      blue = raw.lotusTeal2;
      magenta = raw.lotusViolet4;
      cyan = raw.lotusAqua2;
      white = raw.lotusInk2;
    };
  };
  palette = {
    # ─── Backgrounds ──────────────────────────────────────────────────
    bg = raw.lotusWhite3;
    bg_dim = raw.lotusWhite1;
    bg_gutter = raw.lotusWhite4;
    bg_float = raw.lotusWhite0;
    bg_visual = raw.lotusViolet3;

    # ─── Foregrounds ──────────────────────────────────────────────────
    fg = raw.lotusInk1;
    fg_dim = raw.lotusInk2;
    fg_reverse = raw.lotusGray;

    # ─── UI Elements ──────────────────────────────────────────────────
    accent = raw.lotusBlue4;
    accent_dim = raw.lotusBlue5;
    border = raw.lotusWhite4;
    selection = raw.lotusViolet3;
    overlay = raw.lotusViolet1;

    # ─── Semantic Colors ──────────────────────────────────────────────
    red = raw.lotusRed;
    red_bright = raw.lotusRed2;
    red_dim = raw.lotusRed2;
    green = raw.lotusGreen;
    yellow = raw.lotusYellow;
    yellow_bright = raw.lotusYellow2;
    blue = raw.lotusBlue4;
    blue_bright = raw.lotusTeal2;
    orange = raw.lotusOrange;
    violet = raw.lotusViolet4;
    pink = raw.lotusPink;
    cyan = raw.lotusAqua;

    # ─── Special ──────────────────────────────────────────────────────
    inherit transparent;
  };
}
