# libraries/relative-to-root.nix
#
# Path manipulation utilities for working with paths relative to the repository root.
#
# Version: 1.0.0
# Last Updated: 2025-06-09
{lib, ...}: {
  # Create a path relative to the repository root
  #
  # Type: String -> Path
  # Example: relativeToRoot "dev-shells/default.nix"
  # Returns: /absolute/path/to/repo/dev-shells/default.nix
  relativeToRoot = path: let
    # Get the repository root (parent of the libraries directory)
    repoRoot = builtins.toString ../../.;

    # Helper function to join path components
    joinPath = a: b: let
      aStr =
        if builtins.isPath a
        then builtins.toString a
        else a;
      bStr =
        if builtins.isPath b
        then builtins.toString b
        else b;
      hasSlash = lib.strings.hasSuffix "/" aStr || lib.strings.hasPrefix "/" bStr;
    in
      if hasSlash
      then aStr + bStr
      else "${aStr}/${bStr}";

    # Convert path to string if it's a path type
    pathStr =
      if builtins.isPath path
      then builtins.toString path
      else path;

    # Handle different path formats
    resolvedPath =
      if builtins.isString pathStr
      then
        # Handle string paths
        if lib.strings.hasPrefix "/" pathStr
        then
          # Absolute path - use as is
          pathStr
        else
          # Relative path - join with repo root
          joinPath repoRoot pathStr
      else if builtins.isList pathStr
      then
        # Handle list of path components
        let
          fullPath = lib.foldl' (acc: p: joinPath acc p) repoRoot pathStr;
        in
          fullPath
      else builtins.throw "relativeToRoot: expected string or list of strings, got ${builtins.typeOf path}";
  in
    builtins.trace "Resolved path: ${resolvedPath}"
    (
      if builtins.isPath path
      then builtins.toPath resolvedPath
      else resolvedPath
    );
}
