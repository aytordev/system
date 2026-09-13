{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig;

  adapter = import ../../modules/home/programs/desktop/bars/sketchybar/theme.nix {inherit lib;};

  theme = themeConfig {};
  inherit (theme) providers;

  constants = adapter.constants {inherit theme providers;};
  themes = adapter.themes providers;

  families = builtins.attrNames providers;
  allPairs =
    lib.concatMap (
      family: map (variant: {inherit family variant;}) (builtins.attrNames providers.${family}.variants)
    )
    families;

  pairKey = pair: "${pair.family}/${pair.variant}";
  variantColors = pair: themes.${pairKey pair};

  # Every string in a generated color table (including nested bar/popup).
  colorStrings = value:
    if builtins.isAttrs value
    then lib.concatMap colorStrings (builtins.attrValues value)
    else if builtins.isString value
    then [value]
    else [];
in {
  # ─── Catalog coverage ─────────────────────────────────────────────────────

  testSketchybarThemesCoverEveryVariant = {
    expr = builtins.sort builtins.lessThan (builtins.attrNames themes);
    expected = builtins.sort builtins.lessThan (map pairKey allPairs);
  };

  testSketchybarCatalogHasFiveVariants = {
    expr = builtins.length (builtins.attrNames themes);
    expected = 5;
  };

  # ─── Active selection ─────────────────────────────────────────────────────

  testSketchybarActiveThemeKey = {
    expr = constants.active_theme;
    expected = "${theme.name}/${theme.variant}";
  };

  testSketchybarActiveColorsMatchThemesEntry = {
    expr = constants.colors == themes.${constants.active_theme};
    expected = true;
  };

  testSketchybarActiveColorsMatchActiveVariant = {
    expr = constants.colors == adapter.colors {inherit (theme) palette ansi;};
    expected = true;
  };

  # ─── Palette + ANSI provenance for every variant ──────────────────────────

  testSketchybarColorsComeFromPaletteAndAnsi = {
    expr =
      builtins.all (
        pair: let
          palette = providers.${pair.family}.variants.${pair.variant};
          ansi = providers.${pair.family}.ansi.${pair.variant};
          colors = variantColors pair;
        in
          colors.red
          == ansi.normal.red.sketchybar
          && colors.red_bright == ansi.bright.red.sketchybar
          && colors.green == ansi.normal.green.sketchybar
          && colors.yellow == ansi.normal.yellow.sketchybar
          && colors.blue == ansi.normal.blue.sketchybar
          && colors.blue_bright == ansi.bright.blue.sketchybar
          && colors.magenta == ansi.normal.magenta.sketchybar
          && colors.cyan == ansi.normal.cyan.sketchybar
          && colors.accent == palette.accent.sketchybar
          && colors.orange == palette.orange.sketchybar
          && colors.pink == palette.pink.sketchybar
      )
      allPairs;
    expected = true;
  };

  testSketchybarBarBackgroundIsTranslucent = {
    expr =
      builtins.all (
        pair: let
          palette = providers.${pair.family}.variants.${pair.variant};
        in
          (variantColors pair).bar.bg == builtins.replaceStrings ["0xff"] ["0xf0"] palette.bg.sketchybar
      )
      allPairs;
    expected = true;
  };

  testSketchybarSpotifyGreenTracksTerminalGreen = {
    expr =
      builtins.all (
        pair: (variantColors pair).spotify_green == (variantColors pair).green
      )
      allPairs;
    expected = true;
  };

  # ─── Well-formed ARGB for every generated color in every variant ──────────

  testSketchybarEveryColorIsWellFormedArgb = {
    expr =
      builtins.all (
        pair:
          builtins.all (value: builtins.match "0x[0-9a-f]{8}" value != null) (
            colorStrings (variantColors pair)
          )
      )
      allPairs;
    expected = true;
  };

  # ─── Families are genuinely distinguishable (no collapsed catalog) ────────

  testSketchybarFamiliesProduceDistinctAccents = {
    expr = let
      accentOf = family: themes."${family}/${providers.${family}.defaultVariant}".accent;
    in
      builtins.length (lib.unique (map accentOf families)) == builtins.length families;
    expected = true;
  };
}
