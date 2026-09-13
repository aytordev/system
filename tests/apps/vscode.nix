{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  vscode = import ../../modules/home/programs/desktop/editors/vscode/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  generatedLabel = family: variant:
    vscode.generatedThemeLabel {
      inherit (theme.providers.${family}) displayName;
      inherit variant;
    };

  resolveFor = family: variant: override:
    vscode.resolve {
      inherit variant override;
      integration = integrations.${family}.vscode or null;
      generated = generatedLabel family variant;
    };

  brokenIntegration = {
    source = null;
    variants.light.id = "broken-light";
  };

  # Stand-in for the extension derivation built by `default.nix`, matching the
  # `generatedFlavor` convention used by the Yazi adapter tests.
  generatedExtension = "/nix/store/generated-vscode-extension";

  mkThemeFor = family: variant:
    vscode.mkTheme {
      inherit family;
      inherit (theme.providers.${family}) displayName;
      inherit variant;
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
      isLight = variant == theme.providers.${family}.lightVariant;
    };

  tokenFor = name:
    (lib.findFirst (rule: (rule.name or "") == name) null (mkThemeFor "sora" "dark").json.tokenColors)
    .settings;
in {
  # ─── Official resources for covered families ─────────────────────────────

  testVscodeKanagawaDragonResolvesOfficial = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "official";
      id = "Kanagawa Dragon";
      provenance = "community-port";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Sora has no official VS Code resource: generate ─────────────────────

  testVscodeSoraDarkResolvesGenerated = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "generated";
      id = "Aytordev Sora Dark";
      source = "generated";
    };
  };

  testVscodeSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "Aytordev Sora Light";
      source = "generated";
    };
  };

  testVscodeSoraGeneratedLabelsAreVariantSpecific = {
    expr = [
      (resolveFor "sora" "dark" null).id
      (resolveFor "sora" "light" null).id
    ];
    expected = [
      "Aytordev Sora Dark"
      "Aytordev Sora Light"
    ];
  };

  # ─── Explicit override wins ──────────────────────────────────────────────

  testVscodeStringOverrideWins = {
    expr = resolveFor "sora" "dark" "Kanagawa Wave";
    expected = {
      kind = "explicit";
      id = "Kanagawa Wave";
      source = "user";
    };
  };

  testVscodeManualOverrideWins = {
    expr = resolveFor "sora" "dark" {
      mode = "manual";
      id = "Default Dark Modern";
    };
    expected = {
      kind = "explicit";
      id = "Default Dark Modern";
      source = "user";
    };
  };

  testVscodeNoneOverrideEmitsNothing = {
    expr = resolveFor "kanagawa" "dragon" {mode = "none";};
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testVscodeBrokenIntegrationThrows = {
    expr = throws (
      vscode.resolve {
        variant = "light";
        override = null;
        integration = brokenIntegration;
        generated = "Aytordev Sora Light";
      }
    );
    expected = true;
  };

  # ─── Generated theme JSON follows the variant palette ────────────────────

  testVscodeGeneratedThemeBackgroundForeground = {
    expr = let
      palette = theme.providers.sora.variants.dark;
      rendered = vscode.render {
        label = generatedLabel "sora" "dark";
        inherit palette;
        ansi = theme.providers.sora.ansi.dark;
        isLight = false;
      };
    in {
      inherit (rendered) name type;
      background = rendered.colors."editor.background";
      foreground = rendered.colors."editor.foreground";
    };
    expected = {
      name = "Aytordev Sora Dark";
      type = "dark";
      background = theme.providers.sora.variants.dark.bg.hex;
      foreground = theme.providers.sora.variants.dark.fg.hex;
    };
  };

  testVscodeGeneratedThemeIsValidJson = {
    expr = let
      rendered = (mkThemeFor "sora" "light").json;
      parsed = builtins.fromJSON (builtins.toJSON rendered);
    in {
      inherit (parsed) name type;
      background = parsed.colors."editor.background";
      foreground = parsed.colors."editor.foreground";
      hasTokenColors = builtins.isList parsed.tokenColors;
      tokenColorCount = builtins.length parsed.tokenColors;
    };
    expected = {
      name = "Aytordev Sora Light";
      type = "light";
      background = theme.providers.sora.variants.light.bg.hex;
      foreground = theme.providers.sora.variants.light.fg.hex;
      hasTokenColors = true;
      tokenColorCount = 30;
    };
  };

  # ─── Generated syntax mirrors the official Sora (Zed) mapping ────────────

  testVscodeGeneratedSyntaxCommentUsesOverlay = {
    expr = tokenFor "Comment";
    expected = {
      foreground = theme.providers.sora.variants.dark.overlay.hex;
      fontStyle = "italic";
    };
  };

  testVscodeGeneratedSyntaxStringUsesAnsiGreen = {
    expr = (tokenFor "String").foreground;
    expected = theme.providers.sora.ansi.dark.normal.green.hex;
  };

  testVscodeGeneratedSyntaxNumberUsesGold = {
    expr = (tokenFor "Number").foreground;
    expected = theme.providers.sora.variants.dark.yellow.hex;
  };

  testVscodeGeneratedSyntaxBooleanUsesRoseItalic = {
    expr = tokenFor "Boolean";
    expected = {
      foreground = theme.providers.sora.variants.dark.pink.hex;
      fontStyle = "italic";
    };
  };

  testVscodeGeneratedSyntaxKeywordUsesPurpleItalic = {
    expr = tokenFor "Keyword";
    expected = {
      foreground = theme.providers.sora.variants.dark.violet.hex;
      fontStyle = "italic";
    };
  };

  testVscodeGeneratedSyntaxPropertyUsesSteel = {
    expr = (tokenFor "Property").foreground;
    expected = theme.providers.sora.variants.dark.accent_dim.hex;
  };

  testVscodeGeneratedSyntaxHasSemanticTokens = {
    expr = let
      rendered = (mkThemeFor "sora" "dark").json;
    in {
      inherit (rendered) semanticHighlighting;
      function = rendered.semanticTokenColors.function;
      keywordStyle = rendered.semanticTokenColors.keyword.fontStyle;
      property = rendered.semanticTokenColors.property;
    };
    expected = {
      semanticHighlighting = true;
      function = theme.providers.sora.variants.dark.accent.hex;
      keywordStyle = "italic";
      property = theme.providers.sora.variants.dark.accent_dim.hex;
    };
  };

  testVscodeGeneratedThemeUsesAnsiTerminalSlots = {
    expr = let
      rendered = (mkThemeFor "sora" "dark").json;
    in {
      black = rendered.colors."terminal.ansiBlack";
      brightRed = rendered.colors."terminal.ansiBrightRed";
      brightWhite = rendered.colors."terminal.ansiBrightWhite";
    };
    expected = {
      black = theme.providers.sora.ansi.dark.normal.black.hex;
      brightRed = theme.providers.sora.ansi.dark.bright.red.hex;
      brightWhite = theme.providers.sora.ansi.dark.bright.white.hex;
    };
  };

  # ─── Generated extension identity is stable and collision-free ───────────

  testVscodeGeneratedExtensionNameIsFamilyScoped = {
    expr = vscode.generatedExtensionName "sora";
    expected = "aytordev-sora-vscode-theme";
  };

  testVscodeGeneratedThemeFilesAreUnique = {
    expr = let
      dark = mkThemeFor "sora" "dark";
      light = mkThemeFor "sora" "light";
    in {
      darkPath = dark.path;
      lightPath = light.path;
      distinct = dark.path != light.path;
    };
    expected = {
      darkPath = "./themes/aytordev-sora-dark-color-theme.json";
      lightPath = "./themes/aytordev-sora-light-color-theme.json";
      distinct = true;
    };
  };

  testVscodeGeneratedManifestContributesBothSoraThemes = {
    expr = let
      manifest = vscode.manifest {
        family = "sora";
        inherit (theme.providers.sora) displayName;
        themes = [
          (mkThemeFor "sora" "dark")
          (mkThemeFor "sora" "light")
        ];
      };
    in {
      inherit (manifest) name publisher version;
      labels = map (entry: entry.label) manifest.contributes.themes;
      paths = map (entry: entry.path) manifest.contributes.themes;
      uiThemes = map (entry: entry.uiTheme) manifest.contributes.themes;
    };
    expected = {
      name = "aytordev-sora-vscode-theme";
      publisher = "aytordev";
      version = "1.0.0";
      labels = [
        "Aytordev Sora Dark"
        "Aytordev Sora Light"
      ];
      paths = [
        "./themes/aytordev-sora-dark-color-theme.json"
        "./themes/aytordev-sora-light-color-theme.json"
      ];
      uiThemes = [
        "vs-dark"
        "vs"
      ];
    };
  };

  # ─── The generated extension is installed only when generated ────────────

  testVscodeGeneratedExtensionInstalledForSora = {
    expr = vscode.profileExtensions {
      base = ["base"];
      resolutions = [
        (resolveFor "sora" "dark" null)
        (resolveFor "sora" "dark" null)
        (resolveFor "sora" "light" null)
      ];
      inherit generatedExtension;
    };
    expected = [
      "base"
      "/nix/store/generated-vscode-extension"
    ];
  };

  testVscodeOfficialSelectionOmitsGeneratedExtension = {
    expr = vscode.profileExtensions {
      base = ["base"];
      resolutions = [
        (resolveFor "kanagawa" "dragon" null)
        (resolveFor "kanagawa" "dragon" null)
        (resolveFor "kanagawa" "lotus" null)
      ];
      inherit generatedExtension;
    };
    expected = ["base"];
  };

  testVscodeNoneOverrideOmitsGeneratedExtension = {
    expr = vscode.profileExtensions {
      base = ["base"];
      resolutions = [
        (resolveFor "sora" "dark" {mode = "none";})
        (resolveFor "sora" "dark" {mode = "none";})
        (resolveFor "sora" "light" {mode = "none";})
      ];
      inherit generatedExtension;
    };
    expected = ["base"];
  };
}
