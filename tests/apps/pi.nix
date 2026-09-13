{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  pi = import ../../modules/home/programs/terminal/tools/pi/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};

  # Pi declares no upstream resource today, so the integration is always absent.
  integrationFor = family: theme.integrations.${family}.pi or null;

  resolveFor = family: variant: override:
    pi.resolve {
      inherit variant override;
      integration = integrationFor family;
    };

  renderFor = family: variant:
    pi.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  parsedTheme = family: variant: builtins.fromJSON (builtins.toJSON (renderFor family variant));

  brokenIntegration = {
    source = null;
    variants = {};
  };
in {
  # ─── Generated theme name/id and generated resolution ─────────────────────

  testPiGeneratedThemeName = {
    expr = (parsedTheme "kanagawa" "dragon").name;
    expected = "aytordev";
  };

  testPiAbsentIntegrationResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testPiNullGeneratedResolvesNone = {
    expr = pi.resolve {
      variant = "dragon";
      override = null;
      integration = null;
      generated = null;
    };
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  # ─── JSON parse round-trip follows the active variant palette ─────────────

  testPiGeneratedThemeRoundTripsActiveVariantColors = let
    palette = theme.providers.sora.variants.dark;
    parsed = parsedTheme "sora" "dark";
  in {
    expr = {
      inherit (parsed) name;
      bg = parsed.vars.bg;
      text = parsed.vars.text;
      accent = parsed.vars.accent;
      hasColors = parsed.colors ? accent;
      hasExport = parsed.export ? pageBg;
    };
    expected = {
      name = "aytordev";
      bg = palette.bg.hex;
      text = palette.fg.hex;
      accent = palette.accent.hex;
      hasColors = true;
      hasExport = true;
    };
  };

  testPiGeneratedThemeFollowsActiveKanagawaVariant = {
    expr = (parsedTheme "kanagawa" "dragon").vars.bg;
    expected = theme.providers.kanagawa.variants.dragon.bg.hex;
  };

  # ─── ANSI-named slots come from the variant ANSI table ────────────────────

  testPiGeneratedThemeUsesAnsiSlots = let
    ansi = theme.providers.kanagawa.ansi.dragon;
    parsed = parsedTheme "kanagawa" "dragon";
  in {
    expr = {
      inherit
        (parsed.vars)
        brightBlack
        brightGreen
        brightYellow
        brightBlue
        ;
      brightPurple = parsed.vars.brightPurple;
      brightMagenta = parsed.vars.brightMagenta;
      green = parsed.vars.green;
      red = parsed.vars.red;
    };
    expected = {
      brightBlack = ansi.bright.black.hex;
      brightGreen = ansi.bright.green.hex;
      brightYellow = ansi.bright.yellow.hex;
      brightBlue = ansi.bright.blue.hex;
      brightPurple = ansi.bright.magenta.hex;
      brightMagenta = ansi.bright.magenta.hex;
      green = ansi.normal.green.hex;
      red = ansi.normal.red.hex;
    };
  };

  testPiGeneratedThemeFallsBackToPaletteWithoutAnsi = let
    parsed = builtins.fromJSON (
      builtins.toJSON (pi.render {palette = theme.providers.kanagawa.variants.dragon;})
    );
  in {
    expr = parsed.vars.brightGreen;
    expected = theme.providers.kanagawa.variants.dragon.green.hex;
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testPiStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "kanagawa";
    expected = {
      kind = "explicit";
      id = "kanagawa";
      source = "user";
    };
  };

  testPiManualOverrideWins = {
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

  testPiBrokenIntegrationThrows = {
    expr = throws (
      pi.resolve {
        variant = "dragon";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };

  # ─── `none` emits no theme selection ──────────────────────────────────────

  testPiNoneOverrideEmitsNoThemeSelection = {
    expr = pi.themeEntry (resolveFor "kanagawa" "dragon" {mode = "none";});
    expected = {};
  };

  testPiGeneratedResolutionEmitsAytordevSelection = {
    expr = pi.themeEntry (resolveFor "kanagawa" "dragon" null);
    expected = {
      theme = "aytordev";
    };
  };

  testPiStringOverrideEmitsSelection = {
    expr = pi.themeEntry (resolveFor "kanagawa" "dragon" "solarized-light");
    expected = {
      theme = "solarized-light";
    };
  };
}
