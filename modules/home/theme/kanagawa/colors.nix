# Kanagawa Color Palette
# Based on rebelot/kanagawa.nvim
# https://github.com/rebelot/kanagawa.nvim
#
# This file provides the complete Kanagawa color palette in multiple formats:
# - hex: Standard #RRGGBB format
# - rgb: CSS rgb(r, g, b) format
# - sketchybar: 0xffRRGGBB format (for sketchybar/macOS)
# - raw: RRGGBB without prefix (for some tools)
#
# Three variants are provided:
# - wave: Default dark theme (ink/ocean inspired)
# - dragon: Darker, more muted variant
# - lotus: Light theme variant
{
  # ═══════════════════════════════════════════════════════════════════════════
  # WAVE - Default Dark Theme
  # ═══════════════════════════════════════════════════════════════════════════
  wave = {
    # ─── Ink Colors (Background shades) ───────────────────────────────────────
    sumiInk0 = {
      hex = "#16161d";
      rgb = "rgb(22, 22, 29)";
      sketchybar = "0xff16161d";
      raw = "16161d";
    };
    sumiInk1 = {
      hex = "#181820";
      rgb = "rgb(24, 24, 32)";
      sketchybar = "0xff181820";
      raw = "181820";
    };
    sumiInk2 = {
      hex = "#1a1a22";
      rgb = "rgb(26, 26, 34)";
      sketchybar = "0xff1a1a22";
      raw = "1a1a22";
    };
    sumiInk3 = {
      hex = "#1f1f28";
      rgb = "rgb(31, 31, 40)";
      sketchybar = "0xff1f1f28";
      raw = "1f1f28";
    };
    sumiInk4 = {
      hex = "#2a2a37";
      rgb = "rgb(42, 42, 55)";
      sketchybar = "0xff2a2a37";
      raw = "2a2a37";
    };
    sumiInk5 = {
      hex = "#363646";
      rgb = "rgb(54, 54, 70)";
      sketchybar = "0xff363646";
      raw = "363646";
    };
    sumiInk6 = {
      hex = "#54546d";
      rgb = "rgb(84, 84, 109)";
      sketchybar = "0xff54546d";
      raw = "54546d";
    };

    # ─── Foreground Colors ────────────────────────────────────────────────────
    fujiWhite = {
      hex = "#dcd7ba";
      rgb = "rgb(220, 215, 186)";
      sketchybar = "0xffdcd7ba";
      raw = "dcd7ba";
    };
    oldWhite = {
      hex = "#c8c093";
      rgb = "rgb(200, 192, 147)";
      sketchybar = "0xffc8c093";
      raw = "c8c093";
    };
    fujiGray = {
      hex = "#727169";
      rgb = "rgb(114, 113, 105)";
      sketchybar = "0xff727169";
      raw = "727169";
    };

    # ─── Syntax Colors ────────────────────────────────────────────────────────
    oniViolet = {
      hex = "#957fb8";
      rgb = "rgb(149, 127, 184)";
      sketchybar = "0xff957fb8";
      raw = "957fb8";
    };
    oniViolet2 = {
      hex = "#b8b4d0";
      rgb = "rgb(184, 180, 208)";
      sketchybar = "0xffb8b4d0";
      raw = "b8b4d0";
    };
    crystalBlue = {
      hex = "#7e9cd8";
      rgb = "rgb(126, 156, 216)";
      sketchybar = "0xff7e9cd8";
      raw = "7e9cd8";
    };
    springViolet1 = {
      hex = "#938aa9";
      rgb = "rgb(147, 138, 169)";
      sketchybar = "0xff938aa9";
      raw = "938aa9";
    };
    springViolet2 = {
      hex = "#9cabca";
      rgb = "rgb(156, 171, 202)";
      sketchybar = "0xff9cabca";
      raw = "9cabca";
    };
    springBlue = {
      hex = "#7fb4ca";
      rgb = "rgb(127, 180, 202)";
      sketchybar = "0xff7fb4ca";
      raw = "7fb4ca";
    };
    lightBlue = {
      hex = "#a3d4d5";
      rgb = "rgb(163, 212, 213)";
      sketchybar = "0xffa3d4d5";
      raw = "a3d4d5";
    };
    waveAqua1 = {
      hex = "#6a9589";
      rgb = "rgb(106, 149, 137)";
      sketchybar = "0xff6a9589";
      raw = "6a9589";
    };
    waveAqua2 = {
      hex = "#7aa89f";
      rgb = "rgb(122, 168, 159)";
      sketchybar = "0xff7aa89f";
      raw = "7aa89f";
    };
    springGreen = {
      hex = "#98bb6c";
      rgb = "rgb(152, 187, 108)";
      sketchybar = "0xff98bb6c";
      raw = "98bb6c";
    };
    boatYellow1 = {
      hex = "#938056";
      rgb = "rgb(147, 128, 86)";
      sketchybar = "0xff938056";
      raw = "938056";
    };
    boatYellow2 = {
      hex = "#c0a36e";
      rgb = "rgb(192, 163, 110)";
      sketchybar = "0xffc0a36e";
      raw = "c0a36e";
    };
    carpYellow = {
      hex = "#e6c384";
      rgb = "rgb(230, 195, 132)";
      sketchybar = "0xffe6c384";
      raw = "e6c384";
    };
    sakuraPink = {
      hex = "#d27e99";
      rgb = "rgb(210, 126, 153)";
      sketchybar = "0xffd27e99";
      raw = "d27e99";
    };
    waveRed = {
      hex = "#e46876";
      rgb = "rgb(228, 104, 118)";
      sketchybar = "0xffe46876";
      raw = "e46876";
    };
    peachRed = {
      hex = "#ff5d62";
      rgb = "rgb(255, 93, 98)";
      sketchybar = "0xffff5d62";
      raw = "ff5d62";
    };
    surimiOrange = {
      hex = "#ffa066";
      rgb = "rgb(255, 160, 102)";
      sketchybar = "0xffffa066";
      raw = "ffa066";
    };
    katanaGray = {
      hex = "#717c7c";
      rgb = "rgb(113, 124, 124)";
      sketchybar = "0xff717c7c";
      raw = "717c7c";
    };

    # ─── Diff Colors ──────────────────────────────────────────────────────────
    winterGreen = {
      hex = "#2b3328";
      rgb = "rgb(43, 51, 40)";
      sketchybar = "0xff2b3328";
      raw = "2b3328";
    };
    winterYellow = {
      hex = "#49443c";
      rgb = "rgb(73, 68, 60)";
      sketchybar = "0xff49443c";
      raw = "49443c";
    };
    winterRed = {
      hex = "#43242b";
      rgb = "rgb(67, 36, 43)";
      sketchybar = "0xff43242b";
      raw = "43242b";
    };
    winterBlue = {
      hex = "#252535";
      rgb = "rgb(37, 37, 53)";
      sketchybar = "0xff252535";
      raw = "252535";
    };

    # ─── Autumn Colors (for git diff, etc) ────────────────────────────────────
    autumnGreen = {
      hex = "#76946a";
      rgb = "rgb(118, 148, 106)";
      sketchybar = "0xff76946a";
      raw = "76946a";
    };
    autumnRed = {
      hex = "#c34043";
      rgb = "rgb(195, 64, 67)";
      sketchybar = "0xffc34043";
      raw = "c34043";
    };
    autumnYellow = {
      hex = "#dca561";
      rgb = "rgb(220, 165, 97)";
      sketchybar = "0xffdca561";
      raw = "dca561";
    };

    # ─── Special Colors ───────────────────────────────────────────────────────
    samuraiRed = {
      hex = "#e82424";
      rgb = "rgb(232, 36, 36)";
      sketchybar = "0xffe82424";
      raw = "e82424";
    };
    roninYellow = {
      hex = "#ff9e3b";
      rgb = "rgb(255, 158, 59)";
      sketchybar = "0xffff9e3b";
      raw = "ff9e3b";
    };

    # ─── Semantic Mappings ────────────────────────────────────────────────────
    bg = {
      hex = "#1f1f28";
      rgb = "rgb(31, 31, 40)";
      sketchybar = "0xff1f1f28";
      raw = "1f1f28";
    }; # sumiInk3
    bg_dim = {
      hex = "#16161d";
      rgb = "rgb(22, 22, 29)";
      sketchybar = "0xff16161d";
      raw = "16161d";
    }; # sumiInk0
    bg_gutter = {
      hex = "#2a2a37";
      rgb = "rgb(42, 42, 55)";
      sketchybar = "0xff2a2a37";
      raw = "2a2a37";
    }; # sumiInk4
    fg = {
      hex = "#dcd7ba";
      rgb = "rgb(220, 215, 186)";
      sketchybar = "0xffdcd7ba";
      raw = "dcd7ba";
    }; # fujiWhite
    fg_dim = {
      hex = "#727169";
      rgb = "rgb(114, 113, 105)";
      sketchybar = "0xff727169";
      raw = "727169";
    }; # fujiGray
    accent = {
      hex = "#7e9cd8";
      rgb = "rgb(126, 156, 216)";
      sketchybar = "0xff7e9cd8";
      raw = "7e9cd8";
    }; # crystalBlue

    # ─── UI Element Colors ────────────────────────────────────────────────────
    border = {
      hex = "#2a2a37";
      rgb = "rgb(42, 42, 55)";
      sketchybar = "0xff2a2a37";
      raw = "2a2a37";
    }; # sumiInk4
    selection = {
      hex = "#363646";
      rgb = "rgb(54, 54, 70)";
      sketchybar = "0xff363646";
      raw = "363646";
    }; # sumiInk5

    # ─── Transparent ──────────────────────────────────────────────────────────
    transparent = {
      hex = "#00000000";
      rgb = "rgba(0, 0, 0, 0)";
      sketchybar = "0x00000000";
      raw = "00000000";
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # DRAGON - Darker, More Muted Variant
  # ═══════════════════════════════════════════════════════════════════════════
  dragon = {
    # ─── Black (Background shades) ────────────────────────────────────────────
    dragonBlack0 = {
      hex = "#0d0c0c";
      rgb = "rgb(13, 12, 12)";
      sketchybar = "0xff0d0c0c";
      raw = "0d0c0c";
    };
    dragonBlack1 = {
      hex = "#12120f";
      rgb = "rgb(18, 18, 15)";
      sketchybar = "0xff12120f";
      raw = "12120f";
    };
    dragonBlack2 = {
      hex = "#1d1c19";
      rgb = "rgb(29, 28, 25)";
      sketchybar = "0xff1d1c19";
      raw = "1d1c19";
    };
    dragonBlack3 = {
      hex = "#181616";
      rgb = "rgb(24, 22, 22)";
      sketchybar = "0xff181616";
      raw = "181616";
    };
    dragonBlack4 = {
      hex = "#282727";
      rgb = "rgb(40, 39, 39)";
      sketchybar = "0xff282727";
      raw = "282727";
    };
    dragonBlack5 = {
      hex = "#393836";
      rgb = "rgb(57, 56, 54)";
      sketchybar = "0xff393836";
      raw = "393836";
    };
    dragonBlack6 = {
      hex = "#625e5a";
      rgb = "rgb(98, 94, 90)";
      sketchybar = "0xff625e5a";
      raw = "625e5a";
    };

    # ─── Foreground Colors ────────────────────────────────────────────────────
    dragonWhite = {
      hex = "#c5c9c5";
      rgb = "rgb(197, 201, 197)";
      sketchybar = "0xffc5c9c5";
      raw = "c5c9c5";
    };
    dragonGreen = {
      hex = "#87a987";
      rgb = "rgb(135, 169, 135)";
      sketchybar = "0xff87a987";
      raw = "87a987";
    };
    dragonGreen2 = {
      hex = "#8a9a7b";
      rgb = "rgb(138, 154, 123)";
      sketchybar = "0xff8a9a7b";
      raw = "8a9a7b";
    };
    dragonPink = {
      hex = "#a292a3";
      rgb = "rgb(162, 146, 163)";
      sketchybar = "0xffa292a3";
      raw = "a292a3";
    };
    dragonOrange = {
      hex = "#b6927b";
      rgb = "rgb(182, 146, 123)";
      sketchybar = "0xffb6927b";
      raw = "b6927b";
    };
    dragonOrange2 = {
      hex = "#b98d7b";
      rgb = "rgb(185, 141, 123)";
      sketchybar = "0xffb98d7b";
      raw = "b98d7b";
    };
    dragonGray = {
      hex = "#a6a69c";
      rgb = "rgb(166, 166, 156)";
      sketchybar = "0xffa6a69c";
      raw = "a6a69c";
    };
    dragonGray2 = {
      hex = "#9e9b93";
      rgb = "rgb(158, 155, 147)";
      sketchybar = "0xff9e9b93";
      raw = "9e9b93";
    };
    dragonGray3 = {
      hex = "#7a8382";
      rgb = "rgb(122, 131, 130)";
      sketchybar = "0xff7a8382";
      raw = "7a8382";
    };
    dragonBlue = {
      hex = "#658594";
      rgb = "rgb(101, 133, 148)";
      sketchybar = "0xff658594";
      raw = "658594";
    };
    dragonBlue2 = {
      hex = "#8ba4b0";
      rgb = "rgb(139, 164, 176)";
      sketchybar = "0xff8ba4b0";
      raw = "8ba4b0";
    };
    dragonViolet = {
      hex = "#8992a7";
      rgb = "rgb(137, 146, 167)";
      sketchybar = "0xff8992a7";
      raw = "8992a7";
    };
    dragonRed = {
      hex = "#c4746e";
      rgb = "rgb(196, 116, 110)";
      sketchybar = "0xffc4746e";
      raw = "c4746e";
    };
    dragonAqua = {
      hex = "#8ea4a2";
      rgb = "rgb(142, 164, 162)";
      sketchybar = "0xff8ea4a2";
      raw = "8ea4a2";
    };
    dragonAsh = {
      hex = "#737c73";
      rgb = "rgb(115, 124, 115)";
      sketchybar = "0xff737c73";
      raw = "737c73";
    };
    dragonTeal = {
      hex = "#949fb5";
      rgb = "rgb(148, 159, 181)";
      sketchybar = "0xff949fb5";
      raw = "949fb5";
    };
    dragonYellow = {
      hex = "#c4b28a";
      rgb = "rgb(196, 178, 138)";
      sketchybar = "0xffc4b28a";
      raw = "c4b28a";
    };

    # ─── Shared with Wave ─────────────────────────────────────────────────────
    waveRed = {
      hex = "#e46876";
      rgb = "rgb(228, 104, 118)";
      sketchybar = "0xffe46876";
      raw = "e46876";
    };
    springBlue = {
      hex = "#7fb4ca";
      rgb = "rgb(127, 180, 202)";
      sketchybar = "0xff7fb4ca";
      raw = "7fb4ca";
    };

    # ─── Semantic Mappings ────────────────────────────────────────────────────
    bg = {
      hex = "#181616";
      rgb = "rgb(24, 22, 22)";
      sketchybar = "0xff181616";
      raw = "181616";
    }; # dragonBlack3
    bg_dim = {
      hex = "#0d0c0c";
      rgb = "rgb(13, 12, 12)";
      sketchybar = "0xff0d0c0c";
      raw = "0d0c0c";
    }; # dragonBlack0
    bg_gutter = {
      hex = "#282727";
      rgb = "rgb(40, 39, 39)";
      sketchybar = "0xff282727";
      raw = "282727";
    }; # dragonBlack4
    fg = {
      hex = "#c5c9c5";
      rgb = "rgb(197, 201, 197)";
      sketchybar = "0xffc5c9c5";
      raw = "c5c9c5";
    }; # dragonWhite
    fg_dim = {
      hex = "#a6a69c";
      rgb = "rgb(166, 166, 156)";
      sketchybar = "0xffa6a69c";
      raw = "a6a69c";
    }; # dragonGray
    accent = {
      hex = "#8ba4b0";
      rgb = "rgb(139, 164, 176)";
      sketchybar = "0xff8ba4b0";
      raw = "8ba4b0";
    }; # dragonBlue2

    # ─── UI Element Colors ────────────────────────────────────────────────────
    border = {
      hex = "#282727";
      rgb = "rgb(40, 39, 39)";
      sketchybar = "0xff282727";
      raw = "282727";
    }; # dragonBlack4
    selection = {
      hex = "#393836";
      rgb = "rgb(57, 56, 54)";
      sketchybar = "0xff393836";
      raw = "393836";
    }; # dragonBlack5

    # ─── Transparent ──────────────────────────────────────────────────────────
    transparent = {
      hex = "#00000000";
      rgb = "rgba(0, 0, 0, 0)";
      sketchybar = "0x00000000";
      raw = "00000000";
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # LOTUS - Light Theme Variant
  # ═══════════════════════════════════════════════════════════════════════════
  lotus = {
    # ─── White (Background shades) ────────────────────────────────────────────
    lotusWhite0 = {
      hex = "#d5cea3";
      rgb = "rgb(213, 206, 163)";
      sketchybar = "0xffd5cea3";
      raw = "d5cea3";
    };
    lotusWhite1 = {
      hex = "#dcd5ac";
      rgb = "rgb(220, 213, 172)";
      sketchybar = "0xffdcd5ac";
      raw = "dcd5ac";
    };
    lotusWhite2 = {
      hex = "#e5ddb0";
      rgb = "rgb(229, 221, 176)";
      sketchybar = "0xffe5ddb0";
      raw = "e5ddb0";
    };
    lotusWhite3 = {
      hex = "#f2ecbc";
      rgb = "rgb(242, 236, 188)";
      sketchybar = "0xfff2ecbc";
      raw = "f2ecbc";
    };
    lotusWhite4 = {
      hex = "#e7dba0";
      rgb = "rgb(231, 219, 160)";
      sketchybar = "0xffe7dba0";
      raw = "e7dba0";
    };
    lotusWhite5 = {
      hex = "#e4d794";
      rgb = "rgb(228, 215, 148)";
      sketchybar = "0xffe4d794";
      raw = "e4d794";
    };

    # ─── Ink (Foreground shades) ──────────────────────────────────────────────
    lotusInk1 = {
      hex = "#545464";
      rgb = "rgb(84, 84, 100)";
      sketchybar = "0xff545464";
      raw = "545464";
    };
    lotusInk2 = {
      hex = "#43436c";
      rgb = "rgb(67, 67, 108)";
      sketchybar = "0xff43436c";
      raw = "43436c";
    };
    lotusGray = {
      hex = "#dcd7ba";
      rgb = "rgb(220, 215, 186)";
      sketchybar = "0xffdcd7ba";
      raw = "dcd7ba";
    };
    lotusGray2 = {
      hex = "#716e61";
      rgb = "rgb(113, 110, 97)";
      sketchybar = "0xff716e61";
      raw = "716e61";
    };
    lotusGray3 = {
      hex = "#8a8980";
      rgb = "rgb(138, 137, 128)";
      sketchybar = "0xff8a8980";
      raw = "8a8980";
    };

    # ─── Syntax Colors ────────────────────────────────────────────────────────
    lotusViolet1 = {
      hex = "#a09cac";
      rgb = "rgb(160, 156, 172)";
      sketchybar = "0xffa09cac";
      raw = "a09cac";
    };
    lotusViolet2 = {
      hex = "#766b90";
      rgb = "rgb(118, 107, 144)";
      sketchybar = "0xff766b90";
      raw = "766b90";
    };
    lotusViolet3 = {
      hex = "#c9cbd1";
      rgb = "rgb(201, 203, 209)";
      sketchybar = "0xffc9cbd1";
      raw = "c9cbd1";
    };
    lotusViolet4 = {
      hex = "#624c83";
      rgb = "rgb(98, 76, 131)";
      sketchybar = "0xff624c83";
      raw = "624c83";
    };
    lotusBlue1 = {
      hex = "#c7d7e0";
      rgb = "rgb(199, 215, 224)";
      sketchybar = "0xffc7d7e0";
      raw = "c7d7e0";
    };
    lotusBlue2 = {
      hex = "#b5cbd2";
      rgb = "rgb(181, 203, 210)";
      sketchybar = "0xffb5cbd2";
      raw = "b5cbd2";
    };
    lotusBlue3 = {
      hex = "#9fb5c9";
      rgb = "rgb(159, 181, 201)";
      sketchybar = "0xff9fb5c9";
      raw = "9fb5c9";
    };
    lotusBlue4 = {
      hex = "#4d699b";
      rgb = "rgb(77, 105, 155)";
      sketchybar = "0xff4d699b";
      raw = "4d699b";
    };
    lotusBlue5 = {
      hex = "#5d57a3";
      rgb = "rgb(93, 87, 163)";
      sketchybar = "0xff5d57a3";
      raw = "5d57a3";
    };
    lotusCyan = {
      hex = "#6693bf";
      rgb = "rgb(102, 147, 191)";
      sketchybar = "0xff6693bf";
      raw = "6693bf";
    };
    lotusGreen = {
      hex = "#6f894e";
      rgb = "rgb(111, 137, 78)";
      sketchybar = "0xff6f894e";
      raw = "6f894e";
    };
    lotusGreen2 = {
      hex = "#5e857a";
      rgb = "rgb(94, 133, 122)";
      sketchybar = "0xff5e857a";
      raw = "5e857a";
    };
    lotusGreen3 = {
      hex = "#b7d0ae";
      rgb = "rgb(183, 208, 174)";
      sketchybar = "0xffb7d0ae";
      raw = "b7d0ae";
    };
    lotusPink = {
      hex = "#b35b79";
      rgb = "rgb(179, 91, 121)";
      sketchybar = "0xffb35b79";
      raw = "b35b79";
    };
    lotusOrange = {
      hex = "#cc6d00";
      rgb = "rgb(204, 109, 0)";
      sketchybar = "0xffcc6d00";
      raw = "cc6d00";
    };
    lotusOrange2 = {
      hex = "#e98a00";
      rgb = "rgb(233, 138, 0)";
      sketchybar = "0xffe98a00";
      raw = "e98a00";
    };
    lotusYellow = {
      hex = "#77713f";
      rgb = "rgb(119, 113, 63)";
      sketchybar = "0xff77713f";
      raw = "77713f";
    };
    lotusYellow2 = {
      hex = "#836f4a";
      rgb = "rgb(131, 111, 74)";
      sketchybar = "0xff836f4a";
      raw = "836f4a";
    };
    lotusYellow3 = {
      hex = "#de9800";
      rgb = "rgb(222, 152, 0)";
      sketchybar = "0xffde9800";
      raw = "de9800";
    };
    lotusYellow4 = {
      hex = "#f9d791";
      rgb = "rgb(249, 215, 145)";
      sketchybar = "0xfff9d791";
      raw = "f9d791";
    };
    lotusRed = {
      hex = "#c84053";
      rgb = "rgb(200, 64, 83)";
      sketchybar = "0xffc84053";
      raw = "c84053";
    };
    lotusRed2 = {
      hex = "#d7474b";
      rgb = "rgb(215, 71, 75)";
      sketchybar = "0xffd7474b";
      raw = "d7474b";
    };
    lotusRed3 = {
      hex = "#e82424";
      rgb = "rgb(232, 36, 36)";
      sketchybar = "0xffe82424";
      raw = "e82424";
    };
    lotusRed4 = {
      hex = "#d9a594";
      rgb = "rgb(217, 165, 148)";
      sketchybar = "0xffd9a594";
      raw = "d9a594";
    };
    lotusAqua = {
      hex = "#597b75";
      rgb = "rgb(89, 123, 117)";
      sketchybar = "0xff597b75";
      raw = "597b75";
    };
    lotusAqua2 = {
      hex = "#5e857a";
      rgb = "rgb(94, 133, 122)";
      sketchybar = "0xff5e857a";
      raw = "5e857a";
    };
    lotusTeal1 = {
      hex = "#4e8ca2";
      rgb = "rgb(78, 140, 162)";
      sketchybar = "0xff4e8ca2";
      raw = "4e8ca2";
    };
    lotusTeal2 = {
      hex = "#6693bf";
      rgb = "rgb(102, 147, 191)";
      sketchybar = "0xff6693bf";
      raw = "6693bf";
    };
    lotusTeal3 = {
      hex = "#5a7785";
      rgb = "rgb(90, 119, 133)";
      sketchybar = "0xff5a7785";
      raw = "5a7785";
    };

    # ─── Semantic Mappings ────────────────────────────────────────────────────
    bg = {
      hex = "#f2ecbc";
      rgb = "rgb(242, 236, 188)";
      sketchybar = "0xfff2ecbc";
      raw = "f2ecbc";
    }; # lotusWhite3
    bg_dim = {
      hex = "#e5ddb0";
      rgb = "rgb(229, 221, 176)";
      sketchybar = "0xffe5ddb0";
      raw = "e5ddb0";
    }; # lotusWhite2
    bg_gutter = {
      hex = "#e7dba0";
      rgb = "rgb(231, 219, 160)";
      sketchybar = "0xffe7dba0";
      raw = "e7dba0";
    }; # lotusWhite4
    fg = {
      hex = "#545464";
      rgb = "rgb(84, 84, 100)";
      sketchybar = "0xff545464";
      raw = "545464";
    }; # lotusInk1
    fg_dim = {
      hex = "#8a8980";
      rgb = "rgb(138, 137, 128)";
      sketchybar = "0xff8a8980";
      raw = "8a8980";
    }; # lotusGray3
    accent = {
      hex = "#4d699b";
      rgb = "rgb(77, 105, 155)";
      sketchybar = "0xff4d699b";
      raw = "4d699b";
    }; # lotusBlue4

    # ─── UI Element Colors ────────────────────────────────────────────────────
    border = {
      hex = "#e7dba0";
      rgb = "rgb(231, 219, 160)";
      sketchybar = "0xffe7dba0";
      raw = "e7dba0";
    }; # lotusWhite4
    selection = {
      hex = "#e4d794";
      rgb = "rgb(228, 215, 148)";
      sketchybar = "0xffe4d794";
      raw = "e4d794";
    }; # lotusWhite5

    # ─── Transparent ──────────────────────────────────────────────────────────
    transparent = {
      hex = "#00000000";
      rgb = "rgba(0, 0, 0, 0)";
      sketchybar = "0x00000000";
      raw = "00000000";
    };
  };
}
