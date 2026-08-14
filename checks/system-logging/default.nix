{
  inputs,
  lib,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  discoveredModules = extendedLib.importModulesRecursive ../../modules/darwin;
  loggingModules =
    builtins.filter (
      path: lib.hasInfix "/system/logging" (toString path)
    )
    discoveredModules;
  mkLoggingConfig = enable:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs.lib = extendedLib;
      modules = [
        {_module.args.lib = extendedLib;}
        ../../modules/darwin/system/logging
        {
          aytordev.system = {
            logging.enable = enable;
            newsyslog.files.test = [
              {
                logfilename = "/var/log/test.log";
                owner = "root";
                group = "wheel";
                count = 7;
                size = "2048";
                flags = [
                  "Z"
                  "C"
                ];
              }
            ];
          };
        }
      ];
    };
  disabledEtc = (mkLoggingConfig false).config.environment.etc;
  enabledEtc = (mkLoggingConfig true).config.environment.etc;
  generatedLog = enabledEtc."newsyslog.d/test.conf".text;
  tests = [
    (builtins.length loggingModules == 1)
    (!(disabledEtc ? "newsyslog.d/test.conf"))
    (lib.hasInfix "/var/log/test.log\troot:wheel\t644\t7\t2048\t*\tZC" generatedLog)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "system-logging-tests" {} ''
      touch "$out"
    ''
