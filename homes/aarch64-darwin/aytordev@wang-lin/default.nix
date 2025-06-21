# Home Manager configuration for aytordev@wang-lin
#
# This module defines the home configuration for user 'aytordev' on the 'wang-lin' host.
# It's part of the system's modular configuration and is imported by the system's home configuration.

{ config, lib, ... }:

let
  # Shorthand for the home configuration
  cfg = config.home;
in {
  # Module options
  options.home = with lib.types; {
    enable = lib.mkEnableOption (lib.mdDoc "home configuration for aytordev");
  };

  # Module implementation
  config = lib.mkIf cfg.enable {
    # Home Manager configuration version
    #
    # Important: This value should not be changed unless you know what you're doing.
    # It determines the version of Home Manager to be compatible with.
    home.stateVersion = "25.11";

    # User-specific packages and configurations can be added here.
    # Example:
    # home.packages = with pkgs; [ git vim ];
    #
    # programs.git = {
    #   enable = true;
    #   userName = "Your Name";
    #   userEmail = "your.email@example.com";
    # };
  };
}
