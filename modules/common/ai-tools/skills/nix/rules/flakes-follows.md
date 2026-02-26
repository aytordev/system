## Input Follows

**Impact:** HIGH

Use `follows` to deduplicate shared inputs (typically `nixpkgs`). This reduces closure size and ensures consistency across all inputs.

**Incorrect (Duplicated Inputs):**

Without `follows`, you get multiple copies of nixpkgs.

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # BAD - home-manager brings its own nixpkgs
    # Now you have TWO nixpkgs instances, doubling evaluation time and closure size
    home-manager.url = "github:nix-community/home-manager";

    # BAD - Each input has its own nixpkgs copy
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly }: {
    # Configuration here - but with duplicated inputs
  };
}
```

**Correct (Deduplicated):**

Always check `nix flake metadata` to audit for duplicated inputs.

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # GOOD - home-manager follows our nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GOOD - All overlays use the same nixpkgs
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GOOD - Chain follows for nested dependencies
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly, sops-nix }: {
    # Configuration with single nixpkgs instance
  };
}
```
