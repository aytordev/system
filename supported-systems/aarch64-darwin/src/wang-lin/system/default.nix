# wang-lin modules configuration
#
# This file defines host-specific module configurations for the wang-lin system.
# It serves as a central place to manage and organize all module configurations
# specific to this host.
{
  lib,
  variables,
  ...
}: {
  # Add any host-specific module configurations here
  # This is a good place to set default values or overrides for modules
  # that are specific to this host.

  system.stateVersion = 6; # Match your nix-darwin version

  # Set the hostname
  system.networking.hostName = "wang-lin";
  system.networking.computerName = "Mac Studio M3 Ultra (2025)";
  system.networking.localHostName = "wang-lin";

  # Set the primary user for user-specific configurations
  system.primaryUser = variables.username;

  # Configure Homebrew
  tools.homebrew.enable = true;
}
