{
  inputs,
  pkgs,
  ...
}: let
  identity = {
    username = "ci-darwin";
    email = "ci-darwin@example.test";
    fullName = "CI Darwin";
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
      home = "/Users/${identity.username}";
    };
    home.stateVersion = "25.11";
  };
  darwin = inputs.self.lib.system.mkDarwin {
    system = "aarch64-darwin";
    hostname = "ci-darwin";
    inherit (identity) username;
    hostModule = null;
    extraSpecialArgs = {inherit identity;};
    matchingHomes.ci = {
      inherit (identity) username;
      path = homeModule;
    };
    modules = [
      (
        moduleArgs @ {
          inputs,
          options,
          ...
        }: {
          assertions = [
            {
              assertion = !(inputs ? secrets);
              message = "Synthetic Darwin systems must not receive the private secrets input";
            }
            {
              assertion = !(moduleArgs ? secretsRoot);
              message = "Synthetic Darwin systems must not receive the private secrets root";
            }
            {
              assertion = options.aytordev.nix ? package;
              message = "The shared Nix capability must expose a package option";
            }
            {
              assertion = options.aytordev.services.openssh ? package;
              message = "The Darwin OpenSSH capability must expose a package option";
            }
          ];
          aytordev.user = {
            name = identity.username;
            inherit (identity) email fullName;
          };
          networking.hostName = "ci-darwin";
          system = {
            primaryUser = identity.username;
            stateVersion = 6;
          };
        }
      )
    ];
  };
in
  if pkgs.stdenv.hostPlatform.isDarwin
  then darwin.system
  else
    pkgs.runCommand "synthetic-darwin-skipped" {} ''
      touch "$out"
    ''
