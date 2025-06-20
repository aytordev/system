# aarch64-darwin/default.nix
#
# @summary Load and merge all aarch64-darwin host configurations
# @version 1.0.0
#
# This module discovers and merges all host configurations from the src/ directory.
# Each host should be in its own subdirectory with a default.nix file that exports
# a `darwinConfigurations` attribute set.
#
# @param lib The Nixpkgs library
# @param inputs Flake inputs
# @param ... Additional arguments passed to host configurations
# @return An attribute set with merged darwinConfigurations
#
# Version: 2.0.0
# Last Updated: 2025-06-20
{
  lib,
  inputs,
  ...
} @ args: let
  # @summary Check if a path exists and is a directory
  # @param path Path to check
  # @return Boolean indicating if the path is a directory
  isDirectory = path: builtins.pathExists path && (builtins.readFileType path) == "directory";

  # @summary Safely read a directory, returning an empty set if it doesn't exist
  # @param path Path to the directory
  # @return Attribute set of directory entries or empty set
  safeReadDir = path:
    if builtins.pathExists path
    then builtins.readDir path
    else {};

  # @summary Find all host configurations in a directory
  # @param dir Path to the directory containing host configurations
  # @return Attribute set of merged darwinConfigurations
  findHostConfigs = dir: let
    entries = safeReadDir dir;
    isHostDir = name: (entries.${name} or "") == "directory";
    hostDirs = lib.filter isHostDir (builtins.attrNames entries);

    # @summary Import a single host configuration
    # @param name Name of the host directory
    # @return The host's darwinConfigurations or empty set
    importHost = name: let
      path = dir + "/${name}";
      config =
        if isDirectory path
        then import (path + "/default.nix") (args // {hostDir = path;})
        else throw "Host directory '${name}' does not contain a default.nix";
    in
      config.darwinConfigurations or {};

    # @summary Merge configurations with error checking
    # @param acc Accumulator for the merge
    # @param name Name of the host being merged
    # @return New accumulator with merged configurations
    mergeConfigs = acc: name: let
      hostConfig = importHost name;
    in
      if !(builtins.isAttrs hostConfig)
      then throw "Host '${name}' must export a darwinConfigurations attribute set"
      else lib.recursiveUpdate acc hostConfig;
  in
    lib.foldl' mergeConfigs {} hostDirs;
in {
  # Discover and merge all host configurations
  darwinConfigurations =
    if !(isDirectory ./src)
    then {}
    else findHostConfigs ./src;
}
