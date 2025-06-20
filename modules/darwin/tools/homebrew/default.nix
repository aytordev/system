# Homebrew Module
#
# This module provides configuration for the Homebrew package manager on Darwin systems.
# It sets up Homebrew with recommended settings and environment variables.
#
# ## Features
#
# - Configures Homebrew with secure defaults
# - Enables automatic updates and cleanup
# - Sets recommended environment variables
# - Supports Homebrew Bundle for declarative package management
#
# ## Options
#
# - `tools.homebrew.enable`: Enable Homebrew configuration (default: false)
#
# ## Example
#
# ```nix
# # Enable Homebrew with default settings
# tools.homebrew.enable = true;
# ```
# Version: 2.0.0
# Last Updated: 2025-06-20
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.tools.homebrew;
in {
  options.tools.homebrew = {
    enable = mkEnableOption "Homebrew package manager";
    # Note: Additional options can be added here following the pattern:
    # optionName = mkOption {
    #   type = types.bool;
    #   default = false;
    #   description = "Description of the option";
    # };
  };

  config = mkIf cfg.enable {
    # Set Homebrew environment variables for better security and user experience
    # See: https://docs.brew.sh/Manpage#environment
    environment.variables = {
      # Use bat for better paging of output
      HOMEBREW_BAT = "1";
      # Disable analytics for privacy
      HOMEBREW_NO_ANALYTICS = "1";
      # Prevent insecure redirects
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };

    # Main Homebrew configuration
    homebrew = {
      # Enable Homebrew integration
      enable = true;

      # Global Homebrew settings
      # See: https://nix-community.github.io/home-manager/options.xhtml#opt-homebrew.global
      global = {
        # Enable Brewfile support for declarative package management
        brewfile = true;
        # Automatically update Homebrew before installing packages
        autoUpdate = true;
      };

      # Configuration for Homebrew activation behavior
      # See: https://nix-community.github.io/home-manager/options.xhtml#opt-homebrew.onActivation
      onActivation = {
        # Run `brew update` before installing packages
        autoUpdate = true;
        # Clean up old versions of installed formulae and casks
        cleanup = "uninstall";
        # Upgrade all installed packages
        upgrade = true;
      };

      # Default Homebrew taps to include
      # See: https://docs.brew.sh/Taps
      taps = [
        # Required for Brewfile support
        # "homebrew/bundle" - This tap is now empty and all its contents were either deleted or migrated.
        # Required for managing services
        # "homebrew/services" - This tap is now empty and all its contents were either deleted or migrated.
      ];

      # Note: Add packages using:
      # brews = [ "package1" "package2" ];
      # casks = [ "app1" "app2" ];
    };
  };
}
