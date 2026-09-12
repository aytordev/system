{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  btop = import ../../modules/home/programs/terminal/tools/btop/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    btop.resolve {
      inherit variant override;
      integration = integrations.${family}.btop or null;
    };

  renderFor = family: variant:
    btop.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  # Parse `theme[key]="#rrggbb"` lines into an attrset keyed by btop theme key.
  parsedTheme = text:
    builtins.listToAttrs (
      map (
        line: let
          inner = lib.removePrefix "theme[" line;
        in {
          name = builtins.elemAt (lib.splitString "]" inner) 0;
          value = builtins.elemAt (lib.splitString "\"" inner) 1;
        }
      ) (builtins.filter (line: lib.hasPrefix "theme[" line) (lib.splitString "\n" text))
    );

  # The complete btop `.theme` key set, in upstream order.
  themeKeys = [
    "main_bg"
    "main_fg"
    "title"
    "hi_fg"
    "selected_bg"
    "selected_fg"
    "inactive_fg"
    "graph_text"
    "meter_bg"
    "proc_misc"
    "cpu_box"
    "mem_box"
    "net_box"
    "proc_box"
    "div_line"
    "temp_start"
    "temp_mid"
    "temp_end"
    "cpu_start"
    "cpu_mid"
    "cpu_end"
    "free_start"
    "free_mid"
    "free_end"
    "cached_start"
    "cached_mid"
    "cached_end"
    "available_start"
    "available_mid"
    "available_end"
    "used_start"
    "used_mid"
    "used_end"
    "download_start"
    "download_mid"
    "download_end"
    "upload_start"
    "upload_mid"
    "upload_end"
    "process_start"
    "process_mid"
    "process_end"
  ];

  # Order-insensitive set comparison helper.
  sorted = builtins.sort (a: b: a < b);
in {
  # ─── Official selection per family/variant ────────────────────────────────

  testBtopCatppuccinResolvesOfficialPerVariant = {
    expr = map (variant: resolveFor "catppuccin" variant null) [
      "latte"
      "frappe"
      "macchiato"
      "mocha"
    ];
    expected = [
      {
        kind = "official";
        id = "catppuccin_latte";
        provenance = "official-upstream";
        variantProvenance = "official";
        source = "official";
      }
      {
        kind = "official";
        id = "catppuccin_frappe";
        provenance = "official-upstream";
        variantProvenance = "official";
        source = "official";
      }
      {
        kind = "official";
        id = "catppuccin_macchiato";
        provenance = "official-upstream";
        variantProvenance = "official";
        source = "official";
      }
      {
        kind = "official";
        id = "catppuccin_mocha";
        provenance = "official-upstream";
        variantProvenance = "official";
        source = "official";
      }
    ];
  };

  testBtopSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Kanagawa ships no btop resource, so it generates ─────────────────────

  testBtopKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testBtopKanagawaLotusResolvesGenerated = {
    expr = resolveFor "kanagawa" "lotus" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Sora light must generate, never reuse the dark resource ─────────────

  testBtopSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testBtopSoraLightIsNotTheSoraOfficial = {
    expr = (resolveFor "sora" "light" null).id == "sora";
    expected = false;
  };

  # ─── Theme source selected per resolution kind ───────────────────────────

  testBtopOfficialSelectionDeploysVendoredTheme = {
    expr = btop.themeSources {
      resolution = resolveFor "catppuccin" "mocha" null;
      generatedText = "generated";
    };
    expected = {
      catppuccin_mocha = ../../modules/home/programs/terminal/tools/btop/themes/catppuccin_mocha.theme;
    };
  };

  testBtopSoraOfficialSelectionDeploysVendoredTheme = {
    expr = btop.themeSources {
      resolution = resolveFor "sora" "dark" null;
      generatedText = "generated";
    };
    expected = {
      sora = ../../modules/home/programs/terminal/tools/btop/themes/sora.theme;
    };
  };

  testBtopGeneratedSelectionDeploysGeneratedTheme = {
    expr = btop.themeSources {
      resolution = resolveFor "kanagawa" "dragon" null;
      generatedText = "generated:dragon";
    };
    expected = {
      aytordev = "generated:dragon";
    };
  };

  testBtopNoneSelectionDeploysNothing = {
    expr = btop.themeSources {
      resolution = resolveFor "kanagawa" "dragon" {mode = "none";};
      generatedText = "generated";
    };
    expected = {};
  };

  # ─── Explicit override wins ──────────────────────────────────────────────

  testBtopStringOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" "sora";
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testBtopManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "catppuccin_latte";
    };
    expected = {
      kind = "explicit";
      id = "catppuccin_latte";
      source = "user";
    };
  };

  testBtopManualOverrideToGeneratedDeploysGeneratedTheme = {
    expr = btop.themeSources {
      resolution = resolveFor "catppuccin" "mocha" {
        mode = "manual";
        id = "aytordev";
      };
      generatedText = "generated";
    };
    expected = {
      aytordev = "generated";
    };
  };

  # ─── Existing settings survive, none keeps btop's default ────────────────

  testBtopSettingsPreserveBaseOptionsAndAddColorTheme = {
    expr = let
      base = {
        truecolor = true;
        theme_background = true;
        update_ms = 2000;
        graph_symbol = "braille";
      };
      result = btop.settings {
        inherit base;
        resolution = resolveFor "catppuccin" "mocha" null;
      };
    in {
      inherit
        (result)
        truecolor
        theme_background
        update_ms
        graph_symbol
        color_theme
        ;
    };
    expected = {
      truecolor = true;
      theme_background = true;
      update_ms = 2000;
      graph_symbol = "braille";
      color_theme = "catppuccin_mocha";
    };
  };

  testBtopGeneratedSettingsSelectGeneratedId = {
    expr =
      (btop.settings {
        base = {
          truecolor = true;
        };
        resolution = resolveFor "kanagawa" "dragon" null;
      }).color_theme;
    expected = "aytordev";
  };

  testBtopNoneSettingsKeepBaseWithoutColorTheme = {
    expr = let
      base = {
        truecolor = true;
        theme_background = false;
      };
      result = btop.settings {
        inherit base;
        resolution = resolveFor "kanagawa" "dragon" {mode = "none";};
      };
    in {
      inherit (result) truecolor theme_background;
      hasColorTheme = result ? color_theme;
    };
    expected = {
      truecolor = true;
      theme_background = false;
      hasColorTheme = false;
    };
  };

  # ─── Broken declarations stay loud ───────────────────────────────────────

  testBtopBrokenIntegrationThrows = {
    expr = throws (
      btop.resolve {
        variant = "dragon";
        override = null;
        integration = {
          source = null;
          variants.dragon.id = "broken";
        };
      }
    );
    expected = true;
  };

  # ─── Generated theme schema ──────────────────────────────────────────────

  testBtopGeneratedThemeCoversEveryKey = {
    expr = sorted (builtins.attrNames (parsedTheme (renderFor "kanagawa" "dragon")));
    expected = sorted themeKeys;
  };
  testBtopGeneratedThemeLineFormat = {
    expr = let
      lines = builtins.filter (line: line != "") (lib.splitString "\n" (renderFor "kanagawa" "dragon"));
      # `builtins.match` (POSIX ERE) rejects escaped brackets, so match the
      # bracket-free key/hex and assert the literal `theme[...]="#..."` frame
      # with plain string predicates.
      parts =
        builtins.all (
          line: let
            captured = builtins.match "theme.(.*).=\"(#[0-9a-fA-F]+)\"" line;
          in
            captured
            != null
            && builtins.match "[a-z_]+" (builtins.head captured) != null
            && lib.hasPrefix "theme[" line
            && lib.hasSuffix "\"" line
        )
        lines;
    in
      parts && builtins.length lines == 42;
    expected = true;
  };

  testBtopGeneratedThemeUsesPaletteAndAnsiColors = let
    parsed = parsedTheme (renderFor "kanagawa" "dragon");
    palette = theme.providers.kanagawa.variants.dragon;
    ansi = theme.providers.kanagawa.ansi.dragon;
  in {
    expr = {
      inherit
        (parsed)
        main_bg
        main_fg
        hi_fg
        selected_bg
        inactive_fg
        cpu_box
        mem_box
        net_box
        graph_text
        cpu_start
        cpu_mid
        cpu_end
        process_end
        ;
    };
    expected = {
      main_bg = palette.bg.hex;
      main_fg = palette.fg.hex;
      hi_fg = palette.accent.hex;
      selected_bg = palette.selection.hex;
      inactive_fg = palette.fg_dim.hex;
      cpu_box = palette.blue.hex;
      mem_box = palette.green.hex;
      net_box = palette.red.hex;
      graph_text = ansi.normal.white.hex;
      cpu_start = ansi.normal.cyan.hex;
      cpu_mid = ansi.normal.blue.hex;
      cpu_end = ansi.bright.blue.hex;
      process_end = palette.violet.hex;
    };
  };

  testBtopGeneratedThemeFollowsActiveVariant = let
    parsed = parsedTheme (renderFor "sora" "light");
    palette = theme.providers.sora.variants.light;
  in {
    expr = {
      inherit (parsed) main_bg;
    };
    expected = {
      main_bg = palette.bg.hex;
    };
  };

  # ─── Vendored official files are real themes for the declared ids ─────────

  testBtopVendoredOfficialThemesExist = {
    expr = builtins.all (name: builtins.pathExists btop.officialThemes.${name}) (
      builtins.attrNames btop.officialThemes
    );
    expected = true;
  };

  testBtopVendoredIdsCoverDeclaredIntegrations = {
    expr = let
      catppuccinIds = map (variant: integrations.catppuccin.btop.variants.${variant}.id) [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      soraId = integrations.sora.btop.variants.dark.id;
    in
      builtins.all (id: builtins.hasAttr id btop.officialThemes) (catppuccinIds ++ [soraId]);
    expected = true;
  };

  testBtopVendoredThemesDeclareMainBackground = {
    expr = builtins.all (
      name: lib.hasInfix "theme[main_bg]" (builtins.readFile btop.officialThemes.${name})
    ) (builtins.attrNames btop.officialThemes);
    expected = true;
  };
}
