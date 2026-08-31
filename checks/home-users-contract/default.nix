{
  inputs,
  lib,
  pkgs,
  ...
}: let
  fixtureOutputs = (import ../fixtures/secrets/flake.nix).outputs {};
  owner = fixtureOutputs.username;
  fixtureUsers = lib.attrNames (fixtureOutputs.users or {});
  allHomes = inputs.self.lib.file.parseHomeConfigurations ../../homes;
  homeUsers = lib.unique (lib.mapAttrsToList (_: home: home.username) allHomes);
  missingUsers = lib.filter (user: user != owner && !(lib.elem user fixtureUsers)) homeUsers;
  errorMessage =
    (lib.concatStringsSep "\n" [
      "Secrets fixture is missing users.<name> identities for these home users:"
    ])
    ++ lib.concatMap (user: "\n  - ${user}") missingUsers
    ++ "\n"
    ++ (lib.concatStringsSep "\n" [
      "Add each one to checks/fixtures/secrets/flake.nix so CI can evaluate its host and home."
      "Every non-owner home username must have a matching fixture identity (see identity.fromSecretsFor)."
    ]);
in
  if missingUsers == []
  then
    pkgs.runCommand "home-users-contract" {} ''
      touch "$out"
    ''
  else throw errorMessage
