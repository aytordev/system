# macOS System Configuration Library
#
# This library provides a function to create a macOS system configuration
# using nix-darwin and home-manager.
#
# All parameters except `lib` are optional with sensible defaults.
{
  lib,
  # Required inputs for nix-darwin and home-manager
  inputs ? {},
  # List of nix-darwin modules to include
  darwin-modules ? [],
  # List of home-manager modules to include
  home-modules ? [],
  # User variables (must contain at least username)
  variables ? {username = "user";},
  # System architecture (defaults to aarch64-darwin for Apple Silicon)
  system ? "aarch64-darwin",
  # Function to generate special arguments
  genSpecialArgs ? (system: {inherit system;}),
  # Pre-computed special arguments (defaults to genSpecialArgs result)
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  # Import required inputs with fallbacks to prevent evaluation errors
  nixpkgs-darwin = inputs.nixpkgs-darwin or (throw "nixpkgs-darwin input is required");
  home-manager = inputs.home-manager or null; # Make home-manager optional
  nix-darwin = inputs.nix-darwin or (throw "nix-darwin input is required");

  # Default username if not provided
  username = variables.username or "user";

  # Create the darwinSystem configuration with input validation
  darwinConfig = assert lib.assertMsg (nix-darwin != null) "nix-darwin input is required";
  assert lib.assertMsg (nixpkgs-darwin != null) "nixpkgs-darwin input is required";
    nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules =
        darwin-modules
        ++ [
          ({lib, ...}: {
            nixpkgs.pkgs = import nixpkgs-darwin {
              inherit system; # refer the `system` parameter from outer scope recursively
              # To use chrome, we need to allow the installation of non-free software
              config.allowUnfree = true;
            };
          })
        ]
        ++ (
          lib.optionals ((lib.lists.length home-modules) > 0)
          (
            let
              # Only include home-manager if it's available and we have home-modules
              homeManagerAvailable = home-manager != null && home-manager ? darwinModules;
            in
              if homeManagerAvailable
              then [
                home-manager.darwinModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "home-manager.backup";
                  home-manager.extraSpecialArgs = specialArgs;
                  home-manager.users."${username}".imports = home-modules;
                }
              ]
              else []
          )
        );
    };
in
  # Return the configuration
  darwinConfig
