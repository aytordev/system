{
  inputs,
  pkgs,
  ...
}: let
  fileLib = import ../../libraries/file {
    inherit inputs;
    self = ../..;
  };

  evaluates = value: (builtins.tryEval (builtins.deepSeq value true)).success;
  expect = condition: message:
    if condition
    then true
    else throw message;

  validSystems = fileLib.parseSystemConfigurations ./fixtures/systems-valid;
  validHomes = fileLib.parseHomeConfigurations ./fixtures/homes-valid;

  tests = [
    (expect (
      builtins.attrNames validSystems == ["wang-lin"]
    ) "valid system configuration was not discovered")
    (expect (validSystems.wang-lin.system == "aarch64-darwin") "system metadata was parsed incorrectly")
    (expect (
      builtins.attrNames validHomes == ["aytordev@wang-lin"]
    ) "valid home configuration was not discovered")
    (expect (
      validHomes."aytordev@wang-lin".username == "aytordev"
    ) "home username was parsed incorrectly")
    (expect (
      validHomes."aytordev@wang-lin".hostname == "wang-lin"
    ) "home hostname was parsed incorrectly")
    (expect (!evaluates (fileLib.parseSystemConfigurations ./fixtures/systems-duplicate)) "duplicate system hostnames were accepted")
    (expect (!evaluates (fileLib.parseHomeConfigurations ./fixtures/homes-duplicate)) "duplicate home names were accepted")
    (expect (!evaluates (fileLib.parseHomeConfigurations ./fixtures/homes-missing-at)) "home name without @ was accepted")
    (expect (!evaluates (fileLib.parseHomeConfigurations ./fixtures/homes-extra-at)) "home name with multiple @ was accepted")
  ];
in
  builtins.deepSeq tests (
    pkgs.runCommand "file-parser-tests" {} ''
      touch "$out"
    ''
  )
