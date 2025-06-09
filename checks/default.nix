# Checks configuration for the NixOS flake
# This file serves as the entry point for all checks
{
  pkgs,
  system,
  self,
  ...
} @ args: let
  # Get all .nix files in the current directory, excluding default.nix
  checkFiles =
    builtins.filter
    (f: f != "default.nix" && pkgs.lib.strings.hasSuffix ".nix" f)
    (builtins.attrNames (builtins.readDir ./.));

  # Import a check file
  importCheck = name: let
    checkName = builtins.head (pkgs.lib.strings.splitString "." name);
  in {
    name = checkName;
    value = import (./. + "/${name}") args;
  };

  # Import all check files
  importedChecks = builtins.map importCheck checkFiles;
in
  # Convert the list of attrsets to a single attrset
  builtins.listToAttrs importedChecks
