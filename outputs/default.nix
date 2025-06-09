# outputs/default.nix
#
# Main entry point for Nix flake outputs. Defines packages, development shells,
# formatters, and system configurations for the project.
#
# Version: 1.0.0
# Last Updated: 2025-06-09
{
  # Core inputs from flake.nix
  self,
  nixpkgs,
  ...
} @ inputs: let
  #############################################################################
  # Imports and Configuration
  #############################################################################
  inherit (inputs.nixpkgs) lib;

  # Import project libraries with nixpkgs lib
  # Type: AttrSet
  libraries = import ../libraries {inherit lib;};

  #############################################################################
  # System Configuration
  #############################################################################
  # List of supported system types for cross-compilation.
  #
  # Type: List String
  # Supported values:
  #   - x86_64-linux: 64-bit Linux (Intel/AMD)
  #   - aarch64-linux: 64-bit Linux (ARM)
  #   - x86_64-darwin: 64-bit macOS (Intel)
  #   - aarch64-darwin: 64-bit macOS (Apple Silicon)
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  # Helper function to validate system type
  #
  # Type: String -> Bool
  # Example: assertSystem "x86_64-linux"
  assertSystem = system:
    if builtins.elem system systems
    then true
    else throw "Unsupported system: ${system}";

  # Generate system-specific attributes from a function
  #
  # Type: (String -> a) -> AttrSet String a
  # Example: forAllSystems (system: { hello = "hello-${system}"; })
  forAllSystems = nixpkgs.lib.genAttrs systems;

  # Import system-specific nixpkgs with common configuration
  #
  # Type: String -> AttrSet
  # Example: pkgsFor "x86_64-linux"
  # Returns: Nixpkgs package set for the specified system
  pkgsFor = system:
    assert assertSystem system;
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
      pkgs.mkShell (shell // {
        buildInputs = shell.packages or [];
      });

    # Get all shells from the shells attribute with error handling
    #
    # Type: AttrSet
    # Returns: Attribute set of shell configurations
    # Throws: If no shells are defined in dev-shells/default.nix
    allShells = shells.shells or (throw ''
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
  darwinConfigurations = {};

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
