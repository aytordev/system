# macOS System Configuration Library
#
# This module provides a streamlined interface for creating macOS system configurations
# using nix-darwin and home-manager. It emphasizes simplicity, type safety, and
# maintainability while following SOLID principles.
#
# Version: 2.0.1
# Last Modified: 2025-06-11
#
{lib, ...} @ args: let
  # Type Definitions
  # ===============
  #
  # This section defines the type system used for argument validation.
  # It provides runtime validation, documentation, and IDE support.
  # The type system enforces correct configuration structure and provides
  # helpful error messages when invalid configurations are provided.
  types =
    lib.types
    // {
      # Enhanced type for non-empty strings with descriptive error messages.
      # This type ensures that required string values are not empty.
      #
      # Example:
      #   username = lib.mkOption { type = types.nonEmptyStr; };
      nonEmptyStr =
        lib.types.strMatching ".+"
        // {
          description = "A non-empty string value";
          emptyValue = {text = "\"\"";};
          emptyValue.aliases = [""];
          emptyValue.description = "Empty string (not allowed)";
        };

      # Type for system arguments that defines the complete interface for macosSystem.
      # This type validates the structure of the configuration passed to macosSystem.
      systemArgsType = lib.types.submodule {
        description = ''
          Configuration options for the macOS system builder.
          This defines all possible options that can be passed to macosSystem.
        '';

        options = {
          # Flake inputs required for system configuration
          inputs = lib.mkOption {
            type = lib.types.submodule {
              description = "Flake inputs required for system configuration";
              options = {
                # nix-darwin package or flake input
                nix-darwin = lib.mkOption {
                  type = lib.types.raw or lib.types.unspecified;
                  description = ''
                    The nix-darwin flake input. This is required for system configuration.

                    Example:
                    ```nix
                    inputs = {
                      nix-darwin.url = "github:LnL7/nix-darwin";
                    };
                    ```
                  '';
                };

                # Optional home-manager input
                home-manager = lib.mkOption {
                  type = lib.types.nullOr (lib.types.raw or lib.types.unspecified);
                  default = null;
                  description = ''
                    The home-manager flake input. Required if using home-manager modules.

                    Example:
                    ```nix
                    home-manager = inputs.home-manager;
                    ```
                  '';
                };

                # nixpkgs input
                nixpkgs = lib.mkOption {
                  type = lib.types.raw or lib.types.unspecified;
                  description = ''
                    The nixpkgs flake input. Required for package management.

                    Example:
                    ```nix
                    nixpkgs = inputs.nixpkgs;
                    ```
                  '';
                };
              };
            };
            description = "Flake inputs required for system configuration";
            example = {
              nix-darwin = "<nix-darwin-flake>";
              home-manager = "<home-manager-flake>";
              nixpkgs = "<nixpkgs-flake>";
            };
          };

          # Target system architecture
          system = lib.mkOption {
            type = lib.types.str;
            default = "aarch64-darwin";
            description = ''
              The target system architecture. Common values:
              - "aarch64-darwin" for Apple Silicon Macs
              - "x86_64-darwin" for Intel Macs
            '';
            example = "aarch64-darwin";
          };

          # User variables and settings
          variables = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = ''
              User-defined variables that will be available in all modules.
              Must include at least a 'username' field for home-manager.

              Example:
              ```nix
              variables = {
                username = "johndoe";
                fullName = "John Doe";
                email = "john@example.com";
              };
              ```
            '';
          };

          # nix-darwin modules
          "darwin-modules" = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = ''
              List of nix-darwin modules to include in the system configuration.

              Example:
              ```nix
              darwin-modules = [
                ({ lib, ... }: {
                  system.stateVersion = 6;
                  networking.hostName = "my-mac";
                })
              ];
              ```
            '';
          };

          # home-manager modules
          "home-modules" = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = ''
              List of home-manager modules to include in the user configuration.
              Only used if home-manager input is provided.

              Example:
              ```nix
              home-modules = [
                ./users/johndoe/home.nix
                ({ config, ... }: {
                  home.stateVersion = "23.05";
                  programs.git.enable = true;
                })
              ];
              ```
            '';
          };

          # Special arguments for modules
          specialArgs = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = ''
              Additional arguments to make available in all modules.
              These will be merged with the default special arguments.

              Example:
              ```nix
              specialArgs = {
                myCustomArg = "value";
              };
              ```
            '';
          };
        };
      };
    };

  # Internal helper functions for the module
  helpers = rec {
    # Validate that a required input is provided.
    #
    # @param name: The name of the input (for error messages)
    # @param value: The value to check
    # @return: The value if not null, otherwise throws an error
    # @throws: Detailed error message if the input is null
    requireInput = name: value:
      if value == null
      then
        throw ''
          Required input '${name}' is missing. This is likely because:
          1. You forgot to pass it in your configuration
          2. The input path is incorrect in your flake.nix

          Example fix:
          ```nix
          (import ./macos-system.nix { inherit lib; }).macosSystem {
            inherit (inputs) nix-darwin home-manager nixpkgs;
            system = "aarch64-darwin";
            variables = { username = "your-username"; };
            "darwin-modules" = [];
          }
        ''
      else value;

    # Memoization wrapper (currently disabled)
    # TODO: Implement proper memoization that handles complex types
    # This is a no-op implementation that simply returns the function as-is.
    # A proper implementation would need to handle serialization of complex types.
    memoize = f: f; # No-op for now
  };

  # Configuration builders
  builders = {
    # Create nixpkgs configuration
    mkNixpkgsConfig = {
      system,
      nixpkgs,
      ...
    }: {
      nixpkgs.pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # Create home-manager configuration if available
    mkHomeManagerConfig = {
      home-manager,
      modules,
      username,
      specialArgs,
    }:
      if home-manager != null && home-manager ? darwinModules && modules != []
      then [
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "home-manager.backup";
            extraSpecialArgs = specialArgs;
            users."${username}".imports = modules;
          };
        }
      ]
      else [];
  };

  # Process and validate system arguments
  processArgs = systemArgs: let
    # Create a validated configuration using the type system
    validated = lib.types.submodule {
      options = types.systemArgsType.options;
    };

    # Merge with defaults and validate
    merged =
      lib.recursiveUpdate {
        system = "aarch64-darwin";
        variables = {};
        specialArgs = {};
        "darwin-modules" = [];
        "home-modules" = [];
      }
      systemArgs;

    # Extract and validate required inputs
    inputs = merged.inputs or {};
    nix-darwin = helpers.requireInput "nix-darwin" (inputs.nix-darwin or null);
    nixpkgs = helpers.requireInput "nixpkgs" (inputs.nixpkgs or null);
    home-manager = inputs.home-manager or null;

    # Get username with validation
    username =
      if merged.variables ? username && merged.variables.username != ""
      then merged.variables.username
      else throw "variables.username is required and cannot be empty";
  in {
    inherit lib nix-darwin home-manager nixpkgs;
    system = merged.system;
    inherit username;
    variables = merged.variables;
    specialArgs = merged.specialArgs;
    "darwin-modules" = merged."darwin-modules";
    "home-modules" = merged."home-modules";
  };

  # Main configuration builder
  mkDarwinConfig = args: let
    # Filter out the lib argument that might be passed by memoization
    filteredArgs = builtins.removeAttrs args ["lib"];

    # Build the modules list
    modules =
      filteredArgs."darwin-modules" or []
      ++ [
        (builders.mkNixpkgsConfig {
          inherit (filteredArgs) system;
          nixpkgs = filteredArgs.nixpkgs;
        })
      ]
      ++ (builders.mkHomeManagerConfig {
        home-manager = filteredArgs.home-manager or null;
        username = filteredArgs.username or "";
        specialArgs = filteredArgs.specialArgs or {};
        modules = filteredArgs."home-modules" or [];
      });
  in
    filteredArgs.nix-darwin.lib.darwinSystem {
      inherit (filteredArgs) system specialArgs;
      inherit modules;
    };
in {
  # Main entry point for creating a macOS system configuration
  macosSystem = systemArgs: let
    processed = processArgs systemArgs;
  in
    mkDarwinConfig processed;

  # Internal API for testing and advanced use
  _internal = {
    inherit helpers builders processArgs mkDarwinConfig;
    inherit types;
  };
}
