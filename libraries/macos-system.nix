# macOS System Configuration Library
#
# This library provides a function to create a macOS system configuration
# using nix-darwin and home-manager, following SOLID principles.
#
# All parameters except `lib` are optional with sensible defaults.
{
  # Core Nixpkgs library
  lib,
  # Required inputs for nix-darwin and home-manager
  inputs ? {},
  # List of nix-darwin modules to include
  darwin-modules ? [],
  # List of home-manager modules to include
  home-modules ? [],
  # User variables (must contain at least username)
  # Defaults to a minimal configuration with username 'user'
  variables ? {username = "user";},
  # System architecture (defaults to aarch64-darwin for Apple Silicon)
  system ? "aarch64-darwin",
  # Function to generate special arguments
  genSpecialArgs ? (system: {inherit system;}),
  # Pre-computed special arguments (defaults to genSpecialArgs result)
  specialArgs ? (genSpecialArgs system),
  ...
} @ args: let
  # Type definitions for better error messages
  types = {
    nonEmptyStr = str: lib.isString str && str != "";
    nonEmptyAttrs = attrs: lib.isAttrs attrs && attrs != {};
    nonEmptyList = list: lib.isList list && list != [];
  };

  # Input validation
  validateInputs = {
    inherit lib inputs system;

    # Check if required inputs are present
    checkRequiredInputs = {
      nix-darwin = inputs.nix-darwin or null;
      nixpkgs-darwin = inputs.nixpkgs-darwin or null;
    };

    # Validate username in variables
    checkUsername = variables.username or "user";
  };

  # Configuration builders
  builders = {
    # Build nixpkgs configuration
    mkNixpkgsConfig = {system, ...}: {
      nixpkgs.pkgs = import inputs.nixpkgs-darwin {
        inherit system;
        config.allowUnfree = true; # Required for some packages like Chrome
      };
    };

    # Build home-manager configuration if available and needed
    mkHomeManagerConfig = {
      home-manager,
      home-modules,
      username,
      specialArgs,
    }:
      if
        home-manager
        != null
        && home-manager ? darwinModules
        && lib.lists.length home-modules > 0
      then [
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "home-manager.backup";
            extraSpecialArgs = specialArgs;
            users."${username}".imports = home-modules;
          };
        }
      ]
      else [];
  };

  # Main configuration builder that creates a complete darwinSystem configuration
  # by combining all modules and configurations.
  #
  # Parameters:
  #   - nix-darwin: The nix-darwin package
  #   - system: Target system architecture (e.g., "aarch64-darwin")
  #   - specialArgs: Special arguments to pass to modules
  #   - darwin-modules: List of nix-darwin modules to include
  #   - home-manager: The home-manager package (optional)
  #   - home-modules: List of home-manager modules to include
  #   - username: System username for home-manager configuration
  #
  # Returns: A complete darwinSystem configuration
  mkDarwinConfig = {
    nix-darwin,
    system,
    specialArgs,
    darwin-modules,
    home-manager,
    home-modules,
    username,
  }:
    nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules =
        darwin-modules
        ++ [(builders.mkNixpkgsConfig {inherit system;})]
        ++ (builders.mkHomeManagerConfig {
          inherit home-manager home-modules username specialArgs;
        });
    };

  # Validate and process all inputs
  # Combines required inputs with validation results
  validated =
    validateInputs.checkRequiredInputs
    // {
      inherit (validateInputs) checkUsername;
    };

  # Final set of inputs with validation and defaults applied
  # Ensures all required inputs are present and provides defaults where possible
  checkedInputs = lib.recursiveUpdate validated {
    nix-darwin = validated.nix-darwin or (throw "nix-darwin input is required");
    nixpkgs-darwin = validated.nixpkgs-darwin or (throw "nixpkgs-darwin input is required");
    home-manager = inputs.home-manager or null; # Make home-manager optional
  };
in
  # Public interface of the module
  # This is what users of this library will interact with
  {
    # Main function to create a macOS system configuration
    #
    # Returns: A function that creates a complete system configuration
    # Example:
    #   macosSystem {
    #     inherit inputs;
    #     system = "aarch64-darwin";
    #     variables = { username = "user"; };
    #     darwin-modules = [ ./my-config.nix ];
    #   }
    macosSystem = mkDarwinConfig {
      inherit (checkedInputs) nix-darwin nixpkgs-darwin home-manager;
      inherit system specialArgs darwin-modules home-modules;
      username = validateInputs.checkUsername;
    };

    # Internal functions and values exposed for testing and advanced use cases
    # Not part of the public API and may change between releases
    _internal = {
      # Validation functions and input processing
      inherit validateInputs;

      # Configuration builders for different parts of the system
      inherit builders;

      # Main configuration builder function
      inherit mkDarwinConfig;
    };
  }
