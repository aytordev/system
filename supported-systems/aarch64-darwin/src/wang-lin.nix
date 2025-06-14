# wang-lin.nix
#
# Configuration for the 'wang-lin' host (Apple Silicon Mac).
# This file defines the system configuration for a specific host, including both
# system-level and user-level settings.
#
# The configuration is split into modules for better organization and reusability.
# Common modules are imported from the shared modules directory, while host-specific
# customizations are defined inline or in separate files.
{
  # IMPORTANT: All arguments must be kept, even if not directly used in this file.
  # Haumea passes arguments lazily, and they may be used by imported modules.
  inputs,
  lib,
  libraries,
  variables,
  system,
  genSpecialArgs,
  ...
} @ args: let
  # Host identifier - should match the filename (without .nix)
  name = "wang-lin";

  # Module imports are organized by category
  modules = {
    # System-level modules (nix-darwin configuration)
    darwin-modules =
      # Convert relative paths to absolute paths using the project root
      (map libraries.relativeToRoot [
        # Common system modules

        # "modules/darwin/default.nix"
        # "modules/shared/default.nix"

        # Host-specific system configuration
        # "hosts/darwin-${name}/system.nix"

        # Secrets management
        # "secrets/darwin.nix"
      ])
      # Additional modules can be added here
      ++ [
        # Inline module example
        # {
        #   system.stateVersion = 6;  # Should match the version of nix-darwin you're using
        #   networking.hostName = name;
        # }
      ];

    # User-level modules (Home Manager configuration)
    home-modules = map libraries.relativeToRoot [
      # Common user modules
      # "home/common.nix"

      # Host-specific user configuration
      # "hosts/darwin-${name}/home.nix"

      # Desktop environment
      # "home/darwin/desktop.nix"
    ];
  };

  # Combine modules with all other arguments
  systemArgs =
    modules
    // args # This includes all the original arguments like variables, lib, etc.
    // {
      # Add any additional arguments needed by modules
      hostName = name;
    };

in {
  # The final darwin configuration for this host
  darwinConfigurations.${name} = libraries.macosSystem systemArgs;
}
