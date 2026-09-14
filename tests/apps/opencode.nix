{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  opencode = import ../../modules/home/programs/terminal/tools/opencode/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  opencodeModule = builtins.readFile ../../modules/home/programs/terminal/tools/opencode/default.nix;

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    opencode.resolve {
      inherit variant override;
      integration = integrations.${family}.opencode or null;
    };

  renderFor = family: variant:
    opencode.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  parsedTheme = family: variant: builtins.fromJSON (builtins.toJSON (renderFor family variant));

  # Resolve a `{ dark, light }` theme entry through its `defs` reference.
  resolvedColor = parsed: key: let
    entry = parsed.theme.${key};
  in
    parsed.defs.${entry.dark};

  brokenIntegration = {
    source = null;
    variants.light.id = "broken-light";
  };

  officialThemeIds = builtins.attrNames opencode.officialThemes;

  vendoredParsed = id: builtins.fromJSON (builtins.readFile opencode.officialThemes.${id});
in {
  # ─── Official resources for covered families ─────────────────────────────

  testOpencodeSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Uncovered families/variants fall back to the generated theme ─────────

  testOpencodeSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testOpencodeSoraLightIsNotTheSoraOfficial = {
    expr = (resolveFor "sora" "light" null).id == "sora";
    expected = false;
  };

  testOpencodeKanagawaResolvesGeneratedForEveryVariant = {
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

  # ─── Explicit override wins ───────────────────────────────────────────────

  testOpencodeStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "sora";
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testOpencodeManualOverrideWins = {
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

  testOpencodeNoneOverrideResolvesNone = {
    expr = resolveFor "kanagawa" "dragon" {mode = "none";};
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testOpencodeBrokenIntegrationThrows = {
    expr = throws (
      opencode.resolve {
        variant = "light";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };

  # ─── `tui.theme` selection per resolution ────────────────────────────────

  testOpencodeOfficialResolutionSelectsVendoredId = {
    expr = opencode.themeEntry (resolveFor "sora" "dark" null);
    expected = {
      theme = "sora";
    };
  };

  testOpencodeGeneratedResolutionSelectsAytordev = {
    expr = opencode.themeEntry (resolveFor "kanagawa" "dragon" null);
    expected = {
      theme = "aytordev";
    };
  };

  testOpencodeNoneOverrideEmitsNoThemeSelection = {
    expr = opencode.themeEntry (resolveFor "kanagawa" "dragon" {mode = "none";});
    expected = {};
  };

  # ─── Generated theme JSON follows the active variant palette ──────────────

  testOpencodeGeneratedThemeIsValidJson = {
    expr = let
      parsed = parsedTheme "kanagawa" "dragon";
    in {
      schema = parsed."$schema";
      hasDefs = builtins.isAttrs parsed.defs;
      hasTheme = builtins.isAttrs parsed.theme;
      darkIsRef = builtins.isString parsed.theme.background.dark;
      lightIsRef = builtins.isString parsed.theme.background.light;
    };
    expected = {
      schema = "https://opencode.ai/theme.json";
      hasDefs = true;
      hasTheme = true;
      darkIsRef = true;
      lightIsRef = true;
    };
  };

  testOpencodeGeneratedThemeMatchesOfficialSchema = {
    expr =
      builtins.sort builtins.lessThan (builtins.attrNames (parsedTheme "kanagawa" "dragon").theme)
      == builtins.sort builtins.lessThan (builtins.attrNames (vendoredParsed "sora").theme);
    expected = true;
  };

  testOpencodeGeneratedThemeFollowsPaletteChrome = let
    palette = theme.providers.kanagawa.variants.dragon;
    parsed = parsedTheme "kanagawa" "dragon";
  in {
    expr = {
      background = resolvedColor parsed "background";
      backgroundPanel = resolvedColor parsed "backgroundPanel";
      text = resolvedColor parsed "text";
      textMuted = resolvedColor parsed "textMuted";
      primary = resolvedColor parsed "primary";
    };
    expected = {
      background = palette.bg.hex;
      backgroundPanel = palette.bg_dim.hex;
      text = palette.fg.hex;
      textMuted = palette.fg_dim.hex;
      primary = palette.accent.hex;
    };
  };

  testOpencodeGeneratedThemeUsesAnsiSlots = let
    ansi = theme.providers.kanagawa.ansi.dragon;
    parsed = parsedTheme "kanagawa" "dragon";
  in {
    expr = {
      syntaxString = resolvedColor parsed "syntaxString";
      syntaxKeyword = resolvedColor parsed "syntaxKeyword";
      diffAdded = resolvedColor parsed "diffAdded";
      diffRemoved = resolvedColor parsed "diffRemoved";
    };
    expected = {
      syntaxString = ansi.normal.green.hex;
      syntaxKeyword = ansi.normal.magenta.hex;
      diffAdded = ansi.normal.green.hex;
      diffRemoved = ansi.normal.red.hex;
    };
  };

  testOpencodeGeneratedThemeFollowsActiveVariant = {
    expr = {
      kanagawa = resolvedColor (parsedTheme "kanagawa" "dragon") "background";
      sora = resolvedColor (parsedTheme "sora" "dark") "background";
    };
    expected = {
      kanagawa = theme.providers.kanagawa.variants.dragon.bg.hex;
      sora = theme.providers.sora.variants.dark.bg.hex;
    };
  };

  # ─── Vendored official themes are real, parseable JSON ────────────────────

  testOpencodeVendoredOfficialThemesExist = {
    expr = builtins.all (id: builtins.pathExists opencode.officialThemes.${id}) officialThemeIds;
    expected = true;
  };

  testOpencodeVendoredOfficialThemesAreSelectableIds = {
    expr = builtins.sort builtins.lessThan officialThemeIds;
    expected = builtins.sort builtins.lessThan [
      "sora"
    ];
  };

  testOpencodeVendoredOfficialThemesAreValidJson = {
    expr =
      builtins.all (
        id: let
          parsed = vendoredParsed id;
        in
          parsed."$schema" == "https://opencode.ai/theme.json" && builtins.isAttrs parsed.theme
      )
      officialThemeIds;
    expected = true;
  };

  # ─── Existing OpenCode settings/providers/skills are preserved ────────────

  testOpencodePreservesExistingSettings = {
    expr = {
      autoshare = lib.hasInfix "autoshare = false" opencodeModule;
      autoupdate = lib.hasInfix "autoupdate = false" opencodeModule;
      agents = lib.hasInfix "aiTools.opencode.agents" opencodeModule;
      reviewerPrompt = lib.hasInfix "agent-sdd-review.md" opencodeModule;
      commands = lib.hasInfix "inherit (aiTools.opencode) commands" opencodeModule;
      context = lib.hasInfix "context = builtins.readFile" opencodeModule;
      skills = lib.hasInfix "skills = lib.getFile" opencodeModule;
    };
    expected = {
      autoshare = true;
      autoupdate = true;
      agents = true;
      reviewerPrompt = true;
      commands = true;
      context = true;
      skills = true;
    };
  };
}
