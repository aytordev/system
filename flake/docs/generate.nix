{
  inputs,
  pkgs,
}:
/**
Evaluate the `aytordev.*` option surface for darwin and home manager
configurations and render each as CommonMark.

Synthetic arguments are used so evaluation never touches the private
`secrets` input. Outputs are derivation paths (see `nixosOptionsDoc`).
*/
let
  inherit (inputs.nixpkgs.lib) filterAttrs;
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  common = import ../../libraries/system/common {inherit inputs;};
  stateVersion = "26.11";
  identity = {
    username = "docs";
    email = "docs@example.test";
    fullName = "Docs User";
  };

  mkOptionsDoc = eval:
    pkgs.nixosOptionsDoc {
      options = filterAttrs (name: _: name == "aytordev") eval.options;
      warningsAreErrors = false;
    };

  # Compact index: derive from the generated markdown's `##` headers at build
  # time (see flake/docs and checks/docs-generation). Headers are option names
  # only — no prose, no /nix/store paths — so the snapshot stays small and
  # stable. No flattener needed here: consumers run `grep '^## '`.

  darwinEval = inputs.nix-darwin.lib.darwinSystem {
    inherit (pkgs.stdenv.hostPlatform) system;
    modules =
      [
        {nixpkgs.pkgs = pkgs;}
        (_: {
          aytordev.user = {
            name = identity.username;
            inherit (identity) email fullName;
          };
        })
        inputs.home-manager.darwinModules.home-manager
        inputs.sops-nix.darwinModules.sops
        inputs.nix-rosetta-builder.darwinModules.default
      ]
      ++ inputs.self.lib.file.importModulesRecursive ../../modules/darwin;
    specialArgs = {
      inherit inputs identity;
      lib = extendedLib;
      inherit (identity) username;
      hostname = "docs";
      format = "system";
      host = "docs";
      osConfig = {};
      virtual = false;
    };
  };

  homeEval = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    check = false;
    modules =
      [
        (_: {
          nixpkgs.pkgs = pkgs;
          nixpkgs.overlays = [];
          programs.home-manager.enable = true;
          home = {
            inherit stateVersion;
            inherit (identity) username;
            homeDirectory = "/Users/${identity.username}";
          };
          aytordev.user = {
            enable = true;
            name = identity.username;
            inherit (identity) email fullName;
          };
        })
      ]
      ++ common.mkHomeModules {inherit extendedLib;};
    extraSpecialArgs = {
      inherit inputs identity;
      lib = extendedLib;
      system = pkgs.stdenv.hostPlatform.system;
      hostname = "docs";
      inherit (identity) username;
      osConfig = {};
    };
  };
in {
  inherit stateVersion;

  darwin = mkOptionsDoc darwinEval;
  home = mkOptionsDoc homeEval;
}
