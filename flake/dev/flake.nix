{
  description = "Dev inputs for development. Not in consumers' lock files.";

  inputs = {
    root = {
      url = "path:./../..";
      inputs = {
        # Disable inputs not needed for development environment
        secrets.follows = "";
        sops-nix.follows = "";
        yazi-flavors.follows = "";
        nix-rosetta-builder.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        nixpkgs-darwin.follows = "";
        nixpkgs-stable.follows = "";
      };
    };
    nixpkgs.follows = "root/nixpkgs";
    nixpkgs-unstable.follows = "root/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
  };

  # This flake is only used for its inputs
  outputs = _: {};
}
