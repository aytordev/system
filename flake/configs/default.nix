{
  inputs,
  self,
  lib,
  ...
}: let
  inherit
    (self.lib.file)
    parseSystemConfigurations
    parseHomeConfigurations
    filterNixOSSystems
    filterDarwinSystems
    importModulesRecursive
    ;

  systemsPath = ../../systems;
  homesPath = ../../homes;
  allSystems = parseSystemConfigurations systemsPath;
  allHomes = parseHomeConfigurations homesPath;
  allNixOSModules = importModulesRecursive ../../modules/nixos;
  allDarwinModules = importModulesRecursive ../../modules/darwin;
  allHomeModules = importModulesRecursive ../../modules/home;
  identity = self.lib.identity.fromSecrets inputs.secrets;
  privateModuleArgs = {
    inherit identity;
    secretsRoot = inputs.secrets;
  };
  matchingHomes = system: hostname:
    lib.filterAttrs (
      _name: homeConfig: homeConfig.system == system && homeConfig.hostname == hostname
    )
    allHomes;
in {
  flake = {
    nixosConfigurations = lib.mapAttrs' (
      _name: {
        system,
        hostname,
        ...
      }: {
        name = hostname;
        value = self.lib.system.mkSystem {
          inherit inputs system hostname;
          inherit (identity) username;
          extraSpecialArgs = privateModuleArgs;
          nixosModules = allNixOSModules;
          homeModules = allHomeModules;
          matchingHomes = matchingHomes system hostname;
        };
      }
    ) (filterNixOSSystems allSystems);

    darwinConfigurations = lib.mapAttrs' (
      _name: {
        system,
        hostname,
        ...
      }: {
        name = hostname;
        value = self.lib.system.mkDarwin {
          inherit inputs system hostname;
          inherit (identity) username;
          extraSpecialArgs = privateModuleArgs;
          darwinModules = allDarwinModules;
          homeModules = allHomeModules;
          matchingHomes = matchingHomes system hostname;
        };
      }
    ) (filterDarwinSystems allSystems);

    # NOTE: Home Manager configurations are now handled by flake/home/default.nix
  };
}
