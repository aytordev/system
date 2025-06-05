# This file defines all outputs for the Nix flake.
# It's imported by flake.nix to keep the configuration organized.
{
  # Core inputs from flake.nix
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
} @ inputs:

let
  #############################################################################
  # System Configuration
  #############################################################################
  
  # List of supported systems
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  # Helper function to generate system-specific attributes
  forAllSystems = nixpkgs.lib.genAttrs systems;

  # Import system-specific nixpkgs with common configuration
  pkgsFor = system: import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;  # Allow proprietary packages
    };
  };

in {
  ###########################################################################
  # Development Environment
  #
  # Defines development shells with all necessary tools for working on this
  # repository. Access with `nix develop` or `nix-shell`.
  ###########################################################################
  devShells = forAllSystems (system: let
    pkgs = pkgsFor system;
    shells = import ../dev-shells { 
      inherit pkgs system;
      inherit (self) inputs;  # Pass flake inputs to dev-shells
    };
    
    # Helper to create a shell with common configuration
    mkShell = shell: pkgs.mkShell (shell // {
      buildInputs = shell.packages or [];
    });

    # Get all shells from the shells attribute
    allShells = shells.shells or {};

  in {
    # Default shell
    default = mkShell (shells.default or {});
    
    # All other shells
  } // builtins.mapAttrs (name: _: mkShell allShells.${name}) allShells);

  ###########################################################################
  # Packages
  #
  # Defines packages that can be built with `nix build`.
  ###########################################################################
  packages = forAllSystems (system: let
    pkgs = pkgsFor system;
  in {
    # Default package built with `nix build`
    default = pkgs.hello;
    
    # Example package
    hello = pkgs.hello;
  });

  ###########################################################################
  # Formatter
  #
  # Used by `nix fmt` to format Nix code.
  ###########################################################################
  formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);

  ###########################################################################
  # Pre-commit Checks
  #
  # Defines checks that run on `git commit`.
  ###########################################################################
  checks = forAllSystems (system: {});

  ###########################################################################
  # NixOS Configurations
  #
  # System configurations for NixOS machines.
  # Build with `nixos-rebuild switch --flake .#hostname`
  ###########################################################################
  nixosConfigurations = {};

  ###########################################################################
  # Darwin Configurations
  #
  # System configurations for macOS machines.
  # Build with `darwin-rebuild switch --flake .#hostname`
  ###########################################################################
  darwinConfigurations = {};

  # No legacy aliases needed - use packages.<system>.default and 
  #devShells.<system>.default directly
}
