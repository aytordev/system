{
  description = "Dev inputs for development. Not in consumers' lock files.";

  inputs = {
    root.url = "path:./../..";
    nixpkgs.follows = "root/nixpkgs";
    nixpkgs-unstable.follows = "root/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # This flake is only used for its inputs
  outputs = _: { };
}
