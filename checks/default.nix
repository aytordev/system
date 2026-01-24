{
  lib,
  ...
} @ args:
let
  checksDir = ./.;
  # Get all entries in the directory
  entries = builtins.readDir checksDir;

  # Filter for directories that contain a default.nix
  checkDirs = lib.filterAttrs (name: type:
    type == "directory" && builtins.pathExists (checksDir + "/${name}/default.nix")
  ) entries;

  # Import each check
  checks = lib.mapAttrs (name: _:
    import (checksDir + "/${name}") args
  ) checkDirs;
in
  checks
