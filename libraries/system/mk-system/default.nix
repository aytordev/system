{inputs}:
/**
Create a NixOS system configuration.
*/
{
  system,
  hostname,
  username,
  modules ? [],
  matchingHomes ? null,
  nixosModules ? null,
  homeModules ? null,
  ...
}: let
  flake = inputs.self or (throw "mkSystem requires 'inputs.self' to be passed");
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
  baseNixOSModules =
    if nixosModules == null
    then extendedLib.importModulesRecursive ../../../modules/nixos
    else nixosModules;
  homeManagerConfig = common.mkHomeManagerConfig {
    inherit
      extendedLib
      inputs
      system
      hostname
      homeModules
      ;
    matchingHomes = resolvedMatchingHomes;
    isNixOS = true;
  };
in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = common.mkSpecialArgs {
      inherit
        inputs
        hostname
        username
        extendedLib
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

        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops

        # Auto-inject home configurations for this system+hostname
        homeManagerConfig

        # Import all nixos modules recursively
      ]
      ++ baseNixOSModules
      ++ [
        ../../../systems/${system}/${hostname}
      ]
      ++ modules;
  }
