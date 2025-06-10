# libraries/default.nix
#
# Main entry point for library functions. Automatically imports all .nix files
# in this directory and makes them available through a single attribute set.
#
# Version: 1.0.0
# Last Updated: 2025-06-09
{lib, ...}: let
  # Get all .nix files in the current directory
  nixFiles =
    builtins.filter
    (file: file != "default.nix" && lib.strings.hasSuffix ".nix" file)
    (builtins.attrNames (builtins.readDir ./.));

  # Import each file and collect their attributes
  imported = map (file: import (./. + "/${file}") {inherit lib;}) nixFiles;

  # Merge all attribute sets into one
  combined = lib.foldl' lib.recursiveUpdate {} imported;
in
  combined
  // {
    # Export all libraries as a single attribute set
    inherit (combined) relativeToRoot;

    # Export the lib itself for convenience
    inherit lib;
  }
