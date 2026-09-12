{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  fzf = import ../../modules/home/programs/terminal/tools/fzf/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    fzf.resolve {
      inherit variant override;
      integration = integrations.${family}.fzf or null;
    };

  colorsFor = family: variant: override:
    fzf.colorsFor {
      resolution = resolveFor family variant override;
      palette = theme.providers.${family}.variants.${variant};
    };

  kanagawaDragon = theme.providers.kanagawa.variants.dragon;

  brokenIntegration = {
    source = null;
    variants.mocha.id = "catppuccin-fzf-mocha";
  };
in {
  # ─── Official selection per family/variant ────────────────────────────────

  testFzfSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testFzfCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "catppuccin-fzf-mocha";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testFzfCatppuccinResolvesOfficialPerFlavor = {
    expr = map (variant: (resolveFor "catppuccin" variant null).id) [
      "latte"
      "frappe"
      "macchiato"
      "mocha"
    ];
    expected = [
      "catppuccin-fzf-latte"
      "catppuccin-fzf-frappe"
      "catppuccin-fzf-macchiato"
      "catppuccin-fzf-mocha"
    ];
  };

  testFzfOfficialCatppuccinColorsMatchUpstream = {
    expr = let
      colors = colorsFor "catppuccin" "mocha" null;
    in {
      inherit
        (colors)
        bg
        info
        marker
        border
        ;
      selectedBg = colors."selected-bg";
    };
    expected = {
      bg = "#1E1E2E";
      info = "#CBA6F7";
      marker = "#B4BEFE";
      border = "#6C7086";
      selectedBg = "#45475A";
    };
  };

  testFzfOfficialSoraColorsMatchUpstream = {
    expr = let
      colors = colorsFor "sora" "dark" null;
    in {
      inherit (colors) bg hl prompt;
      fgPlus = colors."fg+";
    };
    expected = {
      bg = "#0e1018";
      hl = "#80c8e0";
      prompt = "#b0a0d8";
      fgPlus = "#dce4f0";
    };
  };

  # ─── Families/variants without a covering resource generate ───────────────

  testFzfKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testFzfSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Generated map follows the variant palette ────────────────────────────

  testFzfGeneratedColorsMatchPalette = {
    expr = colorsFor "kanagawa" "dragon" null;
    expected = {
      bg = kanagawaDragon.bg.hex;
      "bg+" = kanagawaDragon.bg_dim.hex;
      fg = kanagawaDragon.fg.hex;
      "fg+" = kanagawaDragon.fg_reverse.hex;
      hl = kanagawaDragon.red.hex;
      "hl+" = kanagawaDragon.red_bright.hex;
      header = kanagawaDragon.red.hex;
      info = kanagawaDragon.accent.hex;
      prompt = kanagawaDragon.accent.hex;
      pointer = kanagawaDragon.fg_dim.hex;
      marker = kanagawaDragon.accent_dim.hex;
      spinner = kanagawaDragon.fg_dim.hex;
      gutter = kanagawaDragon.bg.hex;
      "selected-bg" = kanagawaDragon.selection.hex;
      border = kanagawaDragon.border.hex;
      label = kanagawaDragon.fg.hex;
    };
  };

  testFzfGeneratedColorsFollowActiveFamily = {
    expr = (colorsFor "sora" "light" null).info;
    expected = theme.providers.sora.variants.light.accent.hex;
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testFzfStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "catppuccin-fzf-mocha";
    expected = {
      kind = "explicit";
      id = "catppuccin-fzf-mocha";
      source = "user";
    };
  };

  testFzfManualOverrideWins = {
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

  testFzfOverrideSelectsVendoredColors = {
    expr = (colorsFor "kanagawa" "dragon" "sora").bg;
    expected = "#0e1018";
  };

  testFzfUnknownOverrideEmitsNoColors = {
    expr = colorsFor "kanagawa" "dragon" "does-not-exist";
    expected = {};
  };

  # ─── Opt-out emits no colors ──────────────────────────────────────────────

  testFzfNoneOverrideResolvesNone = {
    expr = resolveFor "catppuccin" "mocha" {mode = "none";};
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testFzfNoneOverrideEmitsNoColors = {
    expr = colorsFor "catppuccin" "mocha" {mode = "none";};
    expected = {};
  };

  # ─── Composition preserves the caller's settings ──────────────────────────

  testFzfSettingsPreserveBaseOptions = {
    expr = let
      base = {
        defaultOptions = [
          "--layout=reverse"
          "--exact"
          "--bind=alt-p:toggle-preview,alt-a:select-all"
        ];
        defaultCommand = "fd --type=f --hidden";
      };
      result = fzf.settings {
        inherit base;
        resolution = resolveFor "kanagawa" "dragon" null;
        palette = kanagawaDragon;
      };
    in {
      inherit (result) defaultOptions defaultCommand;
      hasColors = result.colors != {};
      colorsMatch = result.colors == fzf.generatedColors {palette = kanagawaDragon;};
    };
    expected = {
      defaultOptions = [
        "--layout=reverse"
        "--exact"
        "--bind=alt-p:toggle-preview,alt-a:select-all"
      ];
      defaultCommand = "fd --type=f --hidden";
      hasColors = true;
      colorsMatch = true;
    };
  };

  # ─── Broken declarations stay loud ────────────────────────────────────────

  testFzfBrokenIntegrationThrows = {
    expr = throws (
      fzf.resolve {
        variant = "mocha";
        override = null;
        integration = brokenIntegration;
      }
    );
    expected = true;
  };
}
