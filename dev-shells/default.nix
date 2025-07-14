{
  pkgs,
  system,
  inputs,
  ...
} @ args: let
  currentDir = builtins.readDir ./.;
  isShellDir = name:
    currentDir.${name}
    == "directory"
    && builtins.pathExists (./. + "/${name}/default.nix");
  shellDirs = builtins.filter isShellDir (builtins.attrNames currentDir);
  importShell = dir: let
    path = ./. + "/${dir}";
    shell = import path {inherit pkgs system inputs;};
  in
    if !(builtins.isAttrs shell)
    then throw "Shell '${dir}' must evaluate to an attribute set"
    else if !(shell ? name)
    then throw "Shell '${dir}' must have a 'name' attribute"
    else shell;
  importedShells = builtins.listToAttrs (
    builtins.map
    (dir: {
      name = dir;
      value = importShell dir;
    })
    shellDirs
  );
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
  shellsWithCommonPkgs =
    builtins.mapAttrs (
      name: shell:
        shell
        // {
          packages = (shell.packages or []) ++ commonPackages;
        }
    )
    importedShells;
  defaultShell = {
    name = "default";
    packages = commonPackages;
    shellHook = ''
      echo -e "\n\033[1;32m🚀 Default Development Shell\033[0m"
      echo "Available shells: ${toString (builtins.attrNames importedShells)}"
      echo "Enter a specific shell with: nix develop .
      echo ""
    '';
  };
in {
  shells =
    shellsWithCommonPkgs
    // {
      default = defaultShell;
    };
}
