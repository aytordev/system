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

  # Import every top-level suite file in a partition directory. Support files
  # live under `<dir>/fixtures/` (a subdirectory), so future app tasks can add
  # test files without editing this aggregator.
  importTestFiles = dir:
    file.mergeAttrs (
      map (name: import (dir + "/${name}") {inherit self lib;}) (file.getNixFiles dir)
    );
in
  {
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
  }
  // importTestFiles ./theme
  // importTestFiles ./apps
