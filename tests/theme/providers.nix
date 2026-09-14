{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig themeAssertionsHold throws;
in {
  testThemeDefaultIsKanagawaDragon = {
    expr = let
      theme = themeConfig {};
    in {
      inherit
        (theme)
        name
        variant
        isLight
        displayName
        ;
    };
    expected = {
      name = "kanagawa";
      variant = "dragon";
      isLight = false;
      displayName = "Kanagawa";
    };
  };

  testThemeExposesEveryProvider = {
    expr = builtins.attrNames (themeConfig {}).providers;
    expected = [
      "kanagawa"
      "sora"
    ];
  };

  testThemeExposesEveryFamilyIntegrations = {
    expr = builtins.attrNames (themeConfig {}).integrations;
    expected = [
      "kanagawa"
      "sora"
    ];
  };

  testThemeIntegrationsDeclareEveryNativeApp = {
    expr = let
      theme = themeConfig {};
    in
      builtins.attrNames theme.providers.kanagawa.integrations;
    expected = [
      "bat"
      "ghostty"
      "vscode"
      "zed"
    ];
  };

  testThemeIntegrationsArePerFamily = {
    expr = let
      theme = themeConfig {aytordev.theme.name = "sora";};
    in {
      matches =
        builtins.attrNames theme.integrations.sora == builtins.attrNames theme.providers.sora.integrations;
      sora = builtins.attrNames theme.providers.sora.integrations;
    };
    expected = {
      matches = true;
      sora = [
        "bat"
        "btop"
        "delta"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "hunk"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "yazi"
        "zed"
      ];
    };
  };

  # Every declared integration must carry a pinned provenance reference; a
  # vendored integration must additionally pin each artifact with an SRI hash.
  # Both tests derive their expectation from the live registry, so adding an
  # integration never leaves a stale hardcoded count behind.
  testEveryIntegrationHasProvenanceAndPinnedRev = let
    theme = themeConfig {};
    integrationsOf = provider: builtins.attrValues provider.integrations;
    allIntegrations = lib.concatLists (map integrationsOf (builtins.attrValues theme.providers));
  in {
    expr =
      map (
        integration: let
          inherit (integration) source;
        in {
          hasProvenance =
            source ? provenance
            && builtins.elem source.provenance [
              "official-upstream"
              "community-port"
            ];
          hasUrl = (source.ref.url or "") != "";
          hasRev = (source.ref.rev or "") != "";
        }
      )
      allIntegrations;
    expected = builtins.genList (_: {
      hasProvenance = true;
      hasUrl = true;
      hasRev = true;
    }) (builtins.length allIntegrations);
  };

  testEveryVendoredIntegrationPinsEveryArtifact = let
    theme = themeConfig {};
    vendoredOf = provider:
      builtins.filter (i: i.source.vendored or false) (builtins.attrValues provider.integrations);
    allVendored = lib.concatMap vendoredOf (builtins.attrValues theme.providers);
    checks =
      # A vendored integration must pin its artifact with a source-level hash.
      # Per-variant hashes are optional (they add precision only when the
      # vendored resource is split per variant).
      map (integration: (integration.source.ref.hash or "") != "") allVendored;
  in {
    expr = checks;
    expected = builtins.genList (_: true) (builtins.length checks);
  };

  testSoraGhosttyIntegrationIsDarkOnly = {
    expr = let
      integration = (themeConfig {}).providers.sora.integrations.ghostty;
    in {
      inherit (integration) complete;
      variants = builtins.attrNames integration.variants;
      darkId = integration.variants.dark.id;
    };
    expected = {
      complete = false;
      variants = ["dark"];
      darkId = "sora";
    };
  };

  testSoraProviderDefaults = {
    expr = let
      theme = themeConfig {aytordev.theme.name = "sora";};
    in {
      inherit
        (theme)
        name
        variant
        isLight
        displayName
        ;
      accent = theme.palette.accent.hex;
      providerIntegrations = builtins.attrNames theme.providers.sora.integrations;
    };
    expected = {
      name = "sora";
      variant = "dark";
      isLight = false;
      displayName = "Sora";
      accent = "#80c8e0";
      providerIntegrations = [
        "bat"
        "btop"
        "delta"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "hunk"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "yazi"
        "zed"
      ];
    };
  };

  testSoraSyntheticLightVariant = {
    expr = let
      theme = themeConfig {
        aytordev.theme = {
          name = "sora";
          variant = "light";
        };
      };
    in {
      inherit (theme) isLight;
      bg = theme.palette.bg.hex;
      fg = theme.palette.fg.hex;
      variants = builtins.attrNames theme.providers.${theme.name}.variants;
    };
    expected = {
      isLight = true;
      bg = "#eef1f7";
      fg = "#2a3242";
      variants = [
        "dark"
        "light"
      ];
    };
  };

  testNativeAppsArePerFamily = {
    expr = let
      theme = themeConfig {};
    in {
      kanagawa = builtins.attrNames theme.providers.kanagawa.integrations;
      sora = builtins.attrNames theme.providers.sora.integrations;
    };
    expected = {
      kanagawa = [
        "bat"
        "ghostty"
        "vscode"
        "zed"
      ];
      sora = [
        "bat"
        "btop"
        "delta"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "hunk"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "yazi"
        "zed"
      ];
    };
  };

  testThemeActivePaletteMatchesVariant = {
    expr = let
      theme = themeConfig {aytordev.theme.variant = "wave";};
    in {
      matches = theme.palette == theme.providers.${theme.name}.variants.${theme.variant};
      transparent = theme.palette.transparent.sketchybar;
    };
    expected = {
      matches = true;
      transparent = "0x00000000";
    };
  };

  testThemeRejectsUnknownVariant = {
    expr = themeAssertionsHold {aytordev.theme.variant = "does-not-exist";};
    expected = false;
  };

  testThemeAcceptsEveryVariant = {
    expr = map themeAssertionsHold [
      {aytordev.theme.variant = "wave";}
      {aytordev.theme.variant = "dragon";}
      {aytordev.theme.variant = "lotus";}
    ];
    expected = [
      true
      true
      true
    ];
  };

  testThemeComputedOptionsAreReadOnly = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeConfig {aytordev.theme.palette.accent.hex = "#ffffff";}) true
      )).success;
    expected = false;
  };

  testKanagawaDragonBrightYellowStaysBrighterThanYellow = {
    expr = let
      theme = themeConfig {aytordev.theme.variant = "dragon";};
    in {
      yellow = theme.palette.yellow.hex;
      yellow_bright = theme.palette.yellow_bright.hex;
    };
    expected = {
      yellow = "#c4b28a";
      yellow_bright = "#e6c384";
    };
  };

  testThemeProvidersAgreeWithComputedPalette = {
    expr = let
      theme = themeConfig {
        aytordev.theme = {
          name = "sora";
          variant = "dark";
        };
      };
    in {
      activeMatches = theme.palette == theme.providers.${theme.name}.variants.dark;
      providerMatches = theme.palette == theme.providers.sora.variants.dark;
      transparent = theme.providers.sora.variants.dark.transparent.sketchybar;
    };
    expected = {
      activeMatches = true;
      providerMatches = true;
      transparent = "0x00000000";
    };
  };

  # Regression: Catppuccin is retired; selecting it must be rejected like any
  # other unknown family (the `name` enum no longer lists it).
  testThemeRejectsRemovedCatppuccinFamily = {
    expr = throws (themeConfig {
      aytordev.theme.name = "catppuccin";
    });
    expected = true;
  };
}
