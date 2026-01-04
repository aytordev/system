{ inputs }:
/**
  Create a Home Manager configuration.
*/
{
  system,
  hostname,
  username ? inputs.secrets.username,
  modules ? [ ],
  ...
}:
let
  flake = inputs.self or (throw "mkHome requires 'inputs.self' to be passed");
  common = import ../common { inherit inputs; };

  extendedLib = common.mkExtendedLib flake inputs.nixpkgs;
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    inherit ((common.mkNixpkgsConfig flake)) config overlays;
  };

  extraSpecialArgs = {
    inherit
      inputs
      hostname
      username
      system
      ;
    inherit (flake) self;
    lib = extendedLib;
    flake-parts-lib = inputs.flake-parts.lib;
  };

  modules = [
    { _module.args.lib = extendedLib; }

    inputs.sops-nix.homeManagerModules.sops

    # Import all home modules recursively
  ]
  ++ (extendedLib.importModulesRecursive ../../../modules/home)
  ++ modules;
}
