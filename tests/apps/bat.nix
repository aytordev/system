{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  bat = import ../../modules/home/programs/terminal/tools/bat/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    bat.resolve {
      inherit variant override;
      integration = integrations.${family}.bat or null;
    };

  renderFor = family: variant:
    bat.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  sourcesFor = family: variant: override: generatedSource:
    bat.themeSources {
      resolution = resolveFor family variant override;
      inherit generatedSource;
    };

  # Count non-overlapping occurrences of `needle` in `text`.
  occurrences = needle: text: lib.length (lib.splitString needle text) - 1;
in {
  # ─── Official ids per family/variant ──────────────────────────────────────

  testBatSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "Sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Kanagawa covers wave only ────────────────────────────────────────────

  testBatKanagawaWaveResolvesOfficial = {
    expr = resolveFor "kanagawa" "wave" null;
    expected = {
      kind = "official";
      id = "Kanagawa";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testBatKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testBatKanagawaLotusResolvesGenerated = {
    expr = resolveFor "kanagawa" "lotus" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Sora light must generate, never reuse the dark resource ──────────────

  testBatSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testBatSoraLightIsNotTheSoraOfficial = {
    expr = (resolveFor "sora" "light" null).id == "Sora";
    expected = false;
  };

  # ─── Theme selection per resolution kind ──────────────────────────────────

  testBatOfficialSelectionDeploysVendoredTheme = {
    expr = sourcesFor "sora" "dark" null "generated";
    expected = {
      "Sora" = ../../modules/home/programs/terminal/tools/bat/themes/sora.tmTheme;
    };
  };

  testBatKanagawaWaveDeploysVendoredTheme = {
    expr = sourcesFor "kanagawa" "wave" null "generated";
    expected = {
      "Kanagawa" = ../../modules/home/programs/terminal/tools/bat/themes/kanagawa-wave.tmTheme;
    };
  };

  testBatGeneratedSelectionDeploysGeneratedTheme = {
    expr = sourcesFor "kanagawa" "dragon" null "generated:dragon";
    expected = {
      aytordev = "generated:dragon";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testBatStringOverrideWins = {
    expr = resolveFor "sora" "dark" "Kanagawa";
    expected = {
      kind = "explicit";
      id = "Kanagawa";
      source = "user";
    };
  };

  testBatManualOverrideWins = {
    expr = resolveFor "sora" "dark" {
      mode = "manual";
      id = "Sora";
    };
    expected = {
      kind = "explicit";
      id = "Sora";
      source = "user";
    };
  };

  testBatManualOverrideToGeneratedPinsGeneratedTheme = {
    expr = sourcesFor "sora" "dark" {
      mode = "manual";
      id = "aytordev";
    } "generated";
    expected = {
      aytordev = "generated";
    };
  };

  # ─── Opt-out emits nothing ────────────────────────────────────────────────

  testBatNoneOverrideEmitsNothing = {
    expr = let
      resolution = resolveFor "kanagawa" "wave" {mode = "none";};
    in {
      inherit resolution;
      themes = sourcesFor "kanagawa" "wave" {mode = "none";} "generated";
    };
    expected = {
      resolution = {
        kind = "none";
        id = null;
        source = "none";
      };
      themes = {};
    };
  };

  testBatBrokenIntegrationThrows = {
    expr = throws (
      bat.resolve {
        variant = "dark";
        override = null;
        integration = {
          source = null;
          variants.dark.id = "Sora";
        };
      }
    );
    expected = true;
  };

  # ─── Generated tmTheme schema ─────────────────────────────────────────────

  testBatGeneratedTmThemeIsValidPlist = {
    expr = let
      text = renderFor "kanagawa" "dragon";
      palette = theme.providers.kanagawa.variants.dragon;
      ansi = theme.providers.kanagawa.ansi.dragon;
    in {
      declaration = lib.hasPrefix "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" text;
      doctype = lib.hasInfix "<!DOCTYPE plist PUBLIC" text;
      plistRoot = lib.hasInfix "<plist version=\"1.0\">" text && lib.hasInfix "</plist>" text;
      name = lib.hasInfix "<string>aytordev</string>" text;
      dictsBalanced = occurrences "<dict>" text == occurrences "</dict>" text;
      arraysBalanced = occurrences "<array>" text == occurrences "</array>" text;
      background = lib.hasInfix palette.bg.hex text;
      foreground = lib.hasInfix palette.fg.hex text;
      ansiGreen = lib.hasInfix ansi.normal.green.hex text;
      ansiMagenta = lib.hasInfix ansi.normal.magenta.hex text;
    };
    expected = {
      declaration = true;
      doctype = true;
      plistRoot = true;
      name = true;
      dictsBalanced = true;
      arraysBalanced = true;
      background = true;
      foreground = true;
      ansiGreen = true;
      ansiMagenta = true;
    };
  };

  testBatGeneratedTmThemeFollowsActiveVariant = {
    expr = let
      text = renderFor "sora" "light";
      palette = theme.providers.sora.variants.light;
      ansi = theme.providers.sora.ansi.light;
    in {
      background = lib.hasInfix palette.bg.hex text;
      ansiBlue = lib.hasInfix ansi.normal.blue.hex text;
    };
    expected = {
      background = true;
      ansiBlue = true;
    };
  };

  # ─── Vendored official files are real plists ──────────────────────────────

  testBatVendoredOfficialThemesExist = {
    expr = builtins.all (name: builtins.pathExists bat.officialThemes.${name}) (
      builtins.attrNames bat.officialThemes
    );
    expected = true;
  };

  testBatVendoredKanagawaDeclaresWaveName = {
    expr = let
      text = builtins.readFile bat.officialThemes."Kanagawa";
    in {
      xml = lib.hasPrefix "<?xml" text;
      name = lib.hasInfix "<string>Kanagawa</string>" text;
    };
    expected = {
      xml = true;
      name = true;
    };
  };
}
