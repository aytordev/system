{
  #############################################################################
  # Metadata
  #############################################################################
  description = "Ryan Yin's nix configuration for both NixOS & macOS";

  #############################################################################
  # Outputs
  #
  # All system outputs are defined in outputs/default.nix for better
  # organization and maintainability.
  #############################################################################

  outputs = inputs: import ./outputs/default.nix inputs;

  # Nix configuration for the flake itself (not the system configuration)
  # This affects how Nix fetches dependencies and caches
  # Documentation: https://nixos.org/manual/nix/stable/command-ref/conf-file.html
  #############################################################################
  nixConfig = {
    # Binary cache servers for faster package downloads.
    # These provide pre-built binaries to avoid local compilation.
    extra-substituters = [
      "https://anyrun.cachix.org" # Cache for the anyrun application
    ];

    # Public keys for verifying the authenticity of cached binaries.
    # These must match the signatures of the binary caches listed above.
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };

  #############################################################################
  # Flake Inputs
  #
  # Dependencies of this configuration. Each input will be passed to the
  # outputs function after being fetched.
  #
  # Format: github:owner/repo/ref  (where ref can be a branch, tag, or commit hash)
  #
  # To update inputs, run: nix flake update
  # To update a specific input: nix flake lock --update-input <input-name>
  #############################################################################
  inputs = {
    # =========================================================================
    # Core Package Collections
    # =========================================================================

    # Primary package collection (unstable channel)
    # Contains the latest package versions but may be less stable
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # Additional nixpkgs channels for specific version requirements
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable"; # Alias for nixpkgs (unstable)
    };

    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-25.05"; # Stable release channel
    };

    nixpkgs-ollama = {
      url = "github:nixos/nixpkgs/nixos-unstable"; # For Ollama-specific packages
    };

    # macOS-specific packages and configurations
    nixpkgs-darwin = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    # =========================================================================
    # System Management
    # =========================================================================

    # nix-darwin: Manage macOS system configuration declaratively
    # This extends NixOS-like functionality to macOS
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      # Use macOS-specific nixpkgs for better compatibility
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Home Manager: Manage user-specific configuration and packages
    # Handles user environment, dotfiles, and user services
    home-manager = {
      url = "github:nix-community/home-manager";
      # Alternative stable version (uncomment to use instead):
      # url = "github:nix-community/home-manager/release-25.05";
      # Use main nixpkgs for consistency
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # =========================================================================
    # Development & Tooling
    # =========================================================================
    # Note: Haumea was removed in favor of native Nix module loading
  };
}
