{ inputs }:
let
  inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs';
in
{
  /**
    Create an extended library with the flake's overlay.
  */
  mkExtendedLib = flake: nixpkgs: nixpkgs.lib.extend flake.lib.overlay;

  /**
    Create a nixpkgs configuration with overlays and unfree packages enabled.
  */
  mkNixpkgsConfig = flake: {
    overlays = builtins.attrValues flake.overlays;
    config = {
      allowAliases = false;
      allowUnfree = true;
    };
  };

  /**
    Get home configurations matching a specific system and hostname.
  */
  mkHomeConfigs =
    {
      flake,
      system,
      hostname,
    }:
    let
      inherit (flake.lib.file) parseHomeConfigurations;
      homesPath = ../../../homes;
      allHomes = parseHomeConfigurations homesPath;
    in
    filterAttrs (
      _name: homeConfig: homeConfig.system == system && homeConfig.hostname == hostname
    ) allHomes;

  /**
    Create a Home Manager configuration for a system.
  */
  mkHomeManagerConfig =
    {
      extendedLib,
      inputs,
      system,
      matchingHomes,
      isNixOS ? true,
    }:
    if matchingHomes != { } then
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs system;
            inherit (inputs) self;
            lib = extendedLib;
            flake-parts-lib = inputs.flake-parts.lib;
          };
          sharedModules = [
            { _module.args.lib = extendedLib; }
            inputs.sops-nix.homeManagerModules.sops
          ]
          ++ (extendedLib.importModulesRecursive ../../../modules/home);
          users = mapAttrs' (_name: homeConfig: {
            name = homeConfig.username;
            value = {
              imports = [ homeConfig.path ];
              home = {
                inherit (homeConfig) username;
                homeDirectory = inputs.nixpkgs.lib.mkDefault (
                  if isNixOS then "/home/${homeConfig.username}" else "/Users/${homeConfig.username}"
                );
              };
            };
          }) matchingHomes;
        };
      }
    else
      { };

  /**
    Create special arguments for system configurations.
  */
  mkSpecialArgs =
    {
      inputs,
      hostname,
      username,
      extendedLib,
    }:
    {
      inherit inputs hostname username;
      inherit (inputs) self;
      lib = extendedLib;
      flake-parts-lib = inputs.flake-parts.lib;
      format = "system";
      host = hostname;
    };
}
