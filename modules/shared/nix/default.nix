# Nix Package Manager Configuration
#
# This module configures the Nix package manager with secure defaults and
# performance optimizations. It sets up essential Nix settings, manages
# garbage collection, and configures the Nix daemon.
#
# Version: 1.0.0
# Last Updated: 2025-06-15
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Primary system user with Nix access
  #
  # Type: string
  #
  # The username is imported from the project's variables
  primaryUser = config.system.primaryUser;

  # Users and groups with Nix daemon access
  #
  # Type: listOf string
  #
  # Defines which users and groups can interact with the Nix daemon.
  # Includes system users, wheel group, and the primary user.
  allowedUsers = [
    "root"
    "@wheel"
    "nix-builder"
    primaryUser
  ];

  # Essential Nix-related packages
  #
  # Type: listOf package
  #
  # Core utilities that enhance the Nix experience:
  # - deploy-rs: For remote deployment of NixOS systems
  # - git: Version control for Nix flake management
  # - nix-prefetch-git: For fetching Git repositories with Nix
  essentialPackages = with pkgs; [
    deploy-rs
    git
    nix-prefetch-git
  ];

  # Nix daemon configuration
  #
  # Type: AttrSet
  #
  # Global settings for the Nix daemon that affect all operations.
  # Includes security, performance, and resource management settings.
  nixDaemonSettings = {
    # Security settings
    allowed-users = allowedUsers;
    trusted-users = allowedUsers;
    sandbox = true;

    # Performance optimizations
    auto-optimise-store = pkgs.stdenv.hostPlatform.isLinux;
    builders-use-substitutes = true;
    http-connections = 50;

    # Resource management
    keep-derivations = true;
    keep-going = true;
    keep-outputs = true;
    log-lines = 50;

    # User experience
    use-xdg-base-directories = true;
    warn-dirty = false;
    experimental-features = ["nix-command" "flakes"];
  };
in {
  # Install essential Nix-related packages
  #
  # These packages provide core functionality for working with Nix
  # and managing Nix-based systems.
  environment.systemPackages = essentialPackages;

  # Nix package manager configuration
  #
  # This section configures the core Nix package manager with
  # optimized settings for performance and reliability.
  nix = {
    # Use the latest stable Nix version
    package = pkgs.nixVersions.latest;

    # Enable configuration checking and distributed builds
    checkConfig = true;
    distributedBuilds = true;

    # Automatic garbage collection
    #
    # Configures automatic removal of old generations and
    # unused store paths to manage disk space.
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    # Automatic store optimization to reduce disk usage
    optimise.automatic = true;

    # Nix daemon settings
    settings = nixDaemonSettings;
  };
}
