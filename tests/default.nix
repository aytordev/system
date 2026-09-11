{
  self,
  lib,
}: let
  inherit (self.lib) file identity module;
  evaluateGeneratedModule = enable:
    (lib.evalModules {
      modules = [
        (module.mkModule {
          name = "example";
          description = "example module";
          options.message = lib.mkOption {
            type = lib.types.str;
            default = "default";
          };
          config.testResult = "applied";
        })
        ({lib, ...}: {
          options.testResult = lib.mkOption {
            type = lib.types.str;
            default = "disabled";
          };
          config.aytordev.example = {
            inherit enable;
            message = "custom";
          };
        })
      ];
    }).config;
  archetypes = lib.evalModules {
    modules = [
      ../modules/darwin/archetypes/personal
      ../modules/darwin/archetypes/workstation
      {
        options.aytordev.suites = {
          business.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          common.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          desktop.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          music.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          networking.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          development = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            dockerEnable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            podmanEnable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            aiEnable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        };
      }
      {
        aytordev = {
          archetypes.personal.enable = true;
          archetypes.workstation.enable = true;
          suites = {
            common.enable = false;
            music.enable = false;
            development.podmanEnable = false;
          };
        };
      }
    ];
  };
  runAsServiceModule = builtins.readFile ../modules/home/programs/terminal/tools/run-as-service/default.nix;
  warpModule = builtins.readFile ../modules/home/programs/terminal/emulators/warp/default.nix;

  themeLib = import ../modules/home/theme/lib.nix {inherit lib;};
  evalTheme = extra:
    lib.evalModules {
      modules = [
        ../modules/home/theme
        {
          options.assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [];
          };
        }
        extra
      ];
    };
  themeConfig = extra: (evalTheme extra).config.aytordev.theme;
  themeAssertionsHold = extra: builtins.all (assertion: assertion.assertion) (evalTheme extra).config.assertions;
  activeThemePalette = (themeConfig {}).palette;
  yaziFlavor = import ../modules/home/programs/terminal/tools/yazi/flavor.nix {
    palette = activeThemePalette;
  };
  piTheme = import ../modules/home/programs/terminal/tools/pi/theme.nix {
    palette = activeThemePalette;
  };
