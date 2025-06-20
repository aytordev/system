# Checks configuration for the NixOS flake
# This module dynamically imports all check modules from subdirectories
# and combines them into a single attribute set.

{ pkgs, self, ... } @ args:

let
  # Read the current directory contents
  currentDir = builtins.readDir ./.;
  
  # Function to check if a directory entry is a valid check
  isCheckDir = name: 
    let 
      entryType = currentDir.${name} or "";
      isDir = entryType == "directory";
      hasDefaultNix = isDir && builtins.pathExists (./. + "/${name}/default.nix");
    in
      isDir && hasDefaultNix;
  
  # Get all valid check directories
  checkDirs = builtins.filter isCheckDir (builtins.attrNames currentDir);
  
  # Import a check module
  importCheck = name: {
    inherit name;
    value = import (./. + "/${name}/default.nix") args;
  };

  # Import all check modules and convert to attribute set
  importedChecks = map importCheck checkDirs;
  
in builtins.listToAttrs importedChecks
