{ pkgs, system, inputs, ... }:

let
  # Import a shell file and pass necessary arguments
  importShell = name: path: {
    name = builtins.elemAt (pkgs.lib.strings.splitString "." (baseNameOf path)) 0;
    value = import path { inherit pkgs system inputs; };
  };

  # Get all .nix files except default.nix
  shellFiles = builtins.filter
    (f: f != "default.nix" && pkgs.lib.strings.hasSuffix ".nix" f)
    (builtins.attrNames (builtins.readDir ./.));

  # Create attribute set of all shells
  allShells = builtins.listToAttrs
    (map (f: importShell f (./. + "/${f}")) shellFiles);

  # Common packages for all shells
  commonPackages = with pkgs; [
    # Version control
    git
    git-lfs
    gh
    
    # Nix development
    nixpkgs-fmt
    statix
    deadnix
    
    # Shell tools
    jq
    yq-go
    htop
    file
    tree
  ];

in {
  # All individual shells with common packages
  shells = pkgs.lib.mapAttrs (_: shell: 
    shell // {
      packages = (shell.packages or []) ++ commonPackages;
    }
  ) allShells;

  # Default shell with list of available shells
  default = {
    name = "default";
    packages = commonPackages;
    shellHook = ''
      echo -e "\n\033[1;32m🚀 Default Development Shell\033[0m"
      echo "Available shells: ${toString (builtins.attrNames allShells)}"
      echo "Enter a specific shell with: nix develop .#<shell-name>"
      echo ""
    '';
  };
}
