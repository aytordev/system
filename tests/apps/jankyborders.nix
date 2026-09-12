{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig;

  jankyborders = import ../../modules/home/services/jankyborders/theme.nix {
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};

  # Every registered (family, variant) pair; JankyBorders generates a pair of
  # colors for each, so the contract must hold for all of them.
  families = builtins.attrNames theme.providers;
  variantsOf = family: builtins.attrNames theme.providers.${family}.variants;
  allPairs =
    lib.concatMap (
      family: map (variant: {inherit family variant;}) (variantsOf family)
    )
    families;

  paletteFor = pair: theme.providers.${pair.family}.variants.${pair.variant};
  colorsFor = pair: jankyborders.colors {palette = paletteFor pair;};
in {
  # ─── Fixture sanity: all nine variants are covered ────────────────────────

  testJankybordersIteratesEveryVariant = {
    expr = builtins.length allPairs;
    expected = 9;
  };

  # ─── Active/inactive are distinguishable in every family/variant ──────────

  testJankybordersActiveDiffersFromInactiveForEveryVariant = {
    expr = map (pair: (colorsFor pair).active_color != (colorsFor pair).inactive_color) allPairs;
    expected = map (_: true) allPairs;
  };

  # ─── ARGB (`0xAARRGGBB`) validity for both colors ─────────────────────────

  testJankybordersColorsAreValidArgbForEveryVariant = {
    expr =
      map (
        pair: let
          colors = colorsFor pair;
        in
          (builtins.match "0x[0-9a-f]{8}" colors.active_color != null)
          && (builtins.match "0x[0-9a-f]{8}" colors.inactive_color != null)
      )
      allPairs;
    expected = map (_: true) allPairs;
  };

  # ─── Documented role choice ───────────────────────────────────────────────

  testJankybordersDocumentsActiveInactiveRoles = {
    expr = {
      active = jankyborders.activeRole;
      inactive = jankyborders.inactiveRole;
    };
    expected = {
      active = "accent";
      inactive = "border";
    };
  };

  testJankybordersColorsFollowTheDeclaredRoles = {
    expr = colorsFor {
      family = "catppuccin";
      variant = "mocha";
    };
    expected = {
      active_color = theme.providers.catppuccin.variants.mocha.${jankyborders.activeRole}.sketchybar;
      inactive_color = theme.providers.catppuccin.variants.mocha.${jankyborders.inactiveRole}.sketchybar;
    };
  };

  # ─── Sample variant matches the provider palette literally ────────────────

  testJankybordersMochaMatchesProviderPalette = {
    expr = colorsFor {
      family = "catppuccin";
      variant = "mocha";
    };
    expected = {
      active_color = theme.providers.catppuccin.variants.mocha.accent.sketchybar;
      inactive_color = theme.providers.catppuccin.variants.mocha.border.sketchybar;
    };
  };

  # ─── Hybrid resolution: no official resource, generated palette wins ──────

  testJankybordersResolvesGenerated = {
    expr = jankyborders.resolve {variant = "dragon";};
    expected = {
      kind = "generated";
      id = jankyborders.generatedId;
      source = "generated";
    };
  };

  testJankybordersExplicitOverrideWins = {
    expr = jankyborders.resolve {
      variant = "dragon";
      override = "user-theme";
    };
    expected = {
      kind = "explicit";
      id = "user-theme";
      source = "user";
    };
  };

  testJankybordersNoneOverrideOptsOut = {
    expr = jankyborders.resolve {
      variant = "dragon";
      override = {
        mode = "none";
      };
    };
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };
}
