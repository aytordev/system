{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig activeThemePalette;

  chrome = import ../../modules/home/programs/desktop/browsers/firefox/chrome.nix {inherit lib;};

  theme = themeConfig {};
  activeAnsi = theme.ansi;
  inherit (theme) providers;

  renderFor = {
    family,
    variant,
    isLight ? false,
  }:
    chrome.render {
      palette = providers.${family}.variants.${variant};
      ansi = providers.${family}.ansi.${variant};
      inherit isLight;
    };

  # Evaluate the real module with the real theme module but a stubbed Home
  # Manager surface: `programs.firefox` is captured as opaque data, `pkgs` is
  # reduced to the one package the module resolves, and `home.homeDirectory` is
  # the only other external input the config body reads.
  evalFirefox = {
    family ? "kanagawa",
    variant ? "dragon",
  }: (lib.evalModules {
    specialArgs = {
      pkgs = {
        firefox = {
          type = "derivation";
          name = "firefox";
          outPath = "/nix/store/firefox-stub";
        };
      };
    };
    modules = [
      ../../modules/home/theme
      ({lib, ...}: {
        options = {
          assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [];
          };
          home.homeDirectory = lib.mkOption {
            type = lib.types.str;
            default = "/home/tester";
          };
          programs.firefox = lib.mkOption {type = lib.types.anything;};
        };
      })
      ../../modules/home/programs/desktop/browsers/firefox
      {
        aytordev.theme = {
          name = family;
          inherit variant;
        };
        aytordev.programs.desktop.browsers.firefox.enable = true;
      }
    ];
  });

  firefoxEval = evalFirefox {};
  firefox = firefoxEval.config.programs.firefox;
  profile = firefox.profiles.default;
  firefoxTheme = firefoxEval.config.aytordev.theme;
  firefoxOptions = firefoxEval.options.aytordev.programs.desktop.browsers.firefox;
