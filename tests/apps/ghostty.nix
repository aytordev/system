{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  ghostty = import ../../modules/home/programs/terminal/emulators/ghostty/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    ghostty.resolve {
      inherit variant override;
      integration = integrations.${family}.ghostty or null;
    };

  renderFor = family: variant:
    ghostty.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  # Expected ANSI16 view of a variant's ANSI table, keyed "0".."15".
  expectedPalette = ansi:
    lib.genAttrs (map toString (lib.range 0 15)) (
      index: let
        i = lib.toInt index;
        group =
          if i < 8
          then ansi.normal
          else ansi.bright;
        name = builtins.elemAt ghostty.ansiOrder (lib.mod i 8);
      in
        group.${name}.hex
    );

  # Parse `palette = N=#rrggbb` lines back into an attrset keyed "0".."15".
  parsedPalette = text:
    builtins.listToAttrs (
      map (
        line: let
          payload = lib.removePrefix "palette = " line;
          parts = lib.splitString "=" payload;
        in {
          name = builtins.head parts;
          value = lib.last parts;
        }
      ) (builtins.filter (line: lib.hasPrefix "palette = " line) (lib.splitString "\n" text))
    );

  # First `key = value` line for a chrome setting.
  chromeValue = key: text: let
    line = lib.findFirst (candidate: lib.hasPrefix "${key} = " candidate) null (
      lib.splitString "\n" text
    );
  in
    if line == null
    then null
    else lib.removePrefix "${key} = " line;

  brokenIntegration = {
    source = null;
    variants = {
      light = {
        id = "broken-light";
      };
    };
  };
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testGhosttyKanagawaDragonResolvesOfficial = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "official";
      id = "kanagawa-dragon";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testGhosttySoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Sora light must generate, never reuse the dark resource ─────────────

  testGhosttySoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testGhosttySoraLightIsNotTheDarkOfficial = {
    expr = (resolveFor "sora" "light" null).id == "sora";
    expected = false;
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testGhosttyStringOverrideWins = {
    expr = resolveFor "sora" "dark" "kanagawa-wave";
    expected = {
      kind = "explicit";
      id = "kanagawa-wave";
      source = "user";
    };
  };

  testGhosttyManualOverrideWins = {
    expr = resolveFor "sora" "dark" {
      mode = "manual";
      id = "kanagawa-lotus";
    };
    expected = {
      kind = "explicit";
      id = "kanagawa-lotus";
      source = "user";
    };
  };

  testGhosttyNoneOverrideEmitsNothing = {
    expr = resolveFor "kanagawa" "dragon" {mode = "none";};
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testGhosttyBrokenIntegrationThrows = {
    expr = throws (
      ghostty.resolve {
        variant = "light";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };

  # ─── Generated conf schema ────────────────────────────────────────────────

  testGhosttyGeneratedConfPaletteMatchesAnsi = {
    expr = parsedPalette (renderFor "sora" "light");
    expected = expectedPalette theme.providers.sora.ansi.light;
  };

  testGhosttyGeneratedConfPaletteMatchesKanagawaDragon = {
    expr = parsedPalette (renderFor "kanagawa" "dragon");
    expected = expectedPalette theme.providers.kanagawa.ansi.dragon;
  };

  testGhosttyGeneratedConfBackgroundForeground = {
    expr = let
      text = renderFor "sora" "light";
    in {
      background = chromeValue "background" text;
      foreground = chromeValue "foreground" text;
    };
    expected = {
      background = theme.providers.sora.variants.light.bg.hex;
      foreground = theme.providers.sora.variants.light.fg.hex;
    };
  };

  # ─── Generated file is materialized only for a generated selection ────────

  testGhosttyGeneratedFileOnlyForGeneratedSelection = {
    expr = {
      generated = builtins.attrNames (
        ghostty.generatedFile {
          resolution = {
            kind = "generated";
            id = "aytordev";
          };
          text = "generated";
        }
      );
      official = builtins.attrNames (
        ghostty.generatedFile {
          resolution = {
            kind = "official";
            id = "sora";
          };
          text = "generated";
        }
      );
      none = builtins.attrNames (
        ghostty.generatedFile {
          resolution = {
            kind = "none";
            id = null;
          };
          text = "generated";
        }
      );
    };
    expected = {
      generated = ["ghostty/themes/aytordev.conf"];
      official = [];
      none = [];
    };
  };

  # ─── Shader + cosmetic artifacts are gated by enableThemes ────────────────

  testGhosttyXdgEntriesDeployThemesGeneratedAndShaders = {
    expr = builtins.attrNames (
      ghostty.xdgEntries {
        enableThemes = true;
        themeEntries = {
          "ghostty/themes/kanagawa-dragon.conf" = {};
        };
        generated = {
          "ghostty/themes/aytordev.conf" = {};
        };
        shaderEntries = {
          "ghostty/shaders/${ghostty.cursorShader}" = {};
        };
      }
    );
    expected = [
      "ghostty/shaders/cursor_smear.glsl"
      "ghostty/themes/aytordev.conf"
      "ghostty/themes/kanagawa-dragon.conf"
    ];
  };

  testGhosttyXdgEntriesDropCosmeticsWhenThemesDisabled = {
    expr = builtins.attrNames (
      ghostty.xdgEntries {
        enableThemes = false;
        themeEntries = {
          "ghostty/themes/kanagawa-dragon.conf" = {};
        };
        generated = {
          "ghostty/themes/aytordev.conf" = {};
        };
        shaderEntries = {
          "ghostty/shaders/${ghostty.cursorShader}" = {};
        };
      }
    );
    expected = [];
  };

  testGhosttyCursorShaderShipsOnDisk = {
    expr = builtins.pathExists ../../modules/home/programs/terminal/emulators/ghostty/shaders/cursor_smear.glsl;
    expected = true;
  };
}
