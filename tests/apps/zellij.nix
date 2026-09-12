{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  zellij = import ../../modules/home/programs/terminal/tools/zellij/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    zellij.resolve {
      inherit variant override;
      integration = integrations.${family}.zellij or null;
    };

  renderFor = family: variant: zellij.render {palette = theme.providers.${family}.variants.${variant};};
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testZellijCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "catppuccin-mocha";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testZellijCatppuccinLatteResolvesOfficial = {
    expr = resolveFor "catppuccin" "latte" null;
    expected = {
      kind = "official";
      id = "catppuccin-latte";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Families without a Zellij resource generate ──────────────────────────

  testZellijSoraDarkResolvesGenerated = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testZellijKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testZellijStringOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" "default";
    expected = {
      kind = "explicit";
      id = "default";
      source = "user";
    };
  };

  testZellijManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "kanagawa-wave";
    };
    expected = {
      kind = "explicit";
      id = "kanagawa-wave";
      source = "user";
    };
  };

  # ─── Opt-out emits no theme selection or file ─────────────────────────────

  testZellijNoneOverrideEmitsNothing = {
    expr = let
      resolution = resolveFor "kanagawa" "dragon" {mode = "none";};
    in {
      inherit resolution;
      setting = zellij.themeSetting resolution;
      files = zellij.themeFiles {
        officialName = "kanagawa";
        officialFile = null;
        inherit resolution;
        generatedText = "generated";
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

  testZellijNoneDropsOfficialFile = {
    expr = let
      resolution = zellij.resolve {
        variant = "mocha";
        override = {
          mode = "none";
        };
        integration = integrations.catppuccin.zellij;
      };
    in
      zellij.themeFiles {
        officialName = "catppuccin";
        officialFile = zellij.officialThemeFiles.catppuccin;
        inherit resolution;
      };
    expected = {};
  };

  # ─── Generated theme content follows the variant palette ──────────────────

  testZellijGeneratedThemeUsesVariantPalette = {
    expr = let
      palette = theme.providers.kanagawa.variants.dragon;
      text = renderFor "kanagawa" "dragon";
    in {
      wraps = lib.hasInfix "themes {" text && lib.hasInfix "aytordev {" text;
      bg = lib.hasInfix "bg \"${palette.bg.hex}\"" text;
      accent = lib.hasInfix "blue \"${palette.accent.hex}\"" text;
      dim = lib.hasInfix "black \"${palette.bg_dim.hex}\"" text;
    };
    expected = {
      wraps = true;
      bg = true;
      accent = true;
      dim = true;
    };
  };

  testZellijGeneratedThemeFollowsActiveFamily = {
    expr = let
      palette = theme.providers.sora.variants.dark;
      text = renderFor "sora" "dark";
    in
      lib.hasInfix "bg \"${palette.bg.hex}\"" text;
    expected = true;
  };

  # ─── Theme files materialize only for a selection ─────────────────────────

  testZellijThemeFilesForSelection = {
    expr = {
      generated = builtins.attrNames (
        zellij.themeFiles {
          resolution = {
            kind = "generated";
            id = "aytordev";
          };
          generatedText = "generated";
        }
      );
      official = builtins.attrNames (
        zellij.themeFiles {
          officialName = "catppuccin";
          officialFile = zellij.officialThemeFiles.catppuccin;
          resolution = {
            kind = "official";
            id = "catppuccin-mocha";
          };
        }
      );
      none = builtins.attrNames (
        zellij.themeFiles {
          officialName = "catppuccin";
          officialFile = zellij.officialThemeFiles.catppuccin;
          resolution = {
            kind = "none";
            id = null;
          };
        }
      );
    };
    expected = {
      generated = ["aytordev"];
      official = ["catppuccin"];
      none = [];
    };
  };

  testZellijVendoredThemeDefinesResolvedName = {
    expr = let
      text = builtins.readFile zellij.officialThemeFiles.catppuccin;
    in {
      definesMocha = lib.hasInfix "catppuccin-mocha {" text;
      definesMacchiato = lib.hasInfix "catppuccin-macchiato {" text;
    };
    expected = {
      definesMocha = true;
      definesMacchiato = true;
    };
  };

  testZellijVendoredThemeFileExists = {
    expr = builtins.pathExists zellij.officialThemeFiles.catppuccin;
    expected = true;
  };

  testZellijBrokenIntegrationThrows = {
    expr = throws (
      zellij.resolve {
        variant = "mocha";
        override = null;
        integration = {
          source = null;
          variants.mocha.id = "catppuccin-mocha";
        };
      }
    );
    expected = true;
  };
}
