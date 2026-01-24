{
  self,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, config, lib, ... }:
    let
      # Define common packages that should be in all shells
      commonPackages = with pkgs; [
        git
        git-lfs
        gh
        nixpkgs-fmt
        statix
        deadnix
        jq
        yq-go
        htop
        file
        tree
      ];

      # Path to the dev-shells directory
      shellsPath = ../../../dev-shells;

      # Filter for directories that contain a default.nix
      isShellDir = name: type:
        type == "directory" && builtins.pathExists (shellsPath + "/${name}/default.nix");

      # Get list of valid shell directories
      shellDirs = lib.filterAttrs isShellDir (builtins.readDir shellsPath);
      shellNames = lib.attrNames shellDirs;

      # Custom mkShell wrapper that injects common packages and pre-commit hooks
      mkShell = shellAttrs:
        pkgs.mkShell (shellAttrs // {
          nativeBuildInputs = (shellAttrs.nativeBuildInputs or []) ++ commonPackages ++ [ pkgs.pre-commit ];
          packages = shellAttrs.packages or [];
          shellHook = (shellAttrs.shellHook or "") + "\n" + config.pre-commit.installationScript;
        });

      # Function to import and build a single shell
      buildShell = name: _: {
        ${name} = import (shellsPath + "/${name}/default.nix") {
          inherit pkgs mkShell shellNames;
          inherit (self) inputs;
        };
      };

    in
    {
      devShells = lib.foldl (acc: name: acc // buildShell name null) {} shellNames;
    };
}
