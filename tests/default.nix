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
  claudeAuditCommand =
    (import ../modules/home/programs/terminal/tools/claude-code/hooks/pre-tool-audit.nix {})
    .PreToolUse;
  claudeAuditScript = (builtins.head (builtins.head claudeAuditCommand).hooks).command;
  warpModule = builtins.readFile ../modules/home/programs/terminal/emulators/warp/default.nix;
in {
  testBoolToNumTrue = {
    expr = module.boolToNum true;
    expected = 1;
  };

  testCapitalizeWord = {
    expr = module.capitalize "hello";
    expected = "Hello";
  };

  testClaudeAuditExcludesToolInput = {
    expr = lib.hasInfix ".tool_input" claudeAuditScript;
    expected = false;
  };

  testClaudeAuditUsesPrivatePermissions = {
    expr = lib.hasInfix "umask 077" claudeAuditScript && lib.hasInfix "chmod 600" claudeAuditScript;
    expected = true;
  };

  testClaudeAuditLimitsRetention = {
    expr = lib.hasInfix "tail -n 1000" claudeAuditScript;
    expected = true;
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
