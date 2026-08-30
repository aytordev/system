{
  inputs,
  pkgs,
  ...
}: let
  identity = {
    username = "ci-home";
    email = "ci-home@example.test";
    fullName = "CI Home";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";
  home = inputs.self.lib.system.mkHome {
    inherit (identity) username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "ci-home";
    extraSpecialArgs = {inherit identity;};
    modules = [
      (
        moduleArgs @ {inputs, ...}: {
          assertions = [
            {
              assertion = !(inputs ? secrets);
              message = "Synthetic homes must not receive the private secrets input";
            }
            {
              assertion = !(moduleArgs ? secretsRoot);
              message = "Synthetic homes must not receive the private secrets root";
            }
          ];
          aytordev = {
            user = {
              enable = true;
              name = identity.username;
              inherit (identity) email fullName;
              home = homeDirectory;
            };
            suites.common.enable = true;
          };
          home.stateVersion = "25.11";
        }
      )
    ];
  };
in
  home.activationPackage
