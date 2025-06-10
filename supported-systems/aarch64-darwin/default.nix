# aarch64-darwin/default.nix
#
# This file serves as the entry point for loading all aarch64-darwin (Apple Silicon) host configurations.
# It uses Haumea to dynamically load all .nix files from the src/ directory and merge their
# darwinConfigurations outputs.
#
# The structure allows for easy addition of new hosts by simply adding a new .nix file to the src/ directory.
# Each file should export a darwinConfigurations attribute set that will be merged with others.
{
  lib,
  inputs,
  ...
} @ args: let
  inherit (inputs) haumea;

  # Load all .nix files from the src/ directory using Haumea
  # This dynamically discovers all host configurations
  data = haumea.lib.load {
    src = ./src; # Source directory containing host configurations
    inputs = args; # Pass through all flake inputs and other arguments
  };

  # Convert the attribute set to a list of values, discarding the file paths
  # since they're not needed in the final output
  dataWithoutPaths = builtins.attrValues data;

  # Merge all darwinConfigurations from all loaded files
  # This creates a single attribute set with all host configurations
  outputs = {
    darwinConfigurations =
      lib.attrsets.mergeAttrsList
      (map (it: it.darwinConfigurations or {}) dataWithoutPaths);
  };
in
  outputs
# Return the merged configurations for all hosts

