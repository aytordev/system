{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  home = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      hostname = "module-test";
      username = "module-test";
      osConfig = {};
      lib = extendedLib;
    };

    modules = [
      inputs.self.homeModules.default
      {
        home = {
          username = "module-test";
          homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Users/module-test"
            else "/home/module-test";
          stateVersion = "25.11";
        };
      }
    ];
  };
in
  home.activationPackage
