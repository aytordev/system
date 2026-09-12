{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeLib themeConfig;

  mkProvider = path: import path {inherit (themeLib) mkColor transparent capitalize;};

  providers = {
    kanagawa = mkProvider ../../modules/home/theme/kanagawa/provider.nix;
    catppuccin = mkProvider ../../modules/home/theme/catppuccin/provider.nix;
    sora = mkProvider ../../modules/home/theme/sora/provider.nix;
  };

  # The 26 semantic roles every palette must publish.
  paletteRoles = [
    "bg"
    "bg_dim"
    "bg_gutter"
    "bg_float"
    "bg_visual"
    "fg"
    "fg_dim"
    "fg_reverse"
    "accent"
    "accent_dim"
    "border"
    "selection"
    "overlay"
    "red"
    "red_bright"
    "red_dim"
    "green"
    "yellow"
    "yellow_bright"
    "blue"
    "blue_bright"
    "orange"
    "violet"
    "pink"
    "cyan"
    "transparent"
  ];

  ansiSlots = [
    "black"
    "red"
    "green"
    "yellow"
    "blue"
    "magenta"
    "cyan"
    "white"
  ];
  ansiGroups = [
    "normal"
    "bright"
  ];
  colorFields = [
    "hex"
    "rgb"
    "sketchybar"
    "raw"
  ];

  allVariants = lib.concatLists (
    lib.mapAttrsToList (_: provider: builtins.attrValues provider.variants) providers
  );

  wellFormedColor = color:
    builtins.isAttrs color
    && builtins.all (field: color ? ${field} && builtins.isString color.${field}) colorFields;

  variantHasAllRoles = variant:
    builtins.length (builtins.attrNames variant.palette)
    == 26
    && builtins.all (role: wellFormedColor variant.palette.${role}) paletteRoles;

  variantAnsiHas16Slots = variant:
    builtins.all (
      group:
        builtins.length (builtins.attrNames variant.ansi.${group})
        == 8
        && builtins.all (slot: builtins.elem slot ansiSlots) (builtins.attrNames variant.ansi.${group})
        && builtins.all (slot: wellFormedColor variant.ansi.${group}.${slot}) ansiSlots
    )
    ansiGroups;

  # Full ANSI hex view of a variant, for exact-value assertions.
  ansiHex = variant: {
    normal = lib.genAttrs ansiSlots (slot: variant.ansi.normal.${slot}.hex);
    bright = lib.genAttrs ansiSlots (slot: variant.ansi.bright.${slot}.hex);
  };

  dimHex = variant: lib.mapAttrs (_: color: color.hex) (variant.ansi.dim or {});

  dimNames = variant: builtins.attrNames (variant.ansi.dim or {});
in {
  # ─── Palette completeness ─────────────────────────────────────────────────

  testEveryVariantPaletteHasAll26Roles = {
    expr = builtins.all variantHasAllRoles allVariants;
    expected = true;
  };

  # ─── ANSI shape: 16 normal+bright slots for every variant ─────────────────

  testEveryVariantAnsiHas16Slots = {
    expr = builtins.all variantAnsiHas16Slots allVariants;
    expected = true;
  };

  testOnlySoraAnsiHasDimSlots = {
    expr = {
      soraDark = dimNames providers.sora.variants.dark;
      soraLight = dimNames providers.sora.variants.light;
      kanagawaHasDim = providers.kanagawa.variants.wave.ansi ? dim;
      catppuccinHasDim = providers.catppuccin.variants.mocha.ansi ? dim;
    };
    expected = {
      soraDark = [
        "blue"
        "cyan"
        "green"
        "magenta"
        "red"
        "yellow"
      ];
      soraLight = [
        "blue"
        "cyan"
        "green"
        "magenta"
        "red"
        "yellow"
      ];
      kanagawaHasDim = false;
      catppuccinHasDim = false;
    };
  };

  # ─── Kanagawa raw regression + corrected semantic roles ───────────────────

  testLotusRawGreen2AndCyanAreCorrected = {
    expr = let
      raw = providers.kanagawa.variants.lotus.rawColors;
    in {
      lotusGreen2 = raw.lotusGreen2.hex;
      lotusCyan = raw.lotusCyan.hex;
      # Regression: the old bug had green2 equal to aqua2 and cyan equal to
      # teal2. Both must now be distinct upstream values.
      green2EqualsAqua2 = raw.lotusGreen2.hex == raw.lotusAqua2.hex;
      cyanEqualsTeal2 = raw.lotusCyan.hex == raw.lotusTeal2.hex;
    };
    expected = {
      lotusGreen2 = "#6e915f";
      lotusCyan = "#d7e3d8";
      green2EqualsAqua2 = false;
      cyanEqualsTeal2 = false;
    };
  };

  testKanagawaCorrectedRoles = {
    expr = let
      pick = variant: roles:
        lib.genAttrs roles (role: providers.kanagawa.variants.${variant}.palette.${role}.hex);
    in {
      wave = pick "wave" [
        "bg_dim"
        "bg_float"
        "bg_visual"
        "selection"
        "fg_dim"
        "fg_reverse"
      ];
      dragon = pick "dragon" [
        "bg_dim"
        "bg_float"
        "bg_visual"
        "selection"
        "fg_reverse"
        "red_bright"
        "green"
        "violet"
      ];
      lotus = pick "lotus" [
        "bg_dim"
        "bg_float"
        "bg_visual"
        "selection"
        "fg_dim"
        "fg_reverse"
        "overlay"
        "yellow_bright"
        "blue_bright"
        "violet"
        "cyan"
      ];
    };
    expected = {
      wave = {
        bg_dim = "#181820";
        bg_float = "#16161d";
        bg_visual = "#223249";
        selection = "#223249";
        fg_dim = "#c8c093";
        fg_reverse = "#223249";
      };
      dragon = {
        bg_dim = "#12120f";
        bg_float = "#0d0c0c";
        bg_visual = "#223249";
        selection = "#223249";
        fg_reverse = "#223249";
        red_bright = "#e46876";
        green = "#8a9a7b";
        violet = "#8992a7";
      };
      lotus = {
        bg_dim = "#dcd5ac";
        bg_float = "#d5cea3";
        bg_visual = "#c9cbd1";
        selection = "#c9cbd1";
        fg_dim = "#43436c";
        fg_reverse = "#dcd7ba";
        overlay = "#a09cac";
        yellow_bright = "#836f4a";
        blue_bright = "#6693bf";
        violet = "#624c83";
        cyan = "#597b75";
      };
    };
  };

  # ─── Exact ANSI values per family, sourced from upstream ──────────────────

  testKanagawaAnsiMatchesUpstream = {
    expr = {
      wave = ansiHex providers.kanagawa.variants.wave;
      dragon = ansiHex providers.kanagawa.variants.dragon;
      lotus = ansiHex providers.kanagawa.variants.lotus;
    };
    expected = {
      wave = {
        normal = {
          black = "#16161d";
          red = "#c34043";
          green = "#76946a";
          yellow = "#c0a36e";
          blue = "#7e9cd8";
          magenta = "#957fb8";
          cyan = "#6a9589";
          white = "#c8c093";
        };
        bright = {
          black = "#727169";
          red = "#e82424";
          green = "#98bb6c";
          yellow = "#e6c384";
          blue = "#7fb4ca";
          magenta = "#938aa9";
          cyan = "#7aa89f";
          white = "#dcd7ba";
        };
      };
      dragon = {
        normal = {
          black = "#0d0c0c";
          red = "#c4746e";
          green = "#8a9a7b";
          yellow = "#c4b28a";
          blue = "#8ba4b0";
          magenta = "#a292a3";
          cyan = "#8ea4a2";
          white = "#c8c093";
        };
        bright = {
          black = "#a6a69c";
          red = "#e46876";
          green = "#87a987";
          yellow = "#e6c384";
          blue = "#7fb4ca";
          magenta = "#938aa9";
          cyan = "#7aa89f";
          white = "#c5c9c5";
        };
      };
      lotus = {
        normal = {
          black = "#1f1f28";
          red = "#c84053";
          green = "#6f894e";
          yellow = "#77713f";
          blue = "#4d699b";
          magenta = "#b35b79";
          cyan = "#597b75";
          white = "#545464";
        };
        bright = {
          black = "#8a8980";
          red = "#d7474b";
          green = "#6e915f";
          yellow = "#836f4a";
          blue = "#6693bf";
          magenta = "#624c83";
          cyan = "#5e857a";
          white = "#43436c";
        };
      };
    };
  };

  testCatppuccinAnsiMatchesUpstream = {
    expr = {
      latte = ansiHex providers.catppuccin.variants.latte;
      frappe = ansiHex providers.catppuccin.variants.frappe;
      macchiato = ansiHex providers.catppuccin.variants.macchiato;
      mocha = ansiHex providers.catppuccin.variants.mocha;
    };
    expected = {
      latte = {
        normal = {
          black = "#5c5f77";
          red = "#d20f39";
          green = "#40a02b";
          yellow = "#df8e1d";
          blue = "#1e66f5";
          magenta = "#ea76cb";
          cyan = "#179299";
          white = "#acb0be";
        };
        bright = {
          black = "#6c6f85";
          red = "#de293e";
          green = "#49af3d";
          yellow = "#eea02d";
          blue = "#456eff";
          magenta = "#fe85d8";
          cyan = "#2d9fa8";
          white = "#bcc0cc";
        };
      };
      frappe = {
        normal = {
          black = "#51576d";
          red = "#e78284";
          green = "#a6d189";
          yellow = "#e5c890";
          blue = "#8caaee";
          magenta = "#f4b8e4";
          cyan = "#81c8be";
          white = "#a5adce";
        };
        bright = {
          black = "#626880";
          red = "#e67172";
          green = "#8ec772";
          yellow = "#d9ba73";
          blue = "#7b9ef0";
          magenta = "#f2a4db";
          cyan = "#5abfb5";
          white = "#b5bfe2";
        };
      };
      macchiato = {
        normal = {
          black = "#494d64";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#a5adcb";
        };
        bright = {
          black = "#5b6078";
          red = "#ec7486";
          green = "#8ccf7f";
          yellow = "#e1c682";
          blue = "#78a1f6";
          magenta = "#f2a9dd";
          cyan = "#63cbc0";
          white = "#b8c0e0";
        };
      };
      mocha = {
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
        bright = {
          black = "#585b70";
          red = "#f37799";
          green = "#89d88b";
          yellow = "#ebd391";
          blue = "#74a8fc";
          magenta = "#f2aede";
          cyan = "#6bd7ca";
          white = "#bac2de";
        };
      };
    };
  };

  testSoraAnsiMatchesUpstream = {
    expr = {
      dark = ansiHex providers.sora.variants.dark;
      light = ansiHex providers.sora.variants.light;
      darkDim = dimHex providers.sora.variants.dark;
      lightDim = dimHex providers.sora.variants.light;
    };
    expected = {
      dark = {
        normal = {
          black = "#0e1018";
          red = "#c46c78";
          green = "#90c8a0";
          yellow = "#d4b878";
          blue = "#80c8e0";
          magenta = "#b0a0d8";
          cyan = "#78b8b0";
          white = "#c8d0e0";
        };
        bright = {
          black = "#4a5468";
          red = "#d88898";
          green = "#a8d8b4";
          yellow = "#e0c888";
          blue = "#98d8f0";
          magenta = "#c4b4e8";
          cyan = "#90d0c8";
          white = "#dce4f0";
        };
      };
      light = {
        normal = {
          black = "#2a3242";
          red = "#b04a5a";
          green = "#3f8a5c";
          yellow = "#9a7a2e";
          blue = "#2f7f9e";
          magenta = "#6a5aa8";
          cyan = "#2f8a86";
          white = "#e8ecf4";
        };
        bright = {
          black = "#5c6678";
          red = "#c85a68";
          green = "#4fa06c";
          yellow = "#b0903f";
          blue = "#4a9cbc";
          magenta = "#8a7ac0";
          cyan = "#4aa8a2";
          white = "#f6f8fc";
        };
      };
      darkDim = {
        red = "#9a5660";
        green = "#6a9878";
        yellow = "#a89060";
        blue = "#6098b0";
        magenta = "#8878a8";
        cyan = "#588880";
      };
      lightDim = {
        red = "#9a5660";
        green = "#6a9878";
        yellow = "#a89060";
        blue = "#6098b0";
        magenta = "#8878a8";
        cyan = "#588880";
      };
    };
  };

  # ─── Catppuccin bright roles are sourced from ansiColors ──────────────────

  testCatppuccinBrightRolesSourceAnsi = {
    expr = let
      of = variant: {
        red_bright = providers.catppuccin.variants.${variant}.palette.red_bright.hex;
        ansiRedBright = providers.catppuccin.variants.${variant}.ansi.bright.red.hex;
        yellow_bright = providers.catppuccin.variants.${variant}.palette.yellow_bright.hex;
        ansiYellowBright = providers.catppuccin.variants.${variant}.ansi.bright.yellow.hex;
        blue_bright = providers.catppuccin.variants.${variant}.palette.blue_bright.hex;
        ansiBlueBright = providers.catppuccin.variants.${variant}.ansi.bright.blue.hex;
      };
    in {
      latte = of "latte";
      frappe = of "frappe";
      macchiato = of "macchiato";
      mocha = of "mocha";
    };
    expected = {
      latte = {
        red_bright = "#de293e";
        ansiRedBright = "#de293e";
        yellow_bright = "#eea02d";
        ansiYellowBright = "#eea02d";
        blue_bright = "#456eff";
        ansiBlueBright = "#456eff";
      };
      frappe = {
        red_bright = "#e67172";
        ansiRedBright = "#e67172";
        yellow_bright = "#d9ba73";
        ansiYellowBright = "#d9ba73";
        blue_bright = "#7b9ef0";
        ansiBlueBright = "#7b9ef0";
      };
      macchiato = {
        red_bright = "#ec7486";
        ansiRedBright = "#ec7486";
        yellow_bright = "#e1c682";
        ansiYellowBright = "#e1c682";
        blue_bright = "#78a1f6";
        ansiBlueBright = "#78a1f6";
      };
      mocha = {
        red_bright = "#f37799";
        ansiRedBright = "#f37799";
        yellow_bright = "#ebd391";
        ansiYellowBright = "#ebd391";
        blue_bright = "#74a8fc";
        ansiBlueBright = "#74a8fc";
      };
    };
  };

  # ─── Sora semantic roles versus the ANSI table ────────────────────────────

  testSoraRolesAndAnsiGreen = {
    expr = let
      dark = providers.sora.variants.dark;
      light = providers.sora.variants.light;
    in {
      darkBlue = dark.palette.blue.hex;
      darkBlueBright = dark.palette.blue_bright.hex;
      darkRedBright = dark.palette.red_bright.hex;
      darkGreen = dark.palette.green.hex;
      darkAnsiGreen = dark.ansi.normal.green.hex;
      lightBlue = light.palette.blue.hex;
      lightBlueBright = light.palette.blue_bright.hex;
      lightRedBright = light.palette.red_bright.hex;
      lightGreen = light.palette.green.hex;
      lightAnsiGreen = light.ansi.normal.green.hex;
    };
    expected = {
      darkBlue = "#80c8e0";
      darkBlueBright = "#98d8f0";
      darkRedBright = "#d88898";
      darkGreen = "#68a888";
      darkAnsiGreen = "#90c8a0";
      lightBlue = "#2f7f9e";
      lightBlueBright = "#4a9cbc";
      lightRedBright = "#c85a68";
      lightGreen = "#3f8a5c";
      lightAnsiGreen = "#3f8a5c";
    };
  };

  # ─── Exposure through the module options ──────────────────────────────────

  testActiveAnsiMatchesDefaultVariant = {
    expr = let
      theme = themeConfig {};
    in {
      matchesProvider = theme.ansi == theme.providers.kanagawa.ansi.dragon;
      red = theme.ansi.normal.red.hex;
    };
    expected = {
      matchesProvider = true;
      red = "#c4746e";
    };
  };

  testActiveAnsiFollowsSelectedFamilyAndVariant = {
    expr = let
      theme = themeConfig {
        aytordev.theme = {
          name = "catppuccin";
          variant = "mocha";
        };
      };
    in {
      brightRed = theme.ansi.bright.red.hex;
      providerBrightRed = theme.providers.catppuccin.ansi.mocha.bright.red.hex;
      matchesProvider = theme.ansi == theme.providers.catppuccin.ansi.mocha;
    };
    expected = {
      brightRed = "#f37799";
      providerBrightRed = "#f37799";
      matchesProvider = true;
    };
  };

  testProvidersExposeAnsiForEveryFamilyVariant = {
    expr =
      builtins.mapAttrs (_: provider: builtins.attrNames provider.ansi)
      (themeConfig {}).providers;
    expected = {
      kanagawa = [
        "dragon"
        "lotus"
        "wave"
      ];
      catppuccin = [
        "frappe"
        "latte"
        "macchiato"
        "mocha"
      ];
      sora = [
        "dark"
        "light"
      ];
    };
  };

  testEvaluatedAnsiDimIsEmptyExceptSora = {
    expr = let
      theme = themeConfig {};
    in {
      kanagawaWave = theme.providers.kanagawa.ansi.wave.dim;
      soraDark = builtins.attrNames theme.providers.sora.ansi.dark.dim;
    };
    expected = {
      kanagawaWave = {};
      soraDark = [
        "blue"
        "cyan"
        "green"
        "magenta"
        "red"
        "yellow"
      ];
    };
  };
}
