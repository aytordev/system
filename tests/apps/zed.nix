{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  zed = import ../../modules/home/programs/desktop/editors/zed/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    zed.resolve {
      inherit variant override;
      integration = integrations.${family}.zed or null;
    };

  renderFor = {
    family,
    variant,
    isLight ? false,
  }:
    zed.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
      inherit isLight;
    };

  parsedFor = args: builtins.fromJSON (renderFor args);

  # The single generated `themes[]` entry.
  generatedTheme = parsed: builtins.head parsed.themes;
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testZedKanagawaDragonResolvesOfficial = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "official";
      id = "Kanagawa Dragon";
      provenance = "community-port";
      variantProvenance = "official";
      source = "official";
    };
  };

  testZedCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "Catppuccin Mocha";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testZedSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "Sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Dark-only Sora light must generate, never reuse the dark resource ────

  testZedSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testZedSoraLightIsNotTheDarkOfficial = {
    expr = (resolveFor "sora" "light" null).id == "Sora";
    expected = false;
  };

  # ─── Generated theme is materialized and selected ─────────────────────────

  testZedGeneratedThemeFileOnlyForGeneratedSelection = {
    expr = {
      generated = builtins.attrNames (
        zed.themeFiles {
          resolution = {
            kind = "generated";
            id = "aytordev";
          };
          text = "generated";
        }
      );
      official = builtins.attrNames (
        zed.themeFiles {
          resolution = {
            kind = "official";
            id = "Sora";
          };
          text = "generated";
        }
      );
      none = builtins.attrNames (
        zed.themeFiles {
          resolution = {
            kind = "none";
            id = null;
          };
          text = "generated";
        }
      );
    };
    expected = {
      generated = ["zed/themes/aytordev.json"];
      official = [];
      none = [];
    };
  };

  testZedGeneratedThemeSettingPointsAtGeneratedId = {
    expr = zed.themeSetting (resolveFor "sora" "light" null);
    expected = {
      theme = "aytordev";
    };
  };

  testZedOfficialThemeSettingPointsAtOfficialId = {
    expr = zed.themeSetting (resolveFor "catppuccin" "mocha" null);
    expected = {
      theme = "Catppuccin Mocha";
    };
  };

  # ─── Explicit override wins and suppresses the generated file ─────────────

  testZedStringOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" "Kanagawa Wave";
    expected = {
      kind = "explicit";
      id = "Kanagawa Wave";
      source = "user";
    };
  };

  testZedManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "Kanagawa Lotus";
    };
    expected = {
      kind = "explicit";
      id = "Kanagawa Lotus";
      source = "user";
    };
  };

  testZedOverrideWinsOverGenerated = {
    expr = let
      resolution = resolveFor "sora" "light" "Sora";
    in {
      inherit resolution;
      setting = zed.themeSetting resolution;
      files = zed.themeFiles {
        inherit resolution;
        text = "generated";
      };
    };
    expected = {
      resolution = {
        kind = "explicit";
        id = "Sora";
        source = "user";
      };
      setting = {
        theme = "Sora";
      };
      files = {};
    };
  };

  # ─── Opt-out emits no setting and no generated file ───────────────────────

  testZedNoneOverrideEmitsNothing = {
    expr = let
      resolution = resolveFor "sora" "light" {mode = "none";};
    in {
      inherit resolution;
      setting = zed.themeSetting resolution;
      files = zed.themeFiles {
        inherit resolution;
        text = "generated";
      };
    };
    expected = {
      resolution = {
        kind = "none";
        id = null;
        source = "none";
      };
      setting = {};
      files = {};
    };
  };

  # ─── Generated JSON parses and follows the variant palette/ANSI table ─────

  testZedGeneratedJsonParsesAndHasExpectedColors = let
    palette = theme.providers.sora.variants.light;
    ansi = theme.providers.sora.ansi.light;
    parsed = parsedFor {
      family = "sora";
      variant = "light";
      isLight = true;
    };
    themeEntry = generatedTheme parsed;
  in {
    expr = {
      inherit (parsed) name author;
      themeName = themeEntry.name;
      inherit (themeEntry) appearance;
      background = themeEntry.style.background;
      foreground = themeEntry.style."editor.foreground";
      ansiRed = themeEntry.style."terminal.ansi.red";
      ansiBrightRed = themeEntry.style."terminal.ansi.bright_red";
      ansiDimRed = themeEntry.style."terminal.ansi.dim_red";
    };
    expected = {
      name = "aytordev";
      author = "aytordev";
      themeName = "aytordev";
      appearance = "light";
      background = palette.bg.hex;
      foreground = palette.fg.hex;
      ansiRed = ansi.normal.red.hex;
      ansiBrightRed = ansi.bright.red.hex;
      ansiDimRed = ansi.dim.red.hex;
    };
  };

  testZedGeneratedJsonFollowsKanagawaDragonPalette = let
    palette = theme.providers.kanagawa.variants.dragon;
    ansi = theme.providers.kanagawa.ansi.dragon;
    themeEntry = generatedTheme (parsedFor {
      family = "kanagawa";
      variant = "dragon";
    });
  in {
    expr = {
      inherit (themeEntry) appearance;
      background = themeEntry.style.background;
      accent = themeEntry.style."text.accent";
      ansiGreen = themeEntry.style."terminal.ansi.green";
    };
    expected = {
      appearance = "dark";
      background = palette.bg.hex;
      accent = palette.accent.hex;
      ansiGreen = ansi.normal.green.hex;
    };
  };

  # ─── A malformed integration still fails loudly ───────────────────────────

  testZedBrokenIntegrationThrows = {
    expr = throws (
      zed.resolve {
        variant = "light";
        override = null;
        integration = {
          source = null;
          variants.light.id = "broken-light";
        };
      }
    );
    expected = true;
  };
}
