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
  homeModule = {inputs, ...}: {
    assertions = [
      {
        assertion = !(inputs ? secrets);
        message = "Synthetic integrated homes must not receive the private secrets input";
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
      ({inputs, ...}: {
        assertions = [
          {
            assertion = !(inputs ? secrets);
            message = "Synthetic Darwin systems must not receive the private secrets input";
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
      })
    ];
  };
in
  if pkgs.stdenv.hostPlatform.isDarwin
  then darwin.system
  else
    pkgs.runCommand "synthetic-darwin-skipped" {} ''
      touch "$out"
    ''
