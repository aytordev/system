{inputs}:
/**
Create a Darwin system configuration.
*/
{
  system,
  hostname,
  username,
  modules ? [],
  matchingHomes ? null,
  darwinModules ? null,
  homeModules ? null,
  hostModule ? ../../../systems/${system}/${hostname},
  extraSpecialArgs ? {},
  ...
}: let
  flake = inputs.self or (throw "mkDarwin requires 'inputs.self' to be passed");
  common = import ../common {inherit inputs;};

  extendedLib = common.mkExtendedLib flake inputs.nixpkgs;
  resolvedMatchingHomes =
    if matchingHomes == null
    then
      common.mkHomeConfigs {
        inherit
          flake
          system
          hostname
          ;
      }
    else matchingHomes;
  baseDarwinModules =
    if darwinModules == null
    then extendedLib.importModulesRecursive ../../../modules/darwin
    else darwinModules;
  homeManagerConfig = common.mkHomeManagerConfig {
    inherit
      extendedLib
      inputs
      system
      hostname
      username
      homeModules
      extraSpecialArgs
      ;
    matchingHomes = resolvedMatchingHomes;
    isNixOS = false;
  };
in
  inputs.nix-darwin.lib.darwinSystem {
    inherit system;

    specialArgs = common.mkSpecialArgs {
      inherit
        inputs
        hostname
        username
        extendedLib
        extraSpecialArgs
        ;
    };

    modules =
      [
        {_module.args.lib = extendedLib;}

        # Configure nixpkgs with overlays
        {
          nixpkgs =
            {
              inherit system;
            }
            // common.mkNixpkgsConfig flake;
        }

        inputs.home-manager.darwinModules.home-manager
        inputs.sops-nix.darwinModules.sops
        inputs.nix-rosetta-builder.darwinModules.default

        # Auto-inject home configurations for this system+hostname
        homeManagerConfig

        {
          home-manager = {
            backupFileExtension = "hm.old";
            verbose = true;
          };
        }

        # Import all darwin modules recursively
      ]
      ++ baseDarwinModules
      ++ inputs.nixpkgs.lib.optional (hostModule != null) hostModule
      ++ modules;
  }
