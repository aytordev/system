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

  componentAssertions = palette: text: {
    wraps = lib.hasInfix "themes {" text && lib.hasInfix "aytordev {" text;
    textColors =
      lib.hasInfix ''
        text_unselected {
              base "${palette.fg.hex}"
              background "${palette.bg.hex}"
              emphasis_0 "${palette.orange.hex}"
              emphasis_1 "${palette.cyan.hex}"
              emphasis_2 "${palette.green.hex}"
              emphasis_3 "${palette.violet.hex}"
      ''
      text;
    frameAccent = lib.hasInfix "frame_selected {\n      base \"${palette.accent.hex}\"" text;
    ribbonAccent = lib.hasInfix "ribbon_selected {\n      base \"${palette.bg.hex}\"\n      background \"${palette.accent.hex}\"" text;
    errorRed = lib.hasInfix "exit_code_error {\n      base \"${palette.red.hex}\"" text;
    multiplayerAccent = lib.hasInfix "multiplayer_user_colors {\n      player_1 \"${palette.accent.hex}\"" text;
    noLegacyBg = !(lib.hasInfix "\n    bg \"" text);
    noLegacyFg = !(lib.hasInfix "\n    fg \"" text);
  };

  expectedComponents = {
    wraps = true;
    textColors = true;
    frameAccent = true;
    ribbonAccent = true;
    errorRed = true;
    multiplayerAccent = true;
    noLegacyBg = true;
    noLegacyFg = true;
  };
in {
  testZellijSessionCommandsPreserveModesAndPackage = {
    expr = let
      text = (import ../../modules/home/programs/terminal/tools/zellij/session.nix {inherit lib;}).script {
        type = "derivation";
        name = "custom-zellij";
        outPath = "/nix/store/custom-zellij";
        meta.mainProgram = "custom-zellij";
      };
    in {
      defaultOpen = lib.hasInfix ''mode="''${1:-open}"'' text;
      basename = lib.hasInfix ''session_name="$(basename "$(pwd)")"'' text;
      # Compare every complete emitted argv template, not a matching fragment.
      # Quoting and extra/missing flags are significant; HM checks execute them.
      commands =
        builtins.filter (line: lib.hasPrefix "exec " line)
        (map lib.strings.trim (lib.splitString "\n" text));
    };
    expected = {
      defaultOpen = true;
      basename = true;
      commands = [
        ''exec /nix/store/custom-zellij/bin/custom-zellij -s "$session_name" options --default-cwd "$(pwd)"''
        ''exec /nix/store/custom-zellij/bin/custom-zellij a "$session_name"''
        ''exec /nix/store/custom-zellij/bin/custom-zellij attach --create "$session_name" options --default-cwd "$(pwd)"''
      ];
    };
  };

  # ─── Official resource selection per family/variant ───────────────────────

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
    expr = resolveFor "sora" "light" "default";
    expected = {
      kind = "explicit";
      id = "default";
      source = "user";
    };
  };

  testZellijManualOverrideWins = {
    expr = resolveFor "sora" "light" {
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

  # ─── Generated theme content follows the variant palette ──────────────────

  testZellijGeneratedThemeUsesVariantPalette = {
    expr = let
      palette = theme.providers.kanagawa.variants.dragon;
      text = renderFor "kanagawa" "dragon";
    in
      componentAssertions palette text;
    expected = expectedComponents;
  };

  testZellijGeneratedThemeFollowsActiveFamily = {
    expr = let
      palette = theme.providers.sora.variants.dark;
      text = renderFor "sora" "dark";
    in
      componentAssertions palette text;
    expected = expectedComponents;
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
      none = builtins.attrNames (
        zellij.themeFiles {
          resolution = {
            kind = "none";
            id = null;
          };
        }
      );
    };
    expected = {
      generated = ["aytordev"];
      none = [];
    };
  };

  testZellijBrokenIntegrationThrows = {
    expr = throws (
      zellij.resolve {
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
