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
  ownerIdentity = identity;
  privateHostModule = path: moduleArgs:
    import path (
      moduleArgs
      // {
        secretsRoot = inputs.secrets;
      }
    );
  matchingHomes = system: hostname:
    lib.filterAttrs (
      _name: homeConfig: homeConfig.system == system && homeConfig.hostname == hostname
    )
    allHomes;

  # A host gets its user from its matching home (e.g. "avicente@civislend"
  # resolves "civislend" to user "avicente". Host without a home fall back to
  # the owner identity.
  perHostIdentity = system: hostname: let
    hostHomes = matchingHomes system hostname;
    homeUsers = lib.unique (lib.mapAttrsToList (_name: home: home.username) hostHomes);
    username =
      if homeUsers == []
      then identity.username
      else if builtins.length homeUsers == 1
      then builtins.head homeUsers
      else throw "host '${hostname}' has multiple users (${lib.concatStringsSep ", " homeUsers}); multi-user hosts are not supported yet";
  in
    self.lib.identity.fromSecretsFor username inputs.secrets;
in {
  flake = {
    nixosConfigurations = lib.mapAttrs' (
      _name: {
        system,
        hostname,
        path,
        ...
      }: let
        hostIdentity = perHostIdentity system hostname;
      in {
        name = hostname;
        value = self.lib.system.mkSystem {
          inherit inputs system hostname;
          inherit (hostIdentity) username;
          extraSpecialArgs = {
            identity = hostIdentity;
            inherit ownerIdentity;
          };
          hostModule = privateHostModule path;
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
        path,
        ...
      }: let
        hostIdentity = perHostIdentity system hostname;
      in {
        name = hostname;
        value = self.lib.system.mkDarwin {
          inherit inputs system hostname;
          inherit (hostIdentity) username;
          extraSpecialArgs = {
            identity = hostIdentity;
            inherit ownerIdentity;
          };
          hostModule = privateHostModule path;
          darwinModules = allDarwinModules;
          homeModules = allHomeModules;
          matchingHomes = matchingHomes system hostname;
        };
      }
    ) (filterDarwinSystems allSystems);

    # NOTE: Home Manager configurations are now handled by flake/home/default.nix
  };
}
