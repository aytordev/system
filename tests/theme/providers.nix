{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig themeAssertionsHold;
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
      appThemeLight = theme.appThemeLight.capitalized;
      appThemeDark = theme.appThemeDark.capitalized;
    };
    expected = {
      name = "kanagawa";
      variant = "dragon";
      isLight = false;
      displayName = "Kanagawa";
      appThemeLight = "Kanagawa Lotus";
      appThemeDark = "Kanagawa Dragon";
    };
  };

  testThemeCatppuccinLatte = {
    expr = let
      theme = themeConfig {
        aytordev.theme = {
          name = "catppuccin";
          variant = "latte";
        };
      };
    in {
      inherit
        (theme)
        name
        variant
        isLight
        displayName
        ;
      accent = theme.palette.accent.hex;
      appTheme = theme.appTheme.capitalized;
      appThemeDark = theme.appThemeDark.capitalized;
      appThemeLight = theme.appThemeLight.capitalized;
    };
    expected = {
      name = "catppuccin";
      variant = "latte";
      isLight = true;
      displayName = "Catppuccin";
      accent = "#1e66f5";
      appTheme = "Catppuccin Latte";
      appThemeDark = "Catppuccin Mocha";
      appThemeLight = "Catppuccin Latte";
    };
  };

  testThemeExposesEveryProvider = {
    expr = builtins.attrNames (themeConfig {}).providers;
    expected = [
      "catppuccin"
      "kanagawa"
      "sora"
    ];
  };

  testThemeExposesEveryFamilyIntegrations = {
    expr = builtins.attrNames (themeConfig {}).integrations;
    expected = [
      "catppuccin"
      "kanagawa"
      "sora"
    ];
  };

  testThemeIntegrationsDeclareEveryNativeApp = {
    expr = let
      theme = themeConfig {};
    in {
      integrations = builtins.attrNames theme.providers.kanagawa.integrations;
      nativeApps = theme.providers.kanagawa.nativeApps;
    };
    expected = {
      integrations = [
        "bat"
        "ghostty"
        "vscode"
        "zed"
      ];
      nativeApps = [
        "bat"
        "ghostty"
        "vscode"
        "zed"
      ];
    };
  };

  testThemeNativeAppsAreDerivedFromIntegrations = {
    expr = let
      theme = themeConfig {aytordev.theme.name = "catppuccin";};
    in {
      activeNativeApps = theme.nativeApps;
      catppuccinNativeApps = theme.providers.catppuccin.nativeApps;
      integrationsMatch = builtins.attrNames theme.providers.catppuccin.integrations;
    };
    expected = {
      activeNativeApps = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "vscode"
        "warp"
        "yazi"
        "zed"
        "zellij"
      ];
      catppuccinNativeApps = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "vscode"
        "warp"
        "yazi"
        "zed"
        "zellij"
      ];
      integrationsMatch = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "vscode"
        "warp"
        "yazi"
        "zed"
        "zellij"
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
        nativeApps
        displayName
        ;
      accent = theme.palette.accent.hex;
      appTheme = theme.appTheme.capitalized;
      appThemeLight = theme.appThemeLight.capitalized;
      providerNativeApps = theme.providers.sora.nativeApps;
    };
    expected = {
      name = "sora";
      variant = "dark";
      isLight = false;
      nativeApps = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "yazi"
        "zed"
      ];
      displayName = "Sora";
      accent = "#80c8e0";
      appTheme = "Sora";
      appThemeLight = "Sora";
      providerNativeApps = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
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
      variants = builtins.attrNames theme.allVariantPalettes;
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
      kanagawa = theme.providers.kanagawa.nativeApps;
      catppuccin = theme.providers.catppuccin.nativeApps;
      sora = theme.providers.sora.nativeApps;
    };
    expected = {
      kanagawa = [
        "bat"
        "ghostty"
        "vscode"
        "zed"
      ];
      catppuccin = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
        "lazygit"
        "opencode"
        "starship"
        "tmux"
        "vscode"
        "warp"
        "yazi"
        "zed"
        "zellij"
      ];
      sora = [
        "bat"
        "btop"
        "eza"
        "firefox"
        "fzf"
        "ghostty"
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
      matches = theme.palette == theme.allVariantPalettes.${theme.variant};
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
      {aytordev.theme.name = "catppuccin";}
    ];
    expected = [
      true
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

  testThemeCatppuccinExposesEveryVariant = {
    expr = let
      theme = themeConfig {aytordev.theme.name = "catppuccin";};
      latte = themeConfig {
        aytordev.theme = {
          name = "catppuccin";
          variant = "latte";
        };
      };
    in {
      variants = builtins.attrNames theme.allVariantPalettes;
      inherit (theme.providers.catppuccin) darkVariant lightVariant;
      latteIsLight = latte.isLight;
      mochaIsLight = theme.isLight;
    };
    expected = {
      variants = [
        "frappe"
        "latte"
        "macchiato"
        "mocha"
      ];
      darkVariant = "mocha";
      lightVariant = "latte";
      latteIsLight = true;
      mochaIsLight = false;
    };
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
          name = "catppuccin";
          variant = "frappe";
        };
      };
    in {
      activeMatches = theme.palette == theme.allVariantPalettes.frappe;
      providerMatches = theme.palette == theme.providers.catppuccin.variants.frappe;
      transparent = theme.providers.catppuccin.variants.latte.transparent.sketchybar;
    };
    expected = {
      activeMatches = true;
      providerMatches = true;
      transparent = "0x00000000";
    };
  };

  testCatppuccinFrappeLabelIsAccented = {
    expr = let
      theme = themeConfig {
        aytordev.theme = {
          name = "catppuccin";
          variant = "frappe";
        };
      };
    in {
      appTheme = theme.appTheme.capitalized;
      zed = theme.providers.catppuccin.integrations.zed.variants.frappe.id;
      vscode = theme.providers.catppuccin.integrations.vscode.variants.frappe.id;
    };
    expected = {
      appTheme = "Catppuccin Frappé";
      zed = "Catppuccin Frappé";
      vscode = "Catppuccin Frappé";
    };
  };
}
