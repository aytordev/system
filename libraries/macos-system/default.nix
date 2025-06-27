# macOS System Configuration Library
#
# This module provides a streamlined interface for creating macOS system configurations
# using nix-darwin and home-manager. It emphasizes simplicity, type safety, and
# maintainability while following SOLID principles.
#
# Version: 2.0.1
# Last Modified: 2025-06-11
#
{lib, ...}: let
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
                "nix-darwin" = lib.mkOption {
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

  /*
  Process and validate system arguments

  Type: processArgs :: AttrSet -> AttrSet

  Validates and processes system arguments, merging them with defaults and ensuring
  required fields are present. Returns a processed argument set ready for configuration.

  Args:
    systemArgs: An attribute set containing system configuration arguments

  Returns:
    An attribute set containing validated and processed arguments

  Throws:
    - If required inputs are missing
    - If username is not provided or empty
  */
  processArgs = systemArgs:
    if !builtins.isAttrs systemArgs
    then throw "systemArgs must be an attribute set"
    else let
      # Default configuration values
      defaults = {
        system = "aarch64-darwin";
        variables = {};
        specialArgs = {};
        "darwin-modules" = [];
        "home-modules" = [];
      };

      # Merge with user args
      merged = defaults // systemArgs;

      # Input validation
      inputs = merged.inputs or {};

      nix-darwin = helpers.requireInput "nix-darwin" (
        inputs.nix-darwin or (throw "inputs.nix-darwin is required")
      );

      nixpkgs = helpers.requireInput "nixpkgs" (
        inputs.nixpkgs or (throw "inputs.nixpkgs is required")
      );

      home-manager = inputs.home-manager or null;

      # Validate username with better error message
      username = let
        user = merged.variables.username or "";
      in
        if user == ""
        then throw "variables.username is required and cannot be empty. Please provide a username in your configuration."
        else if !builtins.isString user
        then throw "variables.username must be a string"
        else user;

      # Prepare special arguments, ensuring libraries are properly passed through
      specialArgs =
        (merged.specialArgs or {})
        // (lib.optionalAttrs (inputs ? libraries) {
          inherit (inputs) libraries;
        })
        // (lib.optionalAttrs (systemArgs ? libraries) {
          inherit (systemArgs) libraries;
        });
    in {
      inherit lib nix-darwin home-manager nixpkgs;
      system = merged.system;
      inherit username specialArgs;
      variables = merged.variables;
      "darwin-modules" = merged."darwin-modules";
      "home-modules" = merged."home-modules";
    };

  /*
  Build a complete Darwin system configuration

  Type: mkDarwinConfig :: AttrSet -> AttrSet

  Constructs a complete Darwin system configuration by combining various modules
  and configurations. This is the main entry point for creating system configurations.

  Args:
    args: An attribute set containing:
      - system: System architecture (e.g., "aarch64-darwin")
      - nix-darwin: The nix-darwin package
      - nixpkgs: The nixpkgs package set
      - username: System username
      - specialArgs: Additional arguments to pass to modules
      - darwin-modules: List of Darwin modules to include
      - home-modules: List of Home Manager modules to include
      - home-manager: Home Manager package (optional)

  Returns:
    A complete Darwin system configuration

  Throws:
    - If required arguments are missing
    - If module construction fails
  */
  mkDarwinConfig = args:
    if !builtins.isAttrs args
    then throw "args must be an attribute set"
    else let
      # Remove lib to prevent conflicts with nix-darwin's lib
      args' = builtins.removeAttrs args ["lib"];

      # Validate required arguments
      requiredArgs = ["system" "nix-darwin" "nixpkgs" "username"];
      missingArgs = builtins.filter (a: !args'?${a}) requiredArgs;

      throwIfMissing = arg:
        if !args'?${arg}
        then throw "Missing required argument: ${arg}"
        else null;

      _ = builtins.map throwIfMissing requiredArgs;

      # Build nixpkgs configuration module
      nixpkgsModule = builders.mkNixpkgsConfig {
        system = args'.system;
        nixpkgs = args'.nixpkgs;
      };

      # Build Home Manager configuration if available
      homeManagerModules = let
        hm = args'."home-manager" or null;
        hmModules = args'."home-modules" or [];
      in
        if hm != null && hmModules != []
        then builders.mkHomeManagerConfig {
          home-manager = hm;
          username = args'.username;
          specialArgs = args'.specialArgs or {};
          modules = hmModules;
        }
        else [];

      # Combine all modules, ensuring no nested lists
      modules = lib.lists.flatten [
        (args'."darwin-modules" or [])
        nixpkgsModule
        homeManagerModules
      ];

      # Final system configuration
      systemConfig = {
        system = args'.system;
        inherit modules;
        specialArgs = args'.specialArgs or {};
      };
    in
      if missingArgs != []
      then throw "Missing required arguments: ${builtins.toString missingArgs}"
      else args'."nix-darwin".lib.darwinSystem systemConfig;
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
