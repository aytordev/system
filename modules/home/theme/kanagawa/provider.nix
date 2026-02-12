# Kanagawa Theme Provider
# Returns theme data conforming to the provider contract.
# This is NOT a NixOS module — it's a plain function returning an attrset.
{
  mkColor,
  transparent,
  capitalize,
}: let
  colors = import ./colors.nix {inherit mkColor;};
  inherit (colors) wave;
  inherit (colors) dragon;
  inherit (colors) lotus;
in {
  name = "kanagawa";
  displayName = "Kanagawa";

  defaultVariant = "wave";
  lightVariant = "lotus";

  variants = {
    wave = {
      isLight = false;
      rawColors = wave;
      palette = {
        # ─── Backgrounds ──────────────────────────────────────────────────
        bg = wave.sumiInk3;
        bg_dim = wave.sumiInk0;
        bg_gutter = wave.sumiInk4;
        bg_float = wave.sumiInk1;
        bg_visual = wave.sumiInk5;

        # ─── Foregrounds ──────────────────────────────────────────────────
        fg = wave.fujiWhite;
        fg_dim = wave.fujiGray;
        fg_reverse = wave.oldWhite;

        # ─── UI Elements ──────────────────────────────────────────────────
        accent = wave.crystalBlue;
        accent_dim = wave.springViolet2;
        border = wave.sumiInk4;
        selection = wave.sumiInk5;
        overlay = wave.sumiInk6;

        # ─── Semantic Colors ──────────────────────────────────────────────
        red = wave.autumnRed;
        red_bright = wave.samuraiRed;
        red_dim = wave.waveRed;
        green = wave.autumnGreen;
        yellow = wave.boatYellow2;
        yellow_bright = wave.carpYellow;
        blue = wave.crystalBlue;
        blue_bright = wave.springBlue;
        orange = wave.surimiOrange;
        violet = wave.oniViolet;
        pink = wave.sakuraPink;
        cyan = wave.waveAqua1;

        # ─── Special ──────────────────────────────────────────────────────
        inherit transparent;
      };
    };

    dragon = {
      isLight = false;
      rawColors = dragon;
      palette = {
        # ─── Backgrounds ──────────────────────────────────────────────────
        bg = dragon.dragonBlack3;
        bg_dim = dragon.dragonBlack0;
        bg_gutter = dragon.dragonBlack4;
        bg_float = dragon.dragonBlack1;
        bg_visual = dragon.dragonBlack5;

        # ─── Foregrounds ──────────────────────────────────────────────────
        fg = dragon.dragonWhite;
        fg_dim = dragon.dragonGray;
        fg_reverse = dragon.dragonGray;

        # ─── UI Elements ──────────────────────────────────────────────────
        accent = dragon.dragonBlue2;
        accent_dim = dragon.dragonViolet;
        border = dragon.dragonBlack4;
        selection = dragon.dragonBlack5;
        overlay = dragon.dragonBlack6;

        # ─── Semantic Colors ──────────────────────────────────────────────
        red = dragon.dragonRed;
        red_bright = dragon.dragonRed;
        red_dim = dragon.waveRed;
        green = dragon.dragonGreen;
        yellow = dragon.dragonYellow;
        yellow_bright = dragon.dragonYellow;
        blue = dragon.dragonBlue2;
        blue_bright = dragon.springBlue;
        orange = dragon.dragonOrange;
        violet = dragon.dragonPink;
        pink = dragon.dragonPink;
        cyan = dragon.dragonAqua;

        # ─── Special ──────────────────────────────────────────────────────
        inherit transparent;
      };
    };

    lotus = {
      isLight = true;
      rawColors = lotus;
      palette = {
        # ─── Backgrounds ──────────────────────────────────────────────────
        bg = lotus.lotusWhite3;
        bg_dim = lotus.lotusWhite2;
        bg_gutter = lotus.lotusWhite4;
        bg_float = lotus.lotusWhite1;
        bg_visual = lotus.lotusWhite5;

        # ─── Foregrounds ──────────────────────────────────────────────────
        fg = lotus.lotusInk1;
        fg_dim = lotus.lotusGray3;
        fg_reverse = lotus.lotusGray2;

        # ─── UI Elements ──────────────────────────────────────────────────
        accent = lotus.lotusBlue4;
        accent_dim = lotus.lotusBlue5;
        border = lotus.lotusWhite4;
        selection = lotus.lotusWhite5;
        overlay = lotus.lotusBlue3;

        # ─── Semantic Colors ──────────────────────────────────────────────
        red = lotus.lotusRed;
        red_bright = lotus.lotusRed3;
        red_dim = lotus.lotusRed2;
        green = lotus.lotusGreen;
        yellow = lotus.lotusYellow;
        yellow_bright = lotus.lotusYellow4;
        blue = lotus.lotusBlue4;
        blue_bright = lotus.lotusBlue2;
        orange = lotus.lotusOrange;
        violet = lotus.lotusViolet1;
        pink = lotus.lotusPink;
        cyan = lotus.lotusTeal1;

        # ─── Special ──────────────────────────────────────────────────────
        inherit transparent;
      };
    };
  };

  # App theme name formatting per variant
  appTheme = variant: {
    capitalized = "Kanagawa ${capitalize variant}";
    kebab = "kanagawa-${variant}";
    underscore = "kanagawa_${variant}";
    raw = "kanagawa/${variant}";
  };
}
