# dev-shells/default.nix
#
# This file defines the base development shell configuration and imports
# shell configurations from subdirectories. Each shell should be in its
# own directory with a default.nix file that exports a shell configuration.
#
# Shells are automatically discovered and imported from subdirectories
# that contain a default.nix file.
#
# Version: 2.1.0
# Last Updated: 2025-06-20
{
  pkgs,
  system,
  inputs,
  ...
} @ args: let
  # Get the current directory contents
  currentDir = builtins.readDir ./.;

  # Check if a directory entry is a valid shell directory
  #
  # Args:
  #   name: Name of the directory entry to check
  # Returns:
  #   Boolean indicating if the entry is a valid shell directory
  isShellDir = name:
    currentDir.${name}
    == "directory"
    && builtins.pathExists (./. + "/${name}/default.nix");

  # Get all valid shell directories
  shellDirs = builtins.filter isShellDir (builtins.attrNames currentDir);

  # Import and validate a shell module
  #
  # Args:
  #   dir: Name of the directory containing the shell configuration
  # Returns:
  #   The imported and validated shell configuration
  importShell = dir: let
    path = ./. + "/${dir}";
    shell = import path {inherit pkgs system inputs;};
  in
    if !(builtins.isAttrs shell)
    then throw "Shell '${dir}' must evaluate to an attribute set"
    else if !(shell ? name)
    then throw "Shell '${dir}' must have a 'name' attribute"
    else shell;

  # Import all shell modules
  importedShells = builtins.listToAttrs (
    builtins.map
    (dir: {
      name = dir;
      value = importShell dir;
    })
    shellDirs
  );

  # Common packages for all shells
  commonPackages = with pkgs; [
    # Version Control
    git # Distributed version control system
    git-lfs # Git extension for versioning large files
    gh # GitHub CLI tool

    # Nix Development
    nixpkgs-fmt # Nix code formatter
    statix # Lints and suggestions for Nix code
    deadnix # Find and remove unused code in .nix files

    # Shell Tools
    jq # Lightweight command-line JSON processor
    yq-go # Portable command-line YAML/XML/TOML/... processor
    htop # Interactive process viewer
    file # File type identification utility
    tree # Display directory structure as a tree
  ];

  # Add common packages to each shell
  shellsWithCommonPkgs =
    builtins.mapAttrs (
      name: shell:
        shell
        // {
          packages = (shell.packages or []) ++ commonPackages;
        }
    )
    importedShells;

  # Default shell with list of available shells
  defaultShell = {
    name = "default";
    packages = commonPackages;
    shellHook = ''
      echo -e "\n\033[1;32m🚀 Default Development Shell\033[0m"
      echo "Available shells: ${toString (builtins.attrNames importedShells)}"
      echo "Enter a specific shell with: nix develop .#<shell-name>"
      echo ""
    '';
  };
in {
  # The 'shells' attribute is expected by the flake
  shells =
    shellsWithCommonPkgs
    // {
      default = defaultShell;
    };
}
