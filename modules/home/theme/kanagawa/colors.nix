# Kanagawa Color Palette
# Based on rebelot/kanagawa.nvim
# https://github.com/rebelot/kanagawa.nvim
#
# All colors derive hex, rgb, sketchybar, and raw formats via mkColor.
# Three variants: wave (default dark), dragon (darker muted), lotus (light).
{mkColor}: {
  # ═══════════════════════════════════════════════════════════════════════════
  # WAVE - Default Dark Theme
  # ═══════════════════════════════════════════════════════════════════════════
  wave = {
    # ─── Ink Colors (Background shades) ────────────────────────────────────
    sumiInk0 = mkColor "#16161d";
    sumiInk1 = mkColor "#181820";
    sumiInk2 = mkColor "#1a1a22";
    sumiInk3 = mkColor "#1f1f28";
    sumiInk4 = mkColor "#2a2a37";
    sumiInk5 = mkColor "#363646";
    sumiInk6 = mkColor "#54546d";

    # ─── Foreground Colors ─────────────────────────────────────────────────
    fujiWhite = mkColor "#dcd7ba";
    oldWhite = mkColor "#c8c093";
    fujiGray = mkColor "#727169";

    # ─── Syntax Colors ─────────────────────────────────────────────────────
    oniViolet = mkColor "#957fb8";
    oniViolet2 = mkColor "#b8b4d0";
    crystalBlue = mkColor "#7e9cd8";
    springViolet1 = mkColor "#938aa9";
    springViolet2 = mkColor "#9cabca";
    springBlue = mkColor "#7fb4ca";
    lightBlue = mkColor "#a3d4d5";
    waveAqua1 = mkColor "#6a9589";
    waveAqua2 = mkColor "#7aa89f";
    springGreen = mkColor "#98bb6c";
    boatYellow1 = mkColor "#938056";
    boatYellow2 = mkColor "#c0a36e";
    carpYellow = mkColor "#e6c384";
    sakuraPink = mkColor "#d27e99";
    waveRed = mkColor "#e46876";
    peachRed = mkColor "#ff5d62";
    surimiOrange = mkColor "#ffa066";
    katanaGray = mkColor "#717c7c";

    # ─── Diff Colors ───────────────────────────────────────────────────────
    winterGreen = mkColor "#2b3328";
    winterYellow = mkColor "#49443c";
    winterRed = mkColor "#43242b";
    winterBlue = mkColor "#252535";

    # ─── Autumn Colors ─────────────────────────────────────────────────────
    autumnGreen = mkColor "#76946a";
    autumnRed = mkColor "#c34043";
    autumnYellow = mkColor "#dca561";

    # ─── Special Colors ────────────────────────────────────────────────────
    samuraiRed = mkColor "#e82424";
    roninYellow = mkColor "#ff9e3b";
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # DRAGON - Darker, More Muted Variant
  # ═══════════════════════════════════════════════════════════════════════════
  dragon = {
    # ─── Black (Background shades) ─────────────────────────────────────────
    dragonBlack0 = mkColor "#0d0c0c";
    dragonBlack1 = mkColor "#12120f";
    dragonBlack2 = mkColor "#1d1c19";
    dragonBlack3 = mkColor "#181616";
    dragonBlack4 = mkColor "#282727";
    dragonBlack5 = mkColor "#393836";
    dragonBlack6 = mkColor "#625e5a";

    # ─── Foreground Colors ─────────────────────────────────────────────────
    dragonWhite = mkColor "#c5c9c5";
    dragonGreen = mkColor "#87a987";
    dragonGreen2 = mkColor "#8a9a7b";
    dragonPink = mkColor "#a292a3";
    dragonOrange = mkColor "#b6927b";
    dragonOrange2 = mkColor "#b98d7b";
    dragonGray = mkColor "#a6a69c";
    dragonGray2 = mkColor "#9e9b93";
    dragonGray3 = mkColor "#7a8382";
    dragonBlue = mkColor "#658594";
    dragonBlue2 = mkColor "#8ba4b0";
    dragonViolet = mkColor "#8992a7";
    dragonRed = mkColor "#c4746e";
    dragonAqua = mkColor "#8ea4a2";
    dragonAsh = mkColor "#737c73";
    dragonTeal = mkColor "#949fb5";
    dragonYellow = mkColor "#c4b28a";

    # ─── Shared with Wave ──────────────────────────────────────────────────
    waveRed = mkColor "#e46876";
    springBlue = mkColor "#7fb4ca";
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # LOTUS - Light Theme Variant
  # ═══════════════════════════════════════════════════════════════════════════
  lotus = {
    # ─── White (Background shades) ─────────────────────────────────────────
    lotusWhite0 = mkColor "#d5cea3";
    lotusWhite1 = mkColor "#dcd5ac";
    lotusWhite2 = mkColor "#e5ddb0";
    lotusWhite3 = mkColor "#f2ecbc";
    lotusWhite4 = mkColor "#e7dba0";
    lotusWhite5 = mkColor "#e4d794";

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
    lotusCyan = mkColor "#6693bf";
    lotusGreen = mkColor "#6f894e";
    lotusGreen2 = mkColor "#5e857a";
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
}
