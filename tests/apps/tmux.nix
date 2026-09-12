{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  tmux = import ../../modules/home/programs/terminal/tools/tmux/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    tmux.resolve {
      inherit variant override;
      integration = integrations.${family}.tmux or null;
    };

  # `variant` falls back to the family's dark variant for synthetic palettes.
  paletteFor = family: variant:
    theme.providers.${family}.variants.${variant}
      or theme.providers.${family}.variants.${theme.providers.${family}.darkVariant};

  materializeFor = family: variant: override:
    tmux.materialize {
      inherit family;
      resolution = resolveFor family variant override;
      palette = paletteFor family variant;
    };
in {
  # ─── Per-family resolution ────────────────────────────────────────────────

  testTmuxCatppuccinMochaResolvesOfficial = {
    expr = resolveFor "catppuccin" "mocha" null;
    expected = {
      kind = "official";
      id = "mocha";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testTmuxCatppuccinLatteResolvesOfficial = {
    expr = resolveFor "catppuccin" "latte" null;
    expected = {
      kind = "official";
      id = "latte";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testTmuxSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # Sora's conf is dark-only; the synthetic light variant must generate.
  testTmuxSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testTmuxKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testTmuxStringOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" "latte";
    expected = {
      kind = "explicit";
      id = "latte";
      source = "user";
    };
  };

  testTmuxManualOverrideWins = {
    expr = resolveFor "catppuccin" "mocha" {
      mode = "manual";
      id = "frappe";
    };
    expected = {
      kind = "explicit";
      id = "frappe";
      source = "user";
    };
  };

  # ─── Per-family materialization ───────────────────────────────────────────

  # Catppuccin loads the official plugin and sets the upstream flavor option.
  testTmuxCatppuccinMaterializesOfficialPluginAndFlavor = {
    expr = materializeFor "catppuccin" "mocha" null;
    expected = {
      pluginName = "catppuccin";
      extraConfig = "set -g @catppuccin_flavor 'mocha'";
    };
  };

  testTmuxCatppuccinOverridePinsFlavor = {
    expr = materializeFor "catppuccin" "mocha" "macchiato";
    expected = {
      pluginName = "catppuccin";
      extraConfig = "set -g @catppuccin_flavor 'macchiato'";
    };
  };

  # Sora sources the vendored official conf instead of loading a plugin.
  testTmuxSoraMaterializesSourcedOfficialConf = {
    expr = let
      artifacts = materializeFor "sora" "dark" null;
    in {
      inherit (artifacts) pluginName;
      sources = lib.hasPrefix "source-file " artifacts.extraConfig;
      namesConf = lib.hasInfix "sora.tmux.conf" artifacts.extraConfig;
    };
    expected = {
      pluginName = null;
      sources = true;
      namesConf = true;
    };
  };

  # Kanagawa has no upstream resource: the fallback is generated from the
  # active palette, not a plugin.
  testTmuxKanagawaMaterializesGeneratedPalette = {
    expr = let
      palette = paletteFor "kanagawa" "dragon";
      artifacts = materializeFor "kanagawa" "dragon" null;
    in {
      inherit (artifacts) pluginName;
      bg = lib.hasInfix palette.bg_dim.hex artifacts.extraConfig;
      fg = lib.hasInfix palette.fg.hex artifacts.extraConfig;
      accent = lib.hasInfix palette.accent.hex artifacts.extraConfig;
      border = lib.hasInfix palette.border.hex artifacts.extraConfig;
    };
    expected = {
      pluginName = null;
      bg = true;
      fg = true;
      accent = true;
      border = true;
    };
  };

  # ─── Opt-out emits no theme ───────────────────────────────────────────────

  testTmuxNoneOverrideEmitsNothing = {
    expr = materializeFor "catppuccin" "mocha" {mode = "none";};
    expected = {
      pluginName = null;
      extraConfig = "";
    };
  };

  testTmuxNoneDropsEvenAnOfficialResource = {
    expr = materializeFor "sora" "dark" {mode = "none";};
    expected = {
      pluginName = null;
      extraConfig = "";
    };
  };

  # ─── Generated/fallback config carries the active palette ─────────────────

  testTmuxGeneratedConfigCarriesPalette = {
    expr = let
      palette = theme.providers.catppuccin.variants.mocha;
      text = tmux.renderConfig {inherit palette;};
    in {
      bg = lib.hasInfix palette.bg_dim.hex text;
      fg = lib.hasInfix palette.fg.hex text;
      accent = lib.hasInfix palette.accent.hex text;
      selection = lib.hasInfix palette.selection.hex text;
      generatedHeader = lib.hasInfix "aytordev tmux theme" text;
    };
    expected = {
      bg = true;
      fg = true;
      accent = true;
      selection = true;
      generatedHeader = true;
    };
  };

  testTmuxGeneratedConfigFollowsActiveFamily = {
    expr = let
      palette = paletteFor "sora" "light";
      text = tmux.renderConfig {inherit palette;};
    in
      lib.hasInfix palette.accent.hex text;
    expected = true;
  };

  # ─── Theme composition ────────────────────────────────────────────────────

  # A sourced conf and the layout must stay on separate lines; otherwise the
  # layout comment is parsed as part of the `source-file` path.
  testTmuxSourcedConfIsSeparatedFromLayout = {
    expr = let
      themeExtraConfig = (materializeFor "sora" "dark" null).extraConfig;
      composed = tmux.composeExtraConfig {inherit themeExtraConfig;};
    in {
      newlineAfterSource = lib.hasInfix "sora.tmux.conf\n" composed;
      layoutFollowsSource = lib.hasInfix "sora.tmux.conf\n# --- Terminal & Key Handling ---" composed;
      statusTopStillPresent = lib.hasInfix "set -g status-position top" composed;
    };
    expected = {
      newlineAfterSource = true;
      layoutFollowsSource = true;
      statusTopStillPresent = true;
    };
  };

  # `none` emits no theme lines, only the preserved layout.
  testTmuxNoneCompositionIsOnlyLayout = {
    expr = tmux.composeExtraConfig {themeExtraConfig = "";};
    expected = tmux.staticConfig;
  };

  # ─── Theme-independent config is preserved ────────────────────────────────

  testTmuxStaticConfigPreservesKeybindingsAndTerminal = {
    expr = let
      config = tmux.staticConfig;
    in {
      terminalOverrides = lib.hasInfix "set -ga terminal-overrides" config;
      viCopy = lib.hasInfix "copy-mode-vi" config;
      splitH = lib.hasInfix "bind v split-window -h" config;
      splitV = lib.hasInfix "bind d split-window -v" config;
      paneNav = lib.hasInfix "bind h select-pane -L" config;
      scratchpad = lib.hasInfix "display-popup" config;
      escapeTime = lib.hasInfix "set -sg escape-time 0" config;
      history = lib.hasInfix "history-limit 50000" config;
      statusTop = lib.hasInfix "set -g status-position top" config;
    };
    expected = {
      terminalOverrides = true;
      viCopy = true;
      splitH = true;
      splitV = true;
      paneNav = true;
      scratchpad = true;
      escapeTime = true;
      history = true;
      statusTop = true;
    };
  };

  # The module still wires every pre-existing plugin; ukiyo is gone.
  testTmuxPluginConfigPreserved = {
    expr = let
      module = builtins.readFile ../../modules/home/programs/terminal/tools/tmux/default.nix;
    in {
      sensible = lib.hasInfix "{plugin = sensible;}" module;
      yank = lib.hasInfix "{plugin = yank;}" module;
      navigator = lib.hasInfix "{plugin = vim-tmux-navigator;}" module;
      resurrect = lib.hasInfix "{plugin = resurrect;}" module;
      continuum = lib.hasInfix "plugin = continuum;" module;
      floax = lib.hasInfix "plugin = tmux-floax;" module;
      sessionx = lib.hasInfix "plugin = tmux-sessionx;" module;
      whichKey = lib.hasInfix "plugin = tmux-which-key;" module;
      noUkiyo = !(lib.hasInfix "ukiyo" module);
    };
    expected = {
      sensible = true;
      yank = true;
      navigator = true;
      resurrect = true;
      continuum = true;
      floax = true;
      sessionx = true;
      whichKey = true;
      noUkiyo = true;
    };
  };

  # The vendored Sora conf must exist on disk at the pinned path.
  testTmuxSoraConfShipsOnDisk = {
    expr = builtins.pathExists ../../modules/home/programs/terminal/tools/tmux/sora.tmux.conf;
    expected = true;
  };

  # A malformed integration still surfaces through the shared resolver.
  testTmuxBrokenIntegrationThrows = {
    expr = throws (
      tmux.resolve {
        variant = "mocha";
        override = null;
        integration = {
          source = null;
          variants.mocha.id = "mocha";
        };
      }
    );
    expected = true;
  };
}