in {
  # ─── Generated CSS carries the active palette and ANSI accents ───────────

  testFirefoxGeneratedChromeContainsActivePalette = {
    expr = let
      text = chrome.userChrome {
        palette = activeThemePalette;
        ansi = activeAnsi;
      };
    in
      map (hex: lib.hasInfix hex text) [
        activeThemePalette.bg.hex
        activeThemePalette.bg_dim.hex
        activeThemePalette.bg_float.hex
        activeThemePalette.fg.hex
        activeThemePalette.fg_dim.hex
        activeThemePalette.accent.hex
        activeThemePalette.border.hex
        activeThemePalette.selection.hex
      ];
    expected = [
      true
      true
      true
      true
      true
      true
      true
      true
    ];
  };

  testFirefoxGeneratedChromeContainsAnsiAccents = {
    expr = let
      text = renderFor {
        family = "kanagawa";
        variant = "dragon";
      };
      ansi = providers.kanagawa.ansi.dragon;
    in
      map (hex: lib.hasInfix hex text) [
        ansi.normal.yellow.hex
        ansi.normal.green.hex
        ansi.normal.red.hex
        ansi.normal.blue.hex
      ];
    expected = [
      true
      true
      true
      true
    ];
  };

  testFirefoxColorSchemeFollowsVariantPolarity = {
    expr = {
      dark = lib.hasInfix "color-scheme: dark;" (renderFor {
        family = "kanagawa";
        variant = "dragon";
      });
      light = lib.hasInfix "color-scheme: light;" (renderFor {
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

  # ─── Pre-existing rules survive and are emitted before the theme ─────────

  testFirefoxBaseRulesPreservedInUserChrome = {
    expr = let
      text = chrome.userChrome {
        palette = activeThemePalette;
        ansi = activeAnsi;
      };
    in {
      singleTab = lib.hasInfix "#tabbrowser-tabs[tabscount=\"1\"]" text;
      collapse = lib.hasInfix "visibility: collapse" text;
      minHeight = lib.hasInfix "--tab-min-height: 32px" text;
      radius = lib.hasInfix "--toolbarbutton-border-radius: 3px" text;
    };
    expected = {
      singleTab = true;
      collapse = true;
      minHeight = true;
      radius = true;
    };
  };

  testFirefoxUserChromeEmitsBaseBeforeGeneratedTheme = {
    expr = let
      text = chrome.userChrome {
        palette = activeThemePalette;
        ansi = activeAnsi;
      };
    in {
      startsWithBase = lib.hasPrefix chrome.base text;
      containsGenerated = lib.hasInfix "generated from the active palette" text;
      differsFromBase = text != chrome.base;
    };
    expected = {
      startsWithBase = true;
      containsGenerated = true;
      differsFromBase = true;
    };
  };

  # ─── Switching family or variant changes the generated colors ────────────

  testFirefoxSwitchingFamilyChangesColors = {
    expr = let
      kanagawa = renderFor {
        family = "kanagawa";
        variant = "dragon";
      };
      catppuccin = renderFor {
        family = "catppuccin";
        variant = "mocha";
      };
      kanagawaBg = providers.kanagawa.variants.dragon.bg.hex;
      catppuccinBg = providers.catppuccin.variants.mocha.bg.hex;
    in {
      differ = kanagawa != catppuccin;
      kanagawaHasOwnBg = lib.hasInfix kanagawaBg kanagawa;
      kanagawaLacksCatppuccinBg = !(lib.hasInfix catppuccinBg kanagawa);
      catppuccinHasOwnBg = lib.hasInfix catppuccinBg catppuccin;
    };
    expected = {
      differ = true;
      kanagawaHasOwnBg = true;
      kanagawaLacksCatppuccinBg = true;
      catppuccinHasOwnBg = true;
    };
  };

  testFirefoxSwitchingVariantChangesColors = {
    expr = let
      wave = renderFor {
        family = "kanagawa";
        variant = "wave";
      };
      dragon = renderFor {
        family = "kanagawa";
        variant = "dragon";
      };
    in {
      differ = wave != dragon;
      waveHasOwnBg = lib.hasInfix providers.kanagawa.variants.wave.bg.hex wave;
      dragonHasOwnBg = lib.hasInfix providers.kanagawa.variants.dragon.bg.hex dragon;
    };
    expected = {
      differ = true;
      waveHasOwnBg = true;
      dragonHasOwnBg = true;
    };
  };

  # ─── The module still deploys the exact same profile/settings/policies ───

  testFirefoxModuleDeploysProfilesSettingsAndPolicies = {
    expr = {
      profileId = profile.id;
      profileName = profile.name;
      inherit (profile) isDefault;
      settingsCount = builtins.length (builtins.attrNames profile.settings);
      tracked = profile.settings."privacy.trackingprotection.enabled";
      downloadDir = profile.settings."browser.download.dir";
      webrender = profile.settings."gfx.webrender.all";
      pocket = profile.settings."extensions.pocket.enabled";
      policyNames = builtins.attrNames firefox.policies;
      telemetry = firefox.policies.DisableTelemetry;
      trackingLocked = firefox.policies.EnableTrackingProtection.Locked;
      menuBar = firefox.policies.DisplayMenuBar;
    };
    expected = {
      profileId = 0;
      profileName = "default";
      isDefault = true;
      settingsCount = 50;
      tracked = true;
      downloadDir = "/home/tester/Downloads";
      webrender = true;
      pocket = false;
      policyNames = [
        "DisableAccounts"
        "DisableFirefoxAccounts"
        "DisableFirefoxScreenshots"
        "DisableFirefoxStudies"
        "DisablePocket"
        "DisableTelemetry"
        "DisplayBookmarksToolbar"
        "DisplayMenuBar"
        "DontCheckDefaultBrowser"
        "EnableTrackingProtection"
        "OverrideFirstRunPage"
        "OverridePostUpdatePage"
        "SearchBar"
      ];
      telemetry = true;
      trackingLocked = true;
      menuBar = "default-off";
    };
  };

  # ─── The deployed userChrome is the generated theme plus the base rules ───

  testFirefoxModuleUserChromeUsesActivePaletteAndBase = {
    expr = let
      text = profile.userChrome;
    in {
      paletteBg = lib.hasInfix firefoxTheme.palette.bg.hex text;
      paletteAccent = lib.hasInfix firefoxTheme.palette.accent.hex text;
      ansiYellow = lib.hasInfix firefoxTheme.ansi.normal.yellow.hex text;
      baseRule = lib.hasInfix "#tabbrowser-tabs[tabscount=\"1\"]" text;
      generated = lib.hasInfix "generated from the active palette" text;
    };
    expected = {
      paletteBg = true;
      paletteAccent = true;
      ansiYellow = true;
      baseRule = true;
      generated = true;
    };
  };

  # ─── No add-on/extension is installed; the surface stays enable/package ───

  testFirefoxModuleInstallsNoAddons = {
    expr = {
      profileExtensions = profile ? extensions;
      firefoxExtensions = firefox ? extensions;
      policyMentionsExtensions = lib.any (name: lib.hasInfix "Extension" name) (
        builtins.attrNames firefox.policies
      );
      optionNames = builtins.attrNames firefoxOptions;
      enableDefault = firefoxOptions.enable.default;
    };
    expected = {
      profileExtensions = false;
      firefoxExtensions = false;
      policyMentionsExtensions = false;
      optionNames = [
        "enable"
        "package"
      ];
      enableDefault = false;
    };
  };
}
