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
{lib, ...} @ args: let
  # Define strategies for importing different types of files
  moduleStrategies = {
    # Default strategy: pass all arguments to the module
    default = _: args;

    # Strategy for files that expect specific arguments
    specific = _: {inherit lib;};
  };

  # Determine which import strategy to use based on the file name
  getStrategy = file:
    if lib.strings.hasInfix "special" file
    then moduleStrategies.specific
    else moduleStrategies.default;

  # Recursively find all .nix files in a directory, excluding default.nix
  getNixFiles = dir: let
    allFiles = builtins.attrNames (builtins.readDir dir);
    filteredFiles =
      builtins.filter
      (
        file: let
          isNixFile = lib.strings.hasSuffix ".nix" file;
          isNotDefault = file != "default.nix";
          isDir = (builtins.readDir dir)."${file}" == "directory";
          result = (isNixFile && isNotDefault) || isDir;
        in
          result
      )
      allFiles;

    subdirFiles =
      builtins.concatMap
      (
        file:
          if (builtins.readDir dir)."${file}" == "directory"
          then let
            subdir = dir + "/${file}";
          in
            builtins.map (f: "${file}/${f}") (getNixFiles subdir)
          else []
      )
      (builtins.filter (f: (builtins.readDir dir)."${f}" == "directory") allFiles);

    allNixFiles = filteredFiles ++ subdirFiles;
  in
    allNixFiles;

  # Import a single file with the appropriate strategy
  importFile = file: let
    strategy = getStrategy file;
    importArgs = strategy args;
    filePath = ./. + "/${file}";
    imported = import filePath importArgs;
    result =
      if builtins.isFunction imported
      then imported importArgs
      else if builtins.isAttrs imported
      then imported
      else builtins.throw "Imported file ${file} must return an attribute set or function that returns an attribute set";
  in
    result;

  # Import all .nix files in the current directory
  imported = let
    files = getNixFiles ./.;
    importedModules = map importFile files;
  in
    importedModules;

  # Merge all attribute sets into one
  combined =
    lib.foldl' (
      acc: module:
        lib.recursiveUpdate acc module
    ) {}
    imported;

  # Extract the modules we want to re-export
  exports = {
    # Export all libraries as a single attribute set
    inherit (combined) relativeToRoot macosSystem;

    # Export the lib itself for convenience
    inherit lib;

    # Export the import mechanism for testing or advanced usage
    _importers = {
      inherit getStrategy importFile getNixFiles;
    };
  };

  # Combine everything together
  final = combined // exports;
in
  final
