{
  self,
  lib,
}: let
  inherit (self.lib) file module;
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
in {
  testBoolToNumTrue = {
    expr = module.boolToNum true;
    expected = 1;
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

  testConfigurationDirectoriesRequireDefault = {
    expr = file.configurationDirectories ../checks/file-parsers/fixtures/systems-valid/aarch64-darwin;
    expected = ["wang-lin"];
  };

  testMkOptDefault = {
    expr = (module.mkOpt' lib.types.int 5).default;
    expected = 5;
  };

  testSystemBuilderInjectionArgs = {
    expr = map (name: builtins.hasAttr name (builtins.functionArgs self.lib.system.mkSystem)) [
      "matchingHomes"
      "nixosModules"
      "homeModules"
    ];
    expected = [
      true
      true
      true
    ];
  };

  testDarwinBuilderInjectionArgs = {
    expr = map (name: builtins.hasAttr name (builtins.functionArgs self.lib.system.mkDarwin)) [
      "matchingHomes"
      "darwinModules"
      "homeModules"
    ];
    expected = [
      true
      true
      true
    ];
  };

  testHomeBuilderInjectionArgs = {
    expr = builtins.hasAttr "homeModules" (builtins.functionArgs self.lib.system.mkHome);
    expected = true;
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
