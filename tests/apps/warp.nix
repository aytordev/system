{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  warp = import ../../modules/home/programs/terminal/emulators/warp/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    warp.resolve {
      inherit variant override;
      integration = integrations.${family}.warp or null;
    };

  renderFor = {
    family,
    variant,
    isLight ? false,
  }:
    warp.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
      inherit isLight;
    };

  entriesFor = family: variant:
    warp.entries {
      resolution = resolveFor family variant null;
      generatedText = "generated";
    };

  vendoredPaths = map (name: "warp/themes/${name}.yaml") (builtins.attrNames warp.vendoredThemes);

  # The module applied directly with a stubbed environment, without pulling
  # Home Manager in. `config` and `pkgs` are stubs: only the option
  # declarations are read, so the config body (and its theme lookups) stays
  # lazy while `enable` is false.
  warpModule = import ../../modules/home/programs/terminal/emulators/warp/default.nix {
    config = {
      aytordev.programs.terminal.emulators.warp.enable = false;
      aytordev.theme = {
        name = "kanagawa";
        variant = "dragon";
        palette = {};
        ansi = {};
        isLight = false;
        integrations = {};
      };
    };
    inherit lib;
    pkgs = {
      "warp-terminal" = {};
    };
  };

  warpOptions = warpModule.options.aytordev.programs.terminal.emulators.warp;
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testWarpCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "catppuccin_mocha";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testWarpCatppuccinEveryFlavorResolvesOfficial = {
    expr = map (variant: (resolveFor "catppuccin" variant null).id) [
      "latte"
      "frappe"
      "macchiato"
      "mocha"
    ];
    expected = [
      "catppuccin_latte"
      "catppuccin_frappe"
      "catppuccin_macchiato"
      "catppuccin_mocha"
    ];
  };

  # ─── Families with no declared Warp integration generate ──────────────────

  testWarpKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testWarpSoraDarkResolvesGenerated = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testWarpStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "catppuccin_mocha";
    expected = {
      kind = "explicit";
      id = "catppuccin_mocha";
      source = "user";
    };
  };

  testWarpManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "kanagawa_wave";
    };
    expected = {
      kind = "explicit";
      id = "kanagawa_wave";
      source = "user";
    };
  };

  testWarpNoneOverrideEmitsNothing = {
    expr = let
      resolution = resolveFor "catppuccin" "mocha" {mode = "none";};
    in {
      inherit resolution;
      entries = warp.entries {
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
      entries =
        lib.mapAttrs' (
          name: path: lib.nameValuePair "warp/themes/${name}.yaml" {source = path;}
        )
        warp.vendoredThemes;
    };
  };

  testWarpBrokenIntegrationThrows = {
    expr = throws (
      warp.resolve {
        variant = "mocha";
        override = null;
        integration = {
          source = null;
          variants.mocha.id = "catppuccin_mocha";
        };
      }
    );
    expected = true;
  };

  # ─── Vendored resources are real, non-colliding files ─────────────────────

  testWarpVendoredThemesExist = {
    expr = builtins.all (name: builtins.pathExists warp.vendoredThemes.${name}) (
      builtins.attrNames warp.vendoredThemes
    );
    expected = true;
  };

  testWarpGeneratedIdDoesNotCollideWithVendored = {
    expr = warp.vendoredThemes ? ${warp.generatedId};
    expected = false;
  };

  # ─── Deployment per active family ─────────────────────────────────────────

  testWarpCatppuccinDeploysVendoredOnly = {
    expr = let
      entries = entriesFor "catppuccin" "mocha";
    in {
      paths = builtins.attrNames entries;
      hasGenerated = entries ? "warp/themes/aytordev.yaml";
      hasMocha = entries ? "warp/themes/catppuccin_mocha.yaml";
    };
    expected = {
      paths = vendoredPaths;
      hasGenerated = false;
      hasMocha = true;
    };
  };

  testWarpSoraDeploysGenerated = {
    expr = let
      entries = entriesFor "sora" "dark";
    in {
      hasGenerated = entries ? "warp/themes/aytordev.yaml";
      generated = entries."warp/themes/aytordev.yaml";
      count = builtins.length (builtins.attrNames entries);
    };
    expected = {
      hasGenerated = true;
      generated = {
        text = "generated";
      };
      count = 8;
    };
  };

  testWarpKanagawaDeploysVendoredPlusGenerated = {
    expr = let
      entries = entriesFor "kanagawa" "dragon";
    in {
      hasVendoredDragon = entries ? "warp/themes/kanagawa_dragon.yaml";
      hasGenerated = entries ? "warp/themes/aytordev.yaml";
    };
    expected = {
      hasVendoredDragon = true;
      hasGenerated = true;
    };
  };

  testWarpVendoredEntryIsAPathOnDisk = {
    expr =
      builtins.pathExists
      (entriesFor "catppuccin" "mocha")."warp/themes/catppuccin_mocha.yaml".source;
    expected = true;
  };

  # ─── Generated YAML content ───────────────────────────────────────────────

  testWarpGeneratedYamlIsValidAndUsesPalette = let
    text = renderFor {
      family = "kanagawa";
      variant = "dragon";
    };
    palette = theme.providers.kanagawa.variants.dragon;
    ansi = theme.providers.kanagawa.ansi.dragon;
  in {
    expr = {
      name = lib.hasInfix "name: aytordev\n" text;
      background = lib.hasInfix "background: '${palette.bg.hex}'" text;
      accent = lib.hasInfix "accent: '${palette.accent.hex}'" text;
      foreground = lib.hasInfix "foreground: '${palette.fg.hex}'" text;
      details = lib.hasInfix "details: darker" text;
      normalHeader = lib.hasInfix "  normal:\n" text;
      brightHeader = lib.hasInfix "  bright:\n" text;
      allAnsi =
        builtins.all (
          name:
            lib.hasInfix "'${ansi.normal.${name}.hex}'" text && lib.hasInfix "'${ansi.bright.${name}.hex}'" text
        )
        warp.ansiOrder;
      trailingNewline = lib.hasSuffix "\n" text;
    };
    expected = {
      name = true;
      background = true;
      accent = true;
      foreground = true;
      details = true;
      normalHeader = true;
      brightHeader = true;
      allAnsi = true;
      trailingNewline = true;
    };
  };

  # An unquoted `#` would open a YAML comment and silently drop the color.
  testWarpGeneratedYamlQuotesEveryColor = {
    expr = let
      text = renderFor {
        family = "sora";
        variant = "light";
        isLight = true;
      };
    in {
      noBareHex = !(lib.hasInfix ": #" text);
      quotedBackground = lib.hasInfix "background: '#" text;
      quotedAnsi = lib.hasInfix "    red: '#" text;
    };
    expected = {
      noBareHex = true;
      quotedBackground = true;
      quotedAnsi = true;
    };
  };

  testWarpGeneratedDetailsFollowsPolarity = {
    expr = {
      dark = lib.hasInfix "details: darker" (renderFor {
        family = "sora";
        variant = "dark";
      });
      light = lib.hasInfix "details: lighter" (renderFor {
        family = "sora";
        variant = "light";
        isLight = true;
      });
    };
    expected = {
      dark = true;
      light = true;
    };
  };

  testWarpRenderDataMapsPaletteAndAnsi = let
    palette = theme.providers.sora.variants.light;
    ansi = theme.providers.sora.ansi.light;
    data = warp.renderData {
      inherit palette ansi;
      isLight = true;
    };
  in {
    expr = {
      inherit
        (data)
        name
        background
        accent
        foreground
        details
        ;
      normalRed = data.terminal_colors.normal.red;
      brightCyan = data.terminal_colors.bright.cyan;
    };
    expected = {
      name = "aytordev";
      background = palette.bg.hex;
      accent = palette.accent.hex;
      foreground = palette.fg.hex;
      details = "lighter";
      normalRed = ansi.normal.red.hex;
      brightCyan = ansi.bright.cyan.hex;
    };
  };

  # ─── The module stays disabled by default and adds no selection option ────

  testWarpEnableDefaultsToDisabled = {
    expr = warpOptions.enable.default;
    expected = false;
  };

  testWarpHasNoBogusSelectionOption = {
    expr = {
      theme = warpOptions ? theme;
      themeOverride = warpOptions ? themeOverride;
    };
    expected = {
      theme = false;
      themeOverride = false;
    };
  };
}
