{
  inputs,
  self,
  lib,
  ...
}: let
  inherit (self.lib.file) parseHomeConfigurations;

  common = import ../../libraries/system/common {inherit inputs;};
  extendedLib = common.mkExtendedLib self inputs.nixpkgs;
  homesPath = ../../homes;
  allHomes = parseHomeConfigurations homesPath;

  generateHomeConfiguration = _name: args @ {
    system,
    username,
    userAtHost,
    hostname,
    ...
  }: let
    configPath = args.path;
  in {
    name = userAtHost; # Use the full "username@hostname" as key
    value = self.lib.system.mkHome {
      inherit
        inputs
        system
        hostname
        username
        ;
      modules = [configPath];
    };
  };
in {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake = {
    homeModules = {
      default = {
        lib,
        pkgs,
        ...
      }:
        if !(lib ? aytordev)
        then throw "homeModules.default requires lib extended with self.lib.overlay"
        else {
          imports = common.mkHomeModules {inherit extendedLib;};

          _module.args = {
            inherit inputs;
            inherit (inputs) self;
            system = pkgs.stdenv.hostPlatform.system;
            flake-parts-lib = inputs.flake-parts.lib;
          };
        };
    };

    # Dynamically generated home configurations
    homeConfigurations = lib.mapAttrs' generateHomeConfiguration allHomes;
  };
}
