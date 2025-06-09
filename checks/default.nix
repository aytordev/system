# Checks configuration for the NixOS flake
# This module dynamically imports all check files in the current directory
# and combines them into a single attribute set.
#
# Each check file should export a derivation that performs a specific
# verification task (e.g., formatting, linting, evaluation).
#
# Example:
#   checks = {
#     format = pkgs.runCommand ...;
#     eval = pkgs.runCommand ...;
#   };
{
  # Standard flake inputs
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

  # Import a check file and return an attribute set entry
  #
  # Type: String -> { name: String, value: Derivation }
  importCheck = name: let
    # Remove the .nix extension to get the check name
    checkName = builtins.head (pkgs.lib.strings.splitString "." name);
  in {
    name = checkName;
    value = import (./. + "/${name}") args;
  };

  # Import all check files
  importedChecks = builtins.map importCheck checkFiles;
in
  # Convert the list of attribute sets to a single attribute set
  # Example: [ { name = "format"; value = <drv>; } ] -> { format = <drv>; }
  builtins.listToAttrs importedChecks
