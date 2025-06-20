# libraries/default.nix
#
# @summary Main entry point for library functions
#
# @description
#   Automatically imports all .nix files in this directory and makes them available
#   through a single attribute set. This module follows SOLID principles for better
#   maintainability and extensibility, providing a dynamic way to import library
#   modules with appropriate arguments.
#
# @version 2.0.0
# @last_updated 2025-06-10
#
# @param lib The nixpkgs library
# @param ... Additional arguments passed to modules
#
# @return An attribute set containing all library functions and utilities
#
# @example Basic usage
#   let
#     lib = import ./libraries;
#   in {
#     # Use library functions
#     path = lib.relativeToRoot ["path" "to" "file"];
#   }
{lib, ...} @ args:

let
  # Type: Path -> [String]
  #
  # Get all .nix files in a directory, recursively.
  #
  # @param dir The directory to search in
  # @return List of relative paths to .nix files
  getNixFiles = dir:
    let
      # Read directory and filter for .nix files and directories
      allFiles = builtins.attrNames (builtins.readDir dir);
      
      # Filter function to identify .nix files (excluding default.nix) and directories
      isNixFileOrDir = file:
        let 
          isNixFile = lib.strings.hasSuffix ".nix" file;
          isNotDefault = file != "default.nix";
          isDir = (builtins.readDir dir)."${file}" == "directory";
        in (isNixFile && isNotDefault) || isDir;
      
      # Get files and directories in current directory
      filteredFiles = builtins.filter isNixFileOrDir allFiles;
      
      # Recursively process subdirectories
      processSubdir = file:
        if (builtins.readDir dir)."${file}" == "directory"
        then
          let
            subdir = dir + "/${file}";
            subFiles = getNixFiles subdir;
          in builtins.map (f: "${file}/${f}") subFiles
        else [];
      
      # Get all files from subdirectories
      subdirFiles = builtins.concatMap processSubdir filteredFiles;
      
      # Combine files from current directory and subdirectories
      allNixFiles = filteredFiles ++ subdirFiles;
    in allNixFiles;

  # Type: Path -> (Path -> a) -> a
  #
  # Import a file with the appropriate strategy.
  #
  # @param file The file to import
  # @return The imported module or function result
  # @throws If the imported file doesn't return an attribute set or function
  importFile = file:
    let
      # Resolve file path
      filePath = ./. + "/${file}";
      
      # Import the file
      imported = import filePath args;
      
      # Handle the imported value (function or attribute set)
      result =
        if builtins.isFunction imported then
          imported args  # Call function with args
        else if builtins.isAttrs imported then
          imported       # Use attribute set as-is
        else
          throw """
            Error in ${file}: 
            Imported file must return an attribute set or function that returns an attribute set.
            Got: ${builtins.typeOf imported}
          """;
    in result;

  # Import all .nix files in the current directory
  importedModules = map importFile (getNixFiles ./.);
  
  # Merge all attribute sets into one using recursive update
  combinedModules = lib.foldl' lib.recursiveUpdate {} importedModules;
  
  # Public API
  publicApi = {
    # Re-export important modules
    inherit (combinedModules) relativeToRoot macosSystem;
    
    # Re-export lib for convenience
    inherit lib;
    
    # Internal utilities (exposed for testing)
    _internal = {
      inherit getNixFiles importFile;
    };
  };
  
in
  # Combine public API with all modules
  combinedModules // publicApi
