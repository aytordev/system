{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  libraries = import ../libraries {
    inherit lib;
    inherit inputs;
    inherit (inputs) self;
  };
  genSpecialArgs = system:
    inputs
    // {
      inherit libraries;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-ollama = import inputs.nixpkgs-ollama {
        inherit system;
        config.allowUnfree = true;
      };
    };
  args = {
    inherit
      inputs
      lib
      libraries
      genSpecialArgs
      ;
  };
  nixosSystems = {
    x86_64-linux =
      import (libraries.relativeToRoot "supported-systems/x86_64-linux")
      (args // {system = "x86_64-linux";});
  };
  darwinSystems = {
    aarch64-darwin =
      import (libraries.relativeToRoot "supported-systems/aarch64-darwin")
      (args // {system = "aarch64-darwin";});
  };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
  pkgsFor = system:
    assert builtins.elem system allSystemNames;
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
in {
  devShells = forAllSystems (system: let
    pkgs = pkgsFor system;
    shells = import (libraries.relativeToRoot "dev-shells") {
      inherit pkgs system;
      inherit (self) inputs;
    };
    mkShell = shell:
      pkgs.mkShell (shell
        // {
          buildInputs = shell.packages or [];
        });
    allShells =
      shells.shells or (throw ''
        No shells defined in dev-shells/default.nix.
        Please ensure you have a 'shells' attribute in your shell definitions.
      '');
  in
    builtins.mapAttrs (name: shell: mkShell shell) allShells);
  overlays = import (libraries.relativeToRoot "overlays");
  packages = forAllSystems (system: let
    pkgs = pkgsFor system;
  in {
    default = self.packages.${system}.hello;
    hello = pkgs.hello.overrideAttrs (old: {
      meta =
        old.meta
        // {
          description = "A friendly program that prints a greeting";
          longDescription = ''
            GNU Hello is a program that prints a friendly greeting.
            This is an example package for the Nix flake.
          '';
        };
    });
  });
  formatter = forAllSystems (system: (pkgsFor system).alejandra);
  checks = forAllSystems (system: let
    pkgs = pkgsFor system;
    allChecks = import (libraries.relativeToRoot "checks") {
      inherit pkgs system;
      inherit (self) inputs;
      inherit self;
    };
  in
    allChecks);
  nixosConfigurations = {};
  darwinConfigurations = lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);
}
