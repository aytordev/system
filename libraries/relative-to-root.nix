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
  relativeToRoot = lib.path.append ../.;
}
