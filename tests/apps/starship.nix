{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  starship = import ../../modules/home/programs/terminal/tools/starship/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    starship.resolve {
      inherit variant override;
      integration = integrations.${family}.starship or null;
    };

  selectionFor = family: variant: override:
    starship.paletteSelection {
      resolution = resolveFor family variant override;
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  stylesFor = family: variant: override:
    starship.styleOverrides {
      resolution = resolveFor family variant override;
    };

  kanagawaDragon = theme.providers.kanagawa.variants.dragon;
  kanagawaAnsi = theme.providers.kanagawa.ansi.dragon;

  brokenIntegration = {
    source = null;
    variants = {
      dark = {
        id = "broken";
      };
    };
  };
in {
  # ─── Official selection: sora (dark only) ─────────────────────────────────

  testStarshipSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testStarshipSoraDarkVendorsUpstreamPalette = {
    expr = let
      selection = selectionFor "sora" "dark" null;
    in {
      name = selection.palette;
      cyan = selection.palettes.sora.cyan;
      gold = selection.palettes.sora.gold;
    };
    expected = {
      name = "sora";
      cyan = "#80c8e0";
      gold = "#d4b878";
    };
  };

  # Sora's official palette is vendored verbatim, including the `peach`/`teal`
  # keys the module-style overlay relies on.
  testStarshipSoraDarkKeepsNativePalette = {
    expr = let
      palette = (selectionFor "sora" "dark" null).palettes.sora;
    in {
      inherit
        (palette)
        cyan
        peach
        teal
        gold
        ;
    };
    expected = {
      cyan = "#80c8e0";
      peach = "#d0a888";
      teal = "#78b8b0";
      gold = "#d4b878";
    };
  };

  # Sora is the only resource that ships module styles; the overlay re-colors
  # the modules the base prompt's shared keys (`blue`/`red`) cannot.
  testStarshipSoraDarkEmitsOfficialStyleOverrides = {
    expr = let
      styles = stylesFor "sora" "dark" null;
    in {
      inherit (styles) directory;
      rust = styles.rust.style;
      gitStatus = styles.git_status.style;
      usernameUser = styles.username.style_user;
      usernameRoot = styles.username.style_root;
      vimcmd = styles.character.vimcmd_symbol;
      golang = styles.golang.style;
      dockerDisabled = styles.docker_context.disabled;
      dockerStyle = styles.docker_context.style;
    };
    expected = {
      directory = {
        style = "cyan";
      };
      rust = "peach";
      gitStatus = "rose";
      usernameUser = "steel";
      usernameRoot = "rose bold";
      vimcmd = "[N](bold purple)";
      golang = "cyan";
      dockerDisabled = false;
      dockerStyle = "teal";
    };
  };

  testStarshipGeneratedEmitsNoStyleOverrides = {
    expr = stylesFor "kanagawa" "dragon" null;
    expected = {};
  };

  testStarshipSoraLightEmitsNoStyleOverrides = {
    expr = stylesFor "sora" "light" null;
    expected = {};
  };

  # ─── Generated fallback ───────────────────────────────────────────────────

  testStarshipSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testStarshipSoraLightIsNotTheDarkOfficial = {
    expr = (resolveFor "sora" "light" null).id == "sora";
    expected = false;
  };

  testStarshipKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testStarshipGeneratedPaletteUsesVariantAnsiAndPalette = {
    expr = let
      selection = selectionFor "kanagawa" "dragon" null;
      generated = selection.palettes.aytordev;
    in {
      name = selection.palette;
      inherit (generated) text;
      inherit (generated) peach;
      inherit (generated) red;
      inherit (generated) cyan;
      brightBlue = generated.bright_blue;
    };
    expected = {
      name = "aytordev";
      text = kanagawaDragon.fg.hex;
      peach = kanagawaDragon.orange.hex;
      red = kanagawaAnsi.normal.red.hex;
      cyan = kanagawaAnsi.normal.cyan.hex;
      brightBlue = kanagawaAnsi.bright.blue.hex;
    };
  };

  # ─── Explicit override wins (bare string and submodule) ───────────────────

  testStarshipStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "sora";
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testStarshipManualOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" {
      mode = "manual";
      id = "sora";
    };
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testStarshipOverrideSelectsPalette = {
    expr = (selectionFor "kanagawa" "dragon" "sora").palette;
    expected = "sora";
  };

  testStarshipUnknownOverrideEmitsOnlyName = {
    expr = selectionFor "kanagawa" "dragon" "nonexistent_palette";
    expected = {
      palette = "nonexistent_palette";
    };
  };

  # ─── `none` emits no palette selection ────────────────────────────────────

  testStarshipNoneOverrideResolvesNone = {
    expr = resolveFor "kanagawa" "dragon" {
      mode = "none";
    };
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testStarshipNoneOverrideEmitsNothing = {
    expr = selectionFor "kanagawa" "dragon" {
      mode = "none";
    };
    expected = {};
  };

  # ─── Broken declarations stay loud ────────────────────────────────────────

  testStarshipMalformedIntegrationThrows = {
    expr = throws (
      starship.resolve {
        variant = "dark";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };
}
