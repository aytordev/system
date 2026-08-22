{
  inputs,
  pkgs,
  ...
}: let
  identity = {
    username = "ci-nixos";
    email = "ci-nixos@example.test";
    fullName = "CI NixOS";
  };
  homeModule = moduleArgs @ {inputs, ...}: {
    assertions = [
      {
        assertion = !(inputs ? secrets);
        message = "Synthetic integrated homes must not receive the private secrets input";
      }
      {
        assertion = !(moduleArgs ? secretsRoot);
        message = "Synthetic integrated homes must not receive the private secrets root";
      }
    ];
    aytordev.user = {
      enable = true;
      name = identity.username;
      inherit (identity) email fullName;
      home = "/home/${identity.username}";
    };
    home.stateVersion = "25.11";
  };
  nixos = inputs.self.lib.system.mkSystem {
    system = "x86_64-linux";
    hostname = "ci-nixos";
    inherit (identity) username;
    hostModule = null;
    nixosModules = [];
    extraSpecialArgs = {inherit identity;};
    matchingHomes.ci = {
      inherit (identity) username;
      path = homeModule;
    };
    modules = [
      (
        moduleArgs @ {inputs, ...}: {
          assertions = [
            {
              assertion = !(inputs ? secrets);
              message = "Synthetic NixOS systems must not receive the private secrets input";
            }
            {
              assertion = !(moduleArgs ? secretsRoot);
              message = "Synthetic NixOS systems must not receive the private secrets root";
            }
          ];
          boot.isContainer = true;
          networking.hostName = "ci-nixos";
          system.stateVersion = "25.11";
          users.users.${identity.username}.isNormalUser = true;
        }
      )
    ];
  };
in
  if pkgs.stdenv.hostPlatform.isLinux
  then nixos.config.system.build.toplevel
  else
    pkgs.runCommand "synthetic-nixos-skipped" {} ''
      touch "$out"
    ''
