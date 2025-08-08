{
  lib,
  inputs,
  ...
}: let
  types =
    lib.types
    // {
      nonEmptyStr =
        lib.types.strMatching ".+"
        // {
          description = "A non-empty string value";
          emptyValue = {text = "\"\"";};
          emptyValue.aliases = [""];
          emptyValue.description = "Empty string (not allowed)";
        };
      systemArgsType = lib.types.submodule {
        description = ''
          Configuration options for the macOS system builder.
          This defines all possible options that can be passed to macosSystem.
        '';
        options = {
          inputs = lib.mkOption {
            type = lib.types.submodule {
              description = "Flake inputs required for system configuration";
              options = {
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
          specialArgs = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = ''
              Additional arguments to make available in all modules.
              These will be merged with the default special arguments, including inputs.secrets.
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
  helpers = rec {
    formatError = {
      what,
      why,
      howToFix,
    }: ''
      Configuration error: ${what}
      - Reason: ${why}
      How to fix:
      ${howToFix}
    '';
    validateRequiredInputs = {
      inputs,
      required,
    }: let
      missing = builtins.filter (name: !(inputs ? ${name})) required;
    in
      if missing == []
      then inputs
      else
        throw (formatError {
          what = "Missing required inputs";
          why = "The following required inputs are missing: ${toString missing}";
          howToFix = ''
            Ensure your configuration includes all required inputs:
            ${lib.concatMapStringsSep "\n" (name: "- inputs.${name}") missing}
            Example:
            ```nix
            inputs = {
              ${lib.concatMapStringsSep "\n  " (name: "${name} = inputs.${name};") required}
            };
            ```
          '';
        });
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
            inputs = {
              inherit (inputs) nix-darwin home-manager nixpkgs;
            };
            system = "aarch64-darwin";
            "darwin-modules" = [];
          }
        ''
      else value;
    memoize = f: let
      cache = {};
    in
      arg:
        if cache ? ${builtins.toJSON arg}
        then cache.${builtins.toJSON arg}
        else let
          result = f arg;
        in
          builtins.trace "Caching result for ${builtins.toJSON arg}"
          (
            cache // {${builtins.toJSON arg} = result;}
          ).${
            builtins.toJSON arg
          };
  };
  builders = {
    mkNixpkgsConfig = {
      system,
      nixpkgs,
      ...
    }: {
      nixpkgs.pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
      };
    };
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
  processArgs = systemArgs:
    if !builtins.isAttrs systemArgs
    then throw "systemArgs must be an attribute set"
    else let
      defaults = {
        system = "aarch64-darwin";
        specialArgs = {};
        "darwin-modules" = [];
        "home-modules" = [];
      };
      merged = defaults // systemArgs;
      inputs = systemArgs.inputs or (throw "systemArgs.inputs is required");
      validatedInputs = helpers.validateRequiredInputs {
        inherit inputs;
        required = ["nix-darwin" "nixpkgs" "secrets"];
      };
      nix-darwin = validatedInputs.nix-darwin;
      nixpkgs = validatedInputs.nixpkgs;
      home-manager = validatedInputs.home-manager or null;
      username = let
        user = validatedInputs.secrets.username or "";
      in
        if user == ""
        then
          throw (helpers.formatError {
            what = "Missing username";
            why = "inputs.secrets.username is required and cannot be empty";
            howToFix = "Please provide a username in your configuration.";
          })
        else if !builtins.isString user
        then throw "inputs.secrets.username must be a string"
        else user;
      specialArgs = let
        baseArgs = merged.specialArgs or {};
        inputArgs = lib.optionalAttrs (inputs ? libraries) {
          inherit (inputs) libraries;
        };
        directArgs = lib.optionalAttrs (systemArgs ? libraries) {
          inherit (systemArgs) libraries;
        };
      in
        baseArgs // inputArgs // directArgs;
    in {
      inherit lib nix-darwin home-manager nixpkgs;
      system = merged.system;
      inherit username specialArgs;
      "darwin-modules" = merged."darwin-modules";
      "home-modules" = merged."home-modules";
    };
  mkDarwinConfig = args:
    if !builtins.isAttrs args
    then throw "args must be an attribute set"
    else let
      args' = builtins.removeAttrs args ["lib"];
      requiredArgs = ["system" "nix-darwin" "nixpkgs" "username"];
      missingArgs = builtins.filter (a: !args'?${a}) requiredArgs;
      _ =
        if missingArgs != []
        then
          throw (helpers.formatError {
            what = "Missing required arguments";
            why = "The following required arguments are missing: ${toString missingArgs}";
            howToFix = ''
              Ensure your configuration includes all required arguments:
              ${lib.concatMapStringsSep "\n" (a: "- ${a}") missingArgs}
            '';
          })
        else null;
      nixpkgsModule = builders.mkNixpkgsConfig {
        system = args'.system;
        nixpkgs = args'.nixpkgs;
      };
      homeManagerModules = let
        hm = args'."home-manager" or null;
        hmModules = args'."home-modules" or [];
      in
        if hm != null && hmModules != []
        then
          builders.mkHomeManagerConfig {
            home-manager = hm;
            username = args'.username;
            specialArgs =
              (args'.specialArgs or {})
              // {
                inherit (args') inputs;
              };
            modules = hmModules;
          }
        else [];
      modules = lib.lists.flatten [
        (args'."darwin-modules" or [])
        nixpkgsModule
        homeManagerModules
      ];
      systemConfig = {
        system = args'.system;
        inherit modules;
        specialArgs = args'.specialArgs or {};
        inputs = args.inputs;
      };
    in
      if missingArgs != []
      then
        throw ''
          The following required arguments are missing:
          ${lib.concatStringsSep "\n" (map (a: "- ${a}") missingArgs)}
          Example usage:
          ```nix
          macosSystem {
            inputs = {
              inherit (inputs) nix-darwin home-manager nixpkgs;
            };
            system = "aarch64-darwin";
            "darwin-modules" = [];
          }
          ```
        ''
      else args'."nix-darwin".lib.darwinSystem systemConfig;
in {
  macosSystem = systemArgs: let
    inputs = systemArgs.inputs or (throw "systemArgs.inputs is required");
    processed = processArgs (systemArgs // {inherit inputs;});
  in
    mkDarwinConfig ({
        inherit (processed) lib system username specialArgs;
        "darwin-modules" = processed."darwin-modules";
        "home-modules" = processed."home-modules";
        inherit (inputs) nix-darwin nixpkgs home-manager;
        inherit inputs;
      }
      // (
        if processed ? home-manager
        then {inherit (processed) home-manager;}
        else {}
      ));
  _internal = {
    inherit helpers builders processArgs mkDarwinConfig;
    inherit types;
  };
}
