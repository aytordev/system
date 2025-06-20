# Checks configuration for the NixOS flake
#
# This module dynamically imports all check modules from subdirectories
# and combines them into a single attribute set. Each check should be in its
# own directory with a default.nix file that exports a derivation.
#
# Version: 1.1.0
# Last Updated: 2025-06-20
{
  pkgs,
  self,
  ...
} @ args: let
  # Read the current directory contents
  currentDir = builtins.readDir ./.;

  # isCheckDir :: String -> Bool
  # Check if a directory entry is a valid check (has a default.nix)
  #
  # Args:
  #   name: Name of the directory entry to check
  # Returns:
  #   Boolean indicating if the entry is a valid check directory
  isCheckDir = name: let
    entryType = currentDir.${name} or "";
    isDir = entryType == "directory";
    checkPath = ./. + "/${name}";
    hasDefaultNix = isDir && builtins.pathExists (checkPath + "/default.nix");
  in
    isDir && hasDefaultNix;

  # Get all valid check directories
  checkDirs = builtins.filter isCheckDir (builtins.attrNames currentDir);

  # importCheck :: String -> { name: String, value: Derivation }
  # Import a check module and validate its structure
  #
  # Args:
  #   name: Name of the check to import
  # Returns:
  #   Attribute set with name and value (the imported check)
  # Throws:
  #   If the check doesn't evaluate to a valid derivation
  importCheck = name: let
    checkPath = ./. + "/${name}";
    imported = import (checkPath + "/default.nix") args;

    # Simple validation that the imported value is a derivation
    isValidDerivation =
      builtins.isAttrs imported
      && (imported.type or "") == "derivation";

    errorMsg =
      "Check '${name}' in ${toString checkPath} "
      + "must evaluate to a derivation";
  in
    if !isValidDerivation
    then throw errorMsg
    else {
      inherit name;
      value = imported;
    };

  # Import all check modules and convert to attribute set
  importedChecks = map importCheck checkDirs;

  # Final result: convert list of {name, value} to attribute set
  result = builtins.listToAttrs importedChecks;
in
  result
