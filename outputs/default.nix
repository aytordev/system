# outputs/default.nix
#
# Main entry point for Nix flake outputs. This file defines:
# - System configurations for NixOS and macOS
# - Development shells with all necessary tools
# - Custom packages and overlays
# - CI/CD checks and formatters
# - Home Manager configurations
#
# The configuration uses a modular approach to support multiple platforms and
# architectures with shared modules and customizations.
#
# Version: 1.1.0
# Last Updated: 2025-06-10
# Flake inputs are passed from flake.nix
{
  # Core inputs from flake.nix
  self,
  nixpkgs,
  ...
} @ inputs: let
  #############################################################################
  # Imports and Configuration
  #############################################################################
  # Import nixpkgs library for utility functions
  inherit (inputs.nixpkgs) lib;

  # Import project-specific libraries
  # Type: AttrSet
  # Contains custom utility functions and shared modules
  libraries = import ../libraries {
    inherit lib;
    inherit inputs;
    inherit (inputs) self;
  };

  # Import project-specific variables
  # Type: AttrSet
  # Contains custom variables and constants
  # variables = import ../variables {inherit lib inputs;};
  #############################################################################
  # System Configuration
  #############################################################################

  # Add my custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager/darwin modules.
  genSpecialArgs = system:
    inputs
    // {
      inherit libraries;

      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    };

  # Common arguments passed to all modules
  # Type: AttrSet
  # Contains:
  # - inputs: All flake inputs
  # - lib: Nixpkgs library functions
  # - libraries: Project-specific libraries
  # - genSpecialArgs: Function to generate system-specific arguments
  args = {
    inherit 
      inputs 
      lib 
      libraries 
      # variables # Remove if not needed
      genSpecialArgs;
    };

  # Import system-specific configurations
  # Each system has its own directory under supported-systems/
  nixosSystems = {
    # x86_64 Linux configuration
    x86_64-linux =
      import (libraries.relativeToRoot "supported-systems/x86_64-linux")
      (args // {system = "x86_64-linux";});

    # Uncomment to enable other architectures as needed
    # aarch64-linux = import (libraries.relativeToRoot "supported-systems/aarch64-linux")
    #   (args // {system = "aarch64-linux";});
    # riscv64-linux = import (libraries.relativeToRoot "supported-systems/riscv64-linux")
    #   (args // {system = "riscv64-linux";});
  };

  # macOS-specific configurations
  darwinSystems = {
    # Apple Silicon (M1/M2) Macs
    aarch64-darwin =
      import (libraries.relativeToRoot "supported-systems/aarch64-darwin")
      (args // {system = "aarch64-darwin";});

    # Intel Macs
    # x86_64-darwin =
    #   import (libraries.relativeToRoot "supported-systems/x86_64-darwin")
    #   (args // {system = "x86_64-darwin";});
  };

  # Combined system configurations
  allSystems = nixosSystems // darwinSystems;

  # Helper variables for system management
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper function to generate a set of attributes for each supported system
  #
  # Type: (String -> a) -> AttrSet String a
  #   - func: A function that takes a system string and returns any value
  # Returns: An attribute set where keys are system names and values are the result of applying func
  #
  # Example:
  #   forAllSystems (system: pkgs.hello)  # Returns { "x86_64-linux" = pkgs.hello; "aarch64-darwin" = pkgs.hello; ... }
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);

  # Import system-specific nixpkgs with common configuration
  #
  # Type: String -> AttrSet
  # Example: pkgsFor "x86_64-linux"
  # Returns: Nixpkgs package set for the specified system
  pkgsFor = system:
    assert builtins.elem system allSystemNames;
      import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow proprietary packages
      };
in {
  ###########################################################################
  # Development Environment
  #
  # Defines development shells with all necessary tools for working on this
  # repository. Access with `nix develop` or `nix-shell`.
  #
  # Available commands:
  #   nix develop        # Enter default shell
  #   nix develop .#just # Enter specific shell
  #   nix flake show     # List all available shells
  ###########################################################################
  devShells = forAllSystems (system: let
    pkgs = pkgsFor system;

    # Import all shell definitions
    # Type: AttrSet
    shells = import (libraries.relativeToRoot "dev-shells") {
      inherit pkgs system;
      inherit (self) inputs; # Pass flake inputs to dev-shells
    };

    # Create a shell environment with the given configuration
    #
    # Type: AttrSet -> derivation
    # Example:
    #   mkShell {
    #     packages = [ pkgs.hello ];
    #     shellHook = "echo 'Hello, Nix!'";
    #   }
    mkShell = shell:
      pkgs.mkShell (shell
        // {
          buildInputs = shell.packages or [];
        });

    # Get all shells from the shells attribute with error handling
    #
    # Type: AttrSet
    # Returns: Attribute set of shell configurations
    # Throws: If no shells are defined in dev-shells/default.nix
    allShells =
      shells.shells or (throw ''
        No shells defined in dev-shells/default.nix.
        Please ensure you have a 'shells' attribute in your shell definitions.
      '');
  in
    # Convert the shells to derivations
    builtins.mapAttrs (name: shell: mkShell shell) allShells);

  ###########################################################################
  # Packages
  #
  # Defines packages that can be built with `nix build`.
  #
  # Available commands:
  #   nix build          # Build default package
  #   nix build .#hello  # Build specific package
  ###########################################################################
  packages = forAllSystems (system: let
    pkgs = pkgsFor system;
  in {
    # Default package built with `nix build`
    default = self.packages.${system}.hello;

    # Example package
    # Build with: nix build .#hello
    hello = pkgs.hello.overrideAttrs (old: {
      meta =
        old.meta
        // {
          description = "A friendly program that prints a greeting";
          longDescription = ''
            GNU Hello is a program that prints a friendly greeting.
            This is an example package for the Nix flake.
          '';
        };
    });
  });

  ###########################################################################
  # Formatter
  #
  # Configures the default formatter for `nix fmt` and `nix fmt --check`
  # Uses alejandra for consistent Nix code formatting across the project.
  #
  # Usage:
  #   nix fmt          # Format all Nix files
  #   nix fmt path/    # Format files in path/
  #   nix fmt --check  # Check formatting without making changes
  ###########################################################################
  formatter = forAllSystems (system: (pkgsFor system).alejandra);

  ###########################################################################
  # Checks
  #
  # Defines checks that run on `nix flake check`.
  #
  # Run all checks: nix flake check
  # Run specific check: nix build .#checks.<system>.<check>
  ###########################################################################
  checks = forAllSystems (system: let
    pkgs = pkgsFor system;
    # Import all checks from the checks directory
    allChecks = import (libraries.relativeToRoot "checks") {
      inherit pkgs system;
      inherit (self) inputs;
      inherit self;
    };
  in
    allChecks);

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
  darwinConfigurations = lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);

  ############################################################################
  # Examples
  ###########################################################################
  # Common usage examples:
  #
  # Build the default package:
  #   nix build
  #
  # Enter development shell:
  #   nix develop
  #
  # Format all Nix files:
  #   nix fmt
  #
  # Run all checks:
  #   nix flake check
  #
  # Build a specific system configuration:
  #   nixos-rebuild switch --flake .#hostname
  ###########################################################################
}
