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

  testMkOptDefault = {
    expr = (module.mkOpt' lib.types.int 5).default;
    expected = 5;
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