in {
  testBoolToNumTrue = {
    expr = module.boolToNum true;
    expected = 1;
  };

  testArchetypesAllowHostOverrides = {
    expr = {
      inherit (archetypes.config.aytordev.suites) common music;
      inherit (archetypes.config.aytordev.suites.development) podmanEnable;
    };
    expected = {
      common.enable = false;
      music.enable = false;
      podmanEnable = false;
    };
  };

  testCapitalizeWord = {
    expr = module.capitalize "hello";
    expected = "Hello";
  };

  testMergeAttrs = {
    expr = file.mergeAttrs [
      {
        a = 1;
        b = 1;
      }
      {
        b = 2;
        c = 3;
      }
    ];
    expected = {
      a = 1;
      b = 2;
      c = 3;
    };
  };

  testRunAsServicePreservesArgumentBoundaries = {
    expr = lib.hasInfix "bash -lc" runAsServiceModule;
    expected = false;
  };

  testRunAsServiceUsesHomeManagerEnvironment = {
    expr = lib.hasInfix "sessionVariablesPackage" runAsServiceModule;
    expected = true;
  };

  testWarpHasNoDestructiveMigration = {
    expr = lib.hasInfix "rm -rf" warpModule;
    expected = false;
  };

  testConfigurationDirectoriesRequireDefault = {
    expr = file.configurationDirectories ../checks/file-parsers/fixtures/systems-valid/aarch64-darwin;
    expected = ["wang-lin"];
  };

  testGetNixFilesOnlyReturnsFiles = {
    expr = file.getNixFiles ./fixtures/nix-files;
    expected = ["regular.nix"];
  };

  testImportDirPlainIgnoresNixDirectories = {
    expr = file.importDirPlain ./fixtures/nix-files [];
    expected = {
      regular = true;
    };
  };

  testIdentityFromSecrets = {
    expr = identity.fromSecrets {
      username = "test-user";
      useremail = "test@example.test";
      userfullname = "Test User";
    };
    expected = {
      username = "test-user";
      email = "test@example.test";
      fullName = "Test User";
    };
  };

  testIdentityFromSecretsForUsersMap = {
    expr = identity.fromSecretsFor "avicente" {
      username = "aytordev";
      users.avicente = {
        username = "avicente";
        useremail = "avicente@example.test";
        userfullname = "Avicente User";
      };
    };
    expected = {
      username = "avicente";
      email = "avicente@example.test";
      fullName = "Avicente User";
    };
  };

  testIdentityFromSecretsForOwnerFallsBackToFlat = {
    expr = identity.fromSecretsFor "aytordev" {
      username = "aytordev";
      useremail = "owner@example.test";
      userfullname = "Owner User";
    };
    expected = {
      username = "aytordev";
      email = "owner@example.test";
      fullName = "Owner User";
    };
  };

  testIdentityFromSecretsForUnknownUserRejected = {
    expr =
      (builtins.tryEval (
        identity.fromSecretsFor "ghost" {
          username = "aytordev";
          users.aytordev = {
            username = "aytordev";
            useremail = "owner@example.test";
            userfullname = "Owner User";
          };
        }
      )).success;
    expected = false;
  };

  testIdentityFromSecretsForRejectsInvalidUserFields = {
    expr =
      (builtins.tryEval (
        identity.fromSecretsFor "avicente" {
          username = "aytordev";
          users.avicente = {
            username = "avicente";
            useremail = "";
            userfullname = "Avicente User";
          };
        }
      )).success;
    expected = false;
  };

  testIdentityRejectsInvalidSecrets = {
    expr = map (secrets: (builtins.tryEval (identity.fromSecrets secrets)).success) [
      {
        useremail = "test@example.test";
        userfullname = "Test User";
      }
      {
        username = 1;
        useremail = "test@example.test";
        userfullname = "Test User";
      }
      {
        username = "test-user";
        useremail = "";
        userfullname = "Test User";
      }
      {
        username = "test-user";
        useremail = "test@example.test";
        userfullname = [];
      }
    ];
    expected = [
      false
      false
      false
      false
    ];
  };

  testIdentityUsernameMatches = {
    expr = identity.assertUsername "test-user" "test-user";
    expected = "test-user";
  };

  testIdentityUsernameMismatch = {
    expr = (builtins.tryEval (identity.assertUsername "canonical-user" "directory-user")).success;
    expected = false;
  };

  testMkOptDefault = {
    expr = (module.mkOpt' lib.types.int 5).default;
    expected = 5;
  };

  testSystemBuilderInjectionArgs = {
    expr = map (name: builtins.hasAttr name (builtins.functionArgs self.lib.system.mkSystem)) [
      "extraSpecialArgs"
      "hostModule"
      "matchingHomes"
      "nixosModules"
      "homeModules"
    ];
    expected = [
      true
      true
      true
      true
      true
    ];
  };

  testDarwinBuilderInjectionArgs = {
    expr = map (name: builtins.hasAttr name (builtins.functionArgs self.lib.system.mkDarwin)) [
      "extraSpecialArgs"
      "hostModule"
      "matchingHomes"
      "darwinModules"
      "homeModules"
    ];
    expected = [
      true
      true
      true
      true
      true
    ];
  };

  testHomeBuilderInjectionArgs = {
    expr = map (name: builtins.hasAttr name (builtins.functionArgs self.lib.system.mkHome)) [
      "extraSpecialArgs"
      "homeModules"
    ];
    expected = [
      true
      true
    ];
  };

  testBuilderUsernameRequired = {
    expr = map (builder: (builtins.functionArgs builder).username) [
      self.lib.system.mkSystem
      self.lib.system.mkDarwin
      self.lib.system.mkHome
    ];
    expected = [
      false
      false
      false
    ];
  };

  testEnablePreservesImports = {
    expr = (module.enable "primary" {imports = ["additional"];}).imports;
    expected = [
      "primary"
      "additional"
    ];
  };

  testGeneratedModuleDisabled = {
    expr = (evaluateGeneratedModule false).testResult;
    expected = "disabled";
  };

  testGeneratedModuleEnabled = {
    expr = (evaluateGeneratedModule true).testResult;
    expected = "applied";
  };

  testGeneratedModuleCustomOptions = {
    expr = (evaluateGeneratedModule true).aytordev.example.message;
    expected = "custom";
  };

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
    ];
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

  testMkColorOpaque = {
    expr = themeLib.mkColor "#dcd7ba";
    expected = {
      hex = "#dcd7ba";
      raw = "dcd7ba";
      rgb = "rgb(220, 215, 186)";
      sketchybar = "0xffdcd7ba";
    };
  };

  testMkColorAlphaReordersSketchybarChannel = {
    expr = themeLib.mkColor "#12345678";
    expected = {
      hex = "#12345678";
      raw = "12345678";
      rgb = "rgba(18, 52, 86, 0.470588)";
      sketchybar = "0x78123456";
    };
  };

  testTransparentMatchesMkColor = {
    expr = themeLib.transparent == themeLib.mkColor "#00000000";
    expected = true;
  };

  testMkColorRejectsMalformedInput = {
    expr = map (value: (builtins.tryEval (builtins.deepSeq (themeLib.mkColor value) true)).success) [
      "#123"
      "123456"
      "#12345g"
      "#123456789"
    ];
    expected = [
      false
      false
      false
      false
    ];
  };

  testValidateProviderAcceptsKanagawa = {
    expr =
      (themeLib.validateProvider (
        import ../modules/home/theme/kanagawa/provider.nix {
          inherit (themeLib) mkColor transparent capitalize;
        }
      )).name;
    expected = "kanagawa";
  };

  testValidateProviderRejectsMissingContract = {
    expr =
      (builtins.tryEval (builtins.deepSeq (themeLib.validateProvider {name = "broken";}) true)).success;
    expected = false;
  };

  testValidateProviderRejectsUnknownVariantReference = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider {
          name = "broken";
          displayName = "Broken";
          defaultVariant = "missing";
          darkVariant = "missing";
          lightVariant = "missing";
          variants = {};
          appTheme = _: {};
        })
        true
      )).success;
    expected = false;
  };

  testValidateProviderRejectsInconsistentPolarity = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider {
          name = "broken";
          displayName = "Broken";
          defaultVariant = "dark";
          darkVariant = "dark";
          lightVariant = "light";
          variants = {
            dark = {
              isLight = true;
            };
            light = {
              isLight = true;
            };
          };
          appTheme = _: {};
        })
        true
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

  testYaziFlavorCoversAllSections = {
    expr = map (section: lib.hasInfix section yaziFlavor) [
      "[mgr]"
      "[tabs]"
      "[mode]"
      "[status]"
      "[pick]"
      "[input]"
      "[cmp]"
      "[tasks]"
      "[which]"
      "[help]"
      "[spot]"
      "[notify]"
      "[filetype]"
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
      true
      true
      true
      true
      true
    ];
  };

  testYaziFlavorHasNoUnresolvedInterpolationOrNulls = {
    expr = {
      hasPlaceholder = lib.hasInfix "\${" yaziFlavor;
      hasNull = lib.hasInfix "null" yaziFlavor;
    };
    expected = {
      hasPlaceholder = false;
      hasNull = false;
    };
  };

  testYaziFlavorUsesActiveFamilyAccent = {
    expr = let
      inherit ((themeConfig {aytordev.theme.name = "catppuccin";})) palette;
      flavor = import ../modules/home/programs/terminal/tools/yazi/flavor.nix {inherit palette;};
    in
      lib.hasInfix palette.accent.hex flavor;
    expected = true;
  };

  testPiThemeIsValidJsonFollowingPalette = {
    expr = let
      parsed = builtins.fromJSON (builtins.toJSON piTheme);
    in {
      inherit (parsed) name;
      accent = parsed.vars.accent;
      hasColors = parsed.colors ? accent;
      hasExport = parsed.export ? pageBg;
    };
    expected = {
      name = "aytordev";
      accent = activeThemePalette.accent.hex;
      hasColors = true;
      hasExport = true;
    };
  };

  testPiThemeFollowsActiveFamily = {
    expr = let
      inherit ((themeConfig {aytordev.theme.name = "catppuccin";})) palette;
    in
      (import ../modules/home/programs/terminal/tools/pi/theme.nix {inherit palette;}).vars.bg;
    expected = "#1e1e2e";
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
}
