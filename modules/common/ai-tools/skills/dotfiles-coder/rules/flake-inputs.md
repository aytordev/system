## Input Management

**Impact:** HIGH

Inputs are categorized: core (nixpkgs, home-manager), system (hardware, sops), programs (overlays, tools). Most inputs follow `nixpkgs` via `follows`. Dev dependencies are isolated in a separate flake partition.

**Incorrect (Uncategorized Inputs):**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:Mic92/sops-nix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    # No follows, no categorization, duplicated nixpkgs
  };
}
```

**Correct (Categorized with Follows):**

```nix
{
  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Programs
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```
