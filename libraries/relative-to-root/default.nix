# libraries/relative-to-root/default.nix
#
# @summary Path manipulation utilities
#
# @description
#   Provides functions for working with paths relative to the repository root.
#   This module helps in resolving paths in a way that's consistent across
#   different environments and build contexts.
#
# @version 1.1.0
# @last_updated 2025-06-21
#
# @param lib The nixpkgs library
# @param ... Additional arguments (unused)
#
# @return An attribute set containing path manipulation functions
#
# @example Basic usage
#   { lib, ... }:
#   {
#     # Resolve a path relative to repository root
#     configFile = lib.relativeToRoot ["config" "app.conf"];
#     
#     # Or using a string path
#     scriptPath = lib.relativeToRoot "scripts/start.sh";
#   }
{lib, ...}: {
  # @param path Path or list of path components relative to the repository root
  # @type path: Path | String | [String | Path]
  #
  # @return The resolved absolute path
  # @rtype: Path | String
  #
  # @throws If the input is neither a string, path, nor a list of strings/paths
  #
  # @example Resolve a simple path
  #   relativeToRoot "config/app.conf"
  #   # => "/path/to/repo/config/app.conf"
  #
  # @example Resolve using path components
  #   relativeToRoot ["config" "app.conf"]
  #   # => "/path/to/repo/config/app.conf"
  relativeToRoot = path:
    let
      # Get the repository root (parent of the libraries directory)
      repoRoot = builtins.toString ../.;
      
      # Type: (String | Path) -> (String | Path) -> String
      # 
      # Join two path components, handling edge cases with slashes.
      #
      # @param a First path component
      # @param b Second path component
      # @return Joined path as string
      joinPath = a: b:
        let
          # Convert path to string if needed
          aStr = if builtins.isPath a then builtins.toString a else a;
          bStr = if builtins.isPath b then builtins.toString b else b;
          
          # Check if we need to add a separator
          aEndsWithSlash = lib.strings.hasSuffix "/" aStr;
          bStartsWithSlash = lib.strings.hasPrefix "/" bStr;
          needsSeparator = !aEndsWithSlash && !bStartsWithSlash && aStr != "" && bStr != "";
        in
          if aStr == "" then
            bStr
          else if bStr == "" then
            aStr
          else if needsSeparator then
            "${aStr}/${bStr}"
          else
            aStr + bStr;
      
      # Convert path to string if it's a path type
      pathStr = if builtins.isPath path then builtins.toString path else path;
      
      # Handle different path formats
      resolvedPath =
        if builtins.isString pathStr then
          # Handle string paths
          if lib.strings.hasPrefix "/" pathStr then
            # Absolute path - use as is
            pathStr
          else
            # Relative path - join with repo root
            joinPath repoRoot pathStr
        else if builtins.isList pathStr then
          # Handle list of path components
          if pathStr == [] then
            throw "relativeToRoot: path component list cannot be empty"
          else
            lib.foldl' joinPath repoRoot pathStr
        else
          throw ''
            relativeToRoot: Invalid path type
            Expected: String | Path | [String | Path]
            Got: ${builtins.typeOf path}
            Value: ${builtins.toJSON path}
          '';
    in
      if builtins.isPath path then
        builtins.toPath resolvedPath
      else
        resolvedPath;
}
