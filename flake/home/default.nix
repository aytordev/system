{
  inputs,
  self,
  lib,
  ...
}: let
  inherit (self.lib.file) parseHomeConfigurations importModulesRecursive;

  reusableInputs = builtins.removeAttrs inputs ["secrets"];
  common = import ../../libraries/system/common {inputs = reusableInputs;};
  extendedLib = common.mkExtendedLib self inputs.nixpkgs;
  homesPath = ../../homes;
  allHomes = parseHomeConfigurations homesPath;
  allHomeModules = importModulesRecursive ../../modules/home;

  generateHomeConfiguration = _name: args @ {
    system,
    username,
    userAtHost,
    hostname,
    ...
  }: let
    configPath = args.path;
    hostIdentity = self.lib.identity.fromSecretsFor username inputs.secrets;
    ownerIdentity = self.lib.identity.fromSecrets inputs.secrets;
    validatedUsername = self.lib.identity.assertUsername hostIdentity.username username;
  in {
    name = userAtHost; # Use the full "username@hostname" as key
    value = self.lib.system.mkHome {
      inherit
        inputs
        system
        hostname
        ;
      username = validatedUsername;
      extraSpecialArgs = {
        identity = hostIdentity;
        inherit ownerIdentity;
      };
      modules = [configPath];
      homeModules = allHomeModules;
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
          imports = common.mkHomeModules {
            inherit extendedLib;
            homeModules = allHomeModules;
          };

          _module.args = {
            inputs = reusableInputs;
            inherit (reusableInputs) self;
            system = pkgs.stdenv.hostPlatform.system;
            flake-parts-lib = reusableInputs.flake-parts.lib;
          };
        };
    };

    # Dynamically generated home configurations
    homeConfigurations = lib.mapAttrs' generateHomeConfiguration allHomes;
  };
}
