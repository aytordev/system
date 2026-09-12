{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  lazygit = import ../../modules/home/programs/terminal/tools/lazygit/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  kanagawaPalette = theme.providers.kanagawa.variants.dragon;

  resolveFor = family: variant: override:
    lazygit.resolve {
      inherit variant override;
      integration = integrations.${family}.lazygit or null;
    };

  guiFor = family: variant: override:
    lazygit.guiSelection {
      resolution = resolveFor family variant override;
      palette = theme.providers.${family}.variants.${variant};
    };

  moduleSource =
    builtins.readFile ../../modules/home/programs/terminal/tools/lazygit/default.nix
    + builtins.readFile ../../modules/home/programs/terminal/tools/lazygit/config.nix;
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testLazygitCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "catppuccin-mocha-mauve";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testLazygitCatppuccinEveryFlavorResolvesOfficial = {
    expr = map (variant: (resolveFor "catppuccin" variant null).id) [
      "latte"
      "frappe"
      "macchiato"
      "mocha"
    ];
    expected = [
      "catppuccin-latte-mauve"
      "catppuccin-frappe-mauve"
      "catppuccin-macchiato-mauve"
      "catppuccin-mocha-mauve"
    ];
  };

  testLazygitSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Sora light and Kanagawa generate ─────────────────────────────────────

  testLazygitSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testLazygitKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testLazygitStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "catppuccin-latte-mauve";
    expected = {
      kind = "explicit";
      id = "catppuccin-latte-mauve";
      source = "user";
    };
  };

  testLazygitManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "sora";
    };
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  # ─── Opt-out emits no theme colors ────────────────────────────────────────

  testLazygitNoneOverrideEmitsNoTheme = {
    expr = guiFor "catppuccin" "mocha" {mode = "none";};
    expected = {};
  };

  testLazygitNoneOverrideDropsGeneratedTheme = {
    expr = guiFor "kanagawa" "dragon" {mode = "none";};
    expected = {};
  };

  # ─── Generated theme follows the active palette ───────────────────────────

  testLazygitGeneratedThemeMatchesPalette = {
    expr = guiFor "kanagawa" "dragon" null;
    expected = {
      theme = lazygit.generatedTheme kanagawaPalette;
    };
  };

  testLazygitGeneratedThemeRolesMapToPalette = {
    expr = let
      t = (guiFor "kanagawa" "dragon" null).theme;
    in {
      inherit
        (t)
        defaultFgColor
        activeBorderColor
        unstagedChangesColor
        selectedLineBgColor
        optionsTextColor
        ;
    };
    expected = {
      defaultFgColor = [kanagawaPalette.fg.hex];
      activeBorderColor = [
        kanagawaPalette.accent.hex
        "bold"
      ];
      unstagedChangesColor = [kanagawaPalette.red.hex];
      selectedLineBgColor = [kanagawaPalette.bg_visual.hex];
      optionsTextColor = [kanagawaPalette.blue.hex];
    };
  };

  testLazygitGeneratedThemeFollowsActiveFamily = {
    expr = let
      palette = theme.providers.sora.variants.light;
    in
      (guiFor "sora" "light" null).theme.defaultFgColor == [palette.fg.hex];
    expected = true;
  };

  # ─── Official selection emits the vendored upstream fragment ──────────────

  testLazygitOfficialCatppuccinEmitsVendoredTheme = {
    expr = guiFor "catppuccin" "mocha" null;
    expected = lazygit.officialThemes.catppuccin.catppuccin-mocha-mauve;
  };

  testLazygitOfficialSoraEmitsVendoredTheme = {
    expr = guiFor "sora" "dark" null;
    expected = lazygit.officialThemes.sora.sora;
  };

  testLazygitCatppuccinOfficialCarriesAuthorColors = {
    expr = (guiFor "catppuccin" "mocha" null).authorColors."*";
    expected = "#b4befe";
  };

  testLazygitSoraOfficialHasNoAuthorColors = {
    expr = guiFor "sora" "dark" null ? authorColors;
    expected = false;
  };

  testLazygitVendoredThemesMatchUpstreamValues = {
    expr = let
      mocha = lazygit.officialThemes.catppuccin.catppuccin-mocha-mauve.theme;
      sora = lazygit.officialThemes.sora.sora.theme;
    in {
      mochaFg = mocha.defaultFgColor;
      mochaActive = mocha.activeBorderColor;
      soraFg = sora.defaultFgColor;
      soraUnstaged = sora.unstagedChangesColor;
    };
    expected = {
      mochaFg = ["#cdd6f4"];
      mochaActive = [
        "#cba6f7"
        "bold"
      ];
      soraFg = ["#c8d0e0"];
      soraUnstaged = ["#c46c78"];
    };
  };

  testLazygitGeneratedIdDoesNotCollideWithVendoredThemes = {
    expr = lazygit.officialById ? ${lazygit.generatedId};
    expected = false;
  };

  # ─── Non-theme settings survive the theme swap ────────────────────────────

  testLazygitModuleKeepsPaletteDrivenAuthorColors = {
    expr = {
      hasAuthorColors = lib.hasInfix "authorColors" moduleSource;
      usesPalette = lib.hasInfix "themeCfg.palette.accent.hex" moduleSource;
      keepsCustomCommands = lib.hasInfix "custom-commands.nix" moduleSource;
      keepsEditPreset = lib.hasInfix "editPreset = \"nvim\"" moduleSource;
    };
    expected = {
      hasAuthorColors = true;
      usesPalette = true;
      keepsCustomCommands = true;
      keepsEditPreset = true;
    };
  };

  # ─── No hardcoded Kanagawa hexes remain ───────────────────────────────────

  testLazygitModuleHasNoHardcodedKanagawaHexes = {
    expr = map (hex: lib.hasInfix hex moduleSource) [
      "#957fb8"
      "#c0a36e"
      "#c34043"
      "#7e9cd8"
    ];
    expected = [
      false
      false
      false
      false
    ];
  };

  testLazygitBrokenIntegrationThrows = {
    expr = throws (
      lazygit.resolve {
        variant = "mocha";
        override = null;
        integration = {
          source = null;
          variants.mocha.id = "catppuccin-mocha-mauve";
        };
      }
    );
    expected = true;
  };
}
