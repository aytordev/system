{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  hunk = import ../../modules/home/programs/terminal/tools/hunk/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    hunk.resolve {
      inherit variant override;
      integration = integrations.${family}.hunk or null;
    };

  renderFor = family: variant:
    hunk.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  configFor = family: variant: override:
    hunk.configText {
      resolution = resolveFor family variant override;
      generated = renderFor family variant;
    };

  brokenIntegration = {
    source = null;
    variants.light.id = "broken-light";
  };

  kanagawaDragon = theme.providers.kanagawa.variants.dragon;
in {
  # ─── Resolution ───────────────────────────────────────────────────────────

  testHunkSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testHunkSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testHunkKanagawaResolvesGeneratedForEveryVariant = {
    expr = map (variant: (resolveFor "kanagawa" variant null).kind) [
      "wave"
      "dragon"
      "lotus"
    ];
    expected = [
      "generated"
      "generated"
      "generated"
    ];
  };

  testHunkStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "sora";
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testHunkNoneOverrideResolvesNone = {
    expr = resolveFor "kanagawa" "dragon" {mode = "none";};
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testHunkBrokenIntegrationThrows = {
    expr = throws (
      hunk.resolve {
        variant = "light";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };

  # ─── config.toml assembly ─────────────────────────────────────────────────

  testHunkOfficialConfigUsesVendoredSoraBlock = let
    text = configFor "sora" "dark" null;
  in {
    expr = {
      theme = lib.hasInfix "theme = \"custom\"" text;
      label = lib.hasInfix "label = \"Sora\"" text;
      prefs = lib.hasInfix "prompt_save_view_preferences = false" text;
      scopes = lib.hasInfix "[custom_theme.syntax_scopes]" text;
    };
    expected = {
      theme = true;
      label = true;
      prefs = true;
      scopes = true;
    };
  };

  testHunkGeneratedConfigFollowsPalette = let
    text = configFor "kanagawa" "dragon" null;
  in {
    expr = {
      label = lib.hasInfix "label = \"aytordev\"" text;
      accent = lib.hasInfix kanagawaDragon.accent.hex text;
      border = lib.hasInfix "border = \"${kanagawaDragon.border.hex}\"" text;
    };
    expected = {
      label = true;
      accent = true;
      border = true;
    };
  };

  testHunkNoneConfigHasNoThemeSelection = let
    text = configFor "kanagawa" "dragon" {mode = "none";};
  in {
    expr = {
      noTheme = !(lib.hasInfix "theme = \"custom\"" text);
      noBlock = !(lib.hasInfix "[custom_theme]" text);
      prefs = lib.hasInfix "prompt_save_view_preferences = false" text;
    };
    expected = {
      noTheme = true;
      noBlock = true;
      prefs = true;
    };
  };

  # ─── Generated block follows the active palette ───────────────────────────

  testHunkGeneratedUsesPaletteAccentAndOverlay = let
    text = renderFor "kanagawa" "dragon";
  in {
    expr = {
      accent = lib.hasInfix "accent = \"${kanagawaDragon.accent.hex}\"" text;
      comment = lib.hasInfix "\"comment\" = \"${kanagawaDragon.overlay.hex}\"" text;
    };
    expected = {
      accent = true;
      comment = true;
    };
  };

  testHunkGeneratedDiffBackgroundUsesBlendedGreen = {
    expr = lib.hasInfix "addedBg = \"${hunk.blend kanagawaDragon.bg.hex kanagawaDragon.green.hex 0.10}\"" (renderFor "kanagawa" "dragon");
    expected = true;
  };

  testHunkBlendIsDeterministic = {
    expr = hunk.blend "#000000" "#ffffff" 0.5;
    expected = "#808080";
  };
}
