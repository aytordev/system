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
  # outputs/default.nix
  #
  # This file defines the outputs for our Nix flake, including development shells
  # and packages. It serves as the main entry point for all system configurations.
  #
  # Version: 1.0.0
  # Last Updated: 2025-06-05

  #############################################################################
  # System Configuration
  #############################################################################
  
  # System types to support
  # Add or remove as needed for your use case
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  # Helper function to generate system-specific attributes
  #
  # Type: AttrSet (String -> a) -> AttrSet (String -> a)
  # Example: forAllSystems (system: { hello = "hello-${system}"; })
  forAllSystems = nixpkgs.lib.genAttrs systems;

  # Import system-specific nixpkgs with common configuration
  #
  # Type: String -> AttrSet
  # Example: pkgsFor "x86_64-linux"
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
    shells = import ../dev-shells { 
      inherit pkgs system;
      inherit (self) inputs;  # Pass flake inputs to dev-shells
    };
    
    # Helper to create a shell with common configuration
    # Type: AttrSet -> derivation
    #
    # Example:
    #   mkShell {
    #     name = "example";
    #     packages = [ pkgs.hello ];
    #   }
    mkShell = shell: pkgs.mkShell (shell // {
      buildInputs = shell.packages or [];
    });

    # Get all shells from the shells attribute
    # Type: AttrSet
    allShells = shells.shells or {};

  in {
    # Default shell (fallback if no default is defined in dev-shells/default.nix)
    default = mkShell (shells.default or {});
    
    # Dynamically import all other shells
  } // builtins.mapAttrs (name: shell: 
    mkShell (shell // {
      # Ensure each shell has a name
      name = shell.name or name;
    })
  ) allShells);

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
      meta = old.meta // {
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
