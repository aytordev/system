{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  yazi = import ../../modules/home/programs/terminal/tools/yazi/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    yazi.resolve {
      inherit variant override;
      generated = "${family}-${variant}";
      integration = integrations.${family}.yazi or null;
    };

  # Stand-in for the generated flavor derivation produced by `default.nix`.
  generatedFlavor = "/nix/store/generated-flavor";

  generatedFor = family: variant:
    yazi.generatedFlavor {
      palette = theme.providers.${family}.variants.${variant};
    };
in {
  # ─── Sora official is a whole theme, not a flavor ─────────────────────────

  testYaziSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testYaziSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "sora-light";
      source = "generated";
    };
  };

  testYaziSoraOfficialUsesThemeNotFlavor = {
    expr = let
      resolution = resolveFor "sora" "dark" null;
      selection = yazi.themeSelection {inherit resolution;};
    in {
      hasFlavor = selection ? flavor;
      cwd = selection.mgr.cwd.fg;
      flavorEntries = builtins.attrNames (
        yazi.flavorEntries {
          inherit resolution generatedFlavor;
        }
      );
    };
    expected = {
      hasFlavor = false;
      cwd = "#80c8e0";
      flavorEntries = [];
    };
  };

  testYaziVendoredSoraThemeExists = {
    expr = builtins.pathExists yazi.officialThemes.sora;
    expected = true;
  };

  testYaziVendoredSoraThemeIsFullTheme = {
    expr = let
      text = builtins.readFile yazi.officialThemes.sora;
    in {
      hasMgr = lib.hasInfix "[mgr]" text;
      hasColor = lib.hasInfix "#80c8e0" text;
      hasFlavorTable = lib.hasInfix "[flavor]" text;
    };
    expected = {
      hasMgr = true;
      hasColor = true;
      hasFlavorTable = false;
    };
  };

  # ─── Kanagawa has no Yazi resource: generate ──────────────────────────────

  testYaziKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "kanagawa-dragon";
      source = "generated";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testYaziStringOverrideWins = {
    expr = resolveFor "sora" "dark" "kanagawa-dragon";
    expected = {
      kind = "explicit";
      id = "kanagawa-dragon";
      source = "user";
    };
  };

  testYaziManualOverrideWins = {
    expr = resolveFor "sora" "dark" {
      mode = "manual";
      id = "kanagawa-dragon";
    };
    expected = {
      kind = "explicit";
      id = "kanagawa-dragon";
      source = "user";
    };
  };

  # ─── Opt-out emits no flavor and no theme selection ───────────────────────

  testYaziNoneOverrideEmitsNothing = {
    expr = let
      resolution = resolveFor "sora" "dark" {mode = "none";};
    in {
      inherit resolution;
      flavors = yazi.flavorEntries {
        inherit resolution generatedFlavor;
      };
      theme = yazi.themeSelection {inherit resolution;};
    };
    expected = {
      resolution = {
        kind = "none";
        id = null;
        source = "none";
      };
      flavors = {};
      theme = {};
    };
  };

  # ─── Composition selects exactly one resource ─────────────────────────────

  testYaziFlavorEntriesForSelection = {
    expr = let
      entries = resolution:
        builtins.attrNames (
          yazi.flavorEntries {
            inherit resolution generatedFlavor;
          }
        );
    in {
      generated = entries (resolveFor "kanagawa" "dragon" null);
      officialSora = entries (resolveFor "sora" "dark" null);
      none = entries {
        kind = "none";
        id = null;
      };
    };
    expected = {
      generated = ["kanagawa-dragon"];
      officialSora = [];
      none = [];
    };
  };

  testYaziGeneratedSelectionPinsBothPolarities = {
    expr =
      (yazi.themeSelection {
        resolution = resolveFor "kanagawa" "dragon" null;
      }).flavor;
    expected = {
      dark = "kanagawa-dragon";
      light = "kanagawa-dragon";
    };
  };

  # ─── Generated flavor content follows the variant palette ─────────────────

  testYaziGeneratedFlavorUsesVariantPalette = {
    expr = let
      palette = theme.providers.kanagawa.variants.dragon;
      text = generatedFor "kanagawa" "dragon";
    in {
      accent = lib.hasInfix palette.accent.hex text;
      bg = lib.hasInfix palette.bg.hex text;
    };
    expected = {
      accent = true;
      bg = true;
    };
  };

  testYaziGeneratedFlavorFollowsActiveFamily = {
    expr = let
      palette = theme.providers.sora.variants.dark;
    in
      lib.hasInfix palette.accent.hex (generatedFor "sora" "dark");
    expected = true;
  };

  testYaziBrokenIntegrationThrows = {
    expr = throws (
      yazi.resolve {
        variant = "dark";
        override = null;
        integration = {
          source = null;
          variants.dark.id = "sora";
        };
      }
    );
    expected = true;
  };
}
