# dev-shells/default.nix
#
# This file defines the base development shell configuration and dynamically
# imports all other shell configurations from this directory. It provides
# common packages and utilities used across all development environments.
#
# Version: 1.0.0
# Last Updated: 2025-06-05

{ pkgs, system, inputs, ... }:

let
  # Import a shell file and pass necessary arguments
  #
  # Type: String -> Path -> AttrSet
  # Example: importShell "just" ./just.nix
  importShell = name: path: {
    name = builtins.elemAt (pkgs.lib.strings.splitString "." (baseNameOf path)) 0;
    value = import path { inherit pkgs system inputs; };
  };

  # Get all .nix files except default.nix
  # Type: [String]
  shellFiles = builtins.filter
    (f: f != "default.nix" && pkgs.lib.strings.hasSuffix ".nix" f)
    (builtins.attrNames (builtins.readDir ./.));

  # Create attribute set of all shells
  # Type: AttrSet
  allShells = builtins.listToAttrs
    (map (f: importShell f (./. + "/${f}")) shellFiles);

  # Common packages for all shells
  # Type: [package]
  commonPackages = with pkgs; [
    # Version Control
    git         # Distributed version control system
    git-lfs     # Git extension for versioning large files
    gh          # GitHub CLI tool
    
    # Nix Development
    nixpkgs-fmt # Nix code formatter
    statix      # Lints and suggestions for Nix code
    deadnix     # Find and remove unused code in .nix files
    
    # Shell Tools
    jq          # Lightweight command-line JSON processor
    yq-go       # Portable command-line YAML/XML/TOML/... processor
    htop        # Interactive process viewer
    file        # File type identification utility
    tree        # Display directory structure as a tree
  ];

in {
  # All individual shells with common packages
  # Type: AttrSet
  shells = pkgs.lib.mapAttrs (_: shell: 
    let
      # Ensure each shell has required attributes
      validatedShell = shell // {
        name = shell.name or "unnamed-shell";
        packages = (shell.packages or []) ++ commonPackages;
      };
    in validatedShell
  ) allShells;

  # Default shell with list of available shells
  # Type: AttrSet
  default = {
    name = "default";
    packages = commonPackages;
    shellHook = ''
      echo -e "\n\033[1;32m🚀 Default Development Shell\033[0m"
      echo "Available shells: ${toString (builtins.attrNames allShells)}"
      echo "Enter a specific shell with: nix develop .#<shell-name>"
      echo ""
    '';
  };
}
