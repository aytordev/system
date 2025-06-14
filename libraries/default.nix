# libraries/default.nix
#
# Main entry point for library functions. Automatically imports all .nix files
# in this directory and makes them available through a single attribute set.
#
# Version: 2.0.0
# Last Updated: 2025-06-10
#
# This module follows SOLID principles for better maintainability and extensibility.
# It provides a dynamic way to import library modules with appropriate arguments.
{
  lib,
  inputs ? null,
  ...
} @ args: let
  # Default arguments passed to all modules unless overridden
  defaultArgs = {inherit lib;};

  # Define argument strategies for different module types
  # Each strategy is a function that receives the full args and returns the arguments to pass
  moduleStrategies = {
    # Default strategy - only pass the library
    default = args: args;

    # Special handling for macos-system.nix - pass all arguments
    "macos-system.nix" = args: args;

    # Add more strategies here as needed
    # "special-module.nix" = args: args // { special = true; };
  };

  # Get the strategy function for a given file
  getStrategy = file:
    if lib.hasAttr file moduleStrategies
    then moduleStrategies."${file}"
    else moduleStrategies.default;

  # Get all .nix files in the current directory
  getNixFiles = dir:
    builtins.filter
    (file: file != "default.nix" && lib.strings.hasSuffix ".nix" file)
    (builtins.attrNames (builtins.readDir dir));

  # Import a single file with the appropriate arguments
  importFile = file: let
    strategy = getStrategy file;
    importArgs = strategy args;
  in
    import (./. + "/${file}") importArgs;

  # Import all library files
  imported = map importFile (getNixFiles ./.);

  # Merge all attribute sets into one
  combined = lib.foldl' lib.recursiveUpdate {} imported;
in
  # Export the combined libraries with some additional utilities
  combined
  // {
    # Export all libraries as a single attribute set
    inherit (combined) relativeToRoot macosSystem namespace;

    # Export the lib itself for convenience
    inherit lib;

    # Export the import mechanism for testing or advanced usage
    _importers = {
      inherit getStrategy importFile getNixFiles;
    };
  }
