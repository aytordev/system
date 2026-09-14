{
  lib,
  pkgs,
  inputs,
  ...
}: let
  # The registry imports the renderers, which call `lib.importSubdirs`, so the
  # extended aytordev lib is required.
  extendedLib = lib.extend inputs.self.lib.overlay;
  registry = import ../../modules/common/ai-tools/registry.nix {lib = extendedLib;};

  inherit (registry) commands;
  inherit (registry) agents;

  sorted = builtins.sort builtins.lessThan;

  # Each identifier has exactly one declaration file and vice versa.
  keyParity =
    sorted (builtins.attrNames commands)
    == sorted registry.commandNames
    && sorted (builtins.attrNames agents) == sorted registry.agentNames;

  # Every command agent reference resolves, or is explicitly absent.
  agentReferencesResolve =
    lib.all (command: command.agent == null || lib.elem command.agent (builtins.attrNames agents))
    (lib.attrValues commands);

  # Duplicate identifiers are detected and unique sets are accepted.
  detectsDuplicate = registry.duplicateNames ["a" "b" "a"] == ["a"];
  acceptsUnique = registry.duplicateNames ["a" "b"] == [];

  checks = {
    inherit
      keyParity
      agentReferencesResolve
      detectsDuplicate
      acceptsUnique
      ;
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);
in
  if failed != []
  then throw "ai-tools contract check failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-contract-check" {} ''
      touch "$out"
    ''
