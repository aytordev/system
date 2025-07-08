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
          # Common modules
          ## System modules
          "modules/darwin/nix/default.nix"
          "modules/darwin/system/fonts/default.nix"
          "modules/darwin/system/interface/default.nix"
          "modules/darwin/system/input/default.nix"
          "modules/darwin/system/networking/default.nix"

          ## Security
          "modules/darwin/security/sops/default.nix"
          "modules/darwin/security/sudo/default.nix"

          ## Services
          "modules/darwin/services/openssh/default.nix"

          ## Tools
          "modules/darwin/tools/homebrew/default.nix"

          ## User
          "modules/darwin/user/default.nix"

          # Applications
          ## Terminal tools
          "modules/darwin/applications/terminal/tools/ssh/default.nix"
        ]
        ++ [
          inputs.sops-nix.darwinModules.sops
        ])
      # Additional modules can be added here
      ++ (map libraries.relativeToRoot [
        # Host-specific system configuration
        "supported-systems/aarch64-darwin/src/wang-lin/system/default.nix"
      ]);

    # User-level modules (Home Manager configuration)
    home-modules =
      (map libraries.relativeToRoot [
        # Common modules
        "modules/home/user/default.nix"
        "modules/darwin/home/default.nix"

        # Applications
        ## Terminal tools
        "modules/home/applications/terminal/tools/git/default.nix"
      ])
      ++ (map libraries.relativeToRoot [
        # Host-specific user configuration
        "homes/aarch64-darwin/aytordev@wang-lin/default.nix"
      ]);
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
