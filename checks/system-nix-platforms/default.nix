{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  expectedUser = "module-eval-user";
  decoyUsername = "must-not-be-trusted";
  expectedAllowedUsers = [
    "root"
    "@wheel"
    "nix-builder"
    expectedUser
  ];
  nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      username = decoyUsername;
      lib = extendedLib;
    };
    modules = [
      {_module.args.lib = extendedLib;}
      ../../modules/common/nix
      {
        aytordev.nix = {
          enable = true;
          extraTrustedUsers = [expectedUser];
        };
        system.stateVersion = "25.11";
      }
    ];
  };
  darwin = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs;
      inherit (inputs) self;
      username = decoyUsername;
      lib = extendedLib;
    };
    modules = [
      {_module.args.lib = extendedLib;}
      ../../modules/darwin/nix
      {
        system = {
          primaryUser = expectedUser;
          stateVersion = 6;
        };
        users.users.${expectedUser}.home = "/Users/${expectedUser}";
        aytordev.nix.enable = true;
      }
    ];
  };
  nixosSettings = nixos.config.nix.settings;
  darwinSettings = darwin.config.nix.settings;
  tests = [
    (nixosSettings."allowed-users" == expectedAllowedUsers)
    (darwinSettings."allowed-users" == expectedAllowedUsers)
    (builtins.elem expectedUser nixosSettings."trusted-users")
    (builtins.elem expectedUser darwinSettings."trusted-users")
    (!(builtins.elem decoyUsername nixosSettings."trusted-users"))
    (!(builtins.elem decoyUsername darwinSettings."trusted-users"))
    (nixosSettings.sandbox == true)
    (darwinSettings.sandbox == "relaxed")
    (nixosSettings."http-connections" == 50)
    (darwinSettings."http-connections" == 25)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "system-nix-platform-tests" {} ''
      touch "$out"
    ''
