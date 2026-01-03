{
  inputs,
  self,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inherit (lib)
    genAttrs
    filterAttrs
    hasPrefix
    hasSuffix
    ;

  getNixFiles' =
    dirPath:
    let
      entries = builtins.readDir dirPath;
    in
    lib.filter (name: hasSuffix ".nix" name) (builtins.attrNames entries);

  mergeAttrs' = attrsList: lib.foldl' (acc: attrs: acc // attrs) { } attrsList;
in
{
  /**
    Read a file and return its contents.
  */
  readFile = filePath: builtins.readFile filePath;

  /**
    Check if a file exists.
  */
  pathExists = filePath: builtins.pathExists filePath;

  /**
    Import a nix file with error handling.
  */
  safeImport = filePath: default: if builtins.pathExists filePath then import filePath else default;

  /**
    Scan a directory and return directory names.
  */
  scanDir = dirPath: builtins.attrNames (builtins.readDir dirPath);

  /**
    Get a file path relative to the flake root.
  */
  getFile = relativePath: self + "/${relativePath}";

  /**
    Get all .nix files from a directory.
  */
  getNixFiles = getNixFiles';

  /**
    Merge a list of attribute sets into a single attribute set.
  */
  mergeAttrs = mergeAttrs';

  /**
    Import all .nix files from a directory.
  */
  importFiles =
    dirPath: args:
    let
      nixFiles = getNixFiles' dirPath;
    in
    map (name: import (dirPath + "/${name}") args) nixFiles;

  /**
    Import all .nix files from a directory and merge them.
  */
  importDir =
    dirPath: args:
    let
      nixFiles = getNixFiles' dirPath;
      imported = map (name: import (dirPath + "/${name}") args) nixFiles;
    in
    mergeAttrs' imported;

  /**
    Recursively discover and import all Nix modules in a directory tree.
    Returns a list of paths to directories containing default.nix.
  */
  importModulesRecursive =
    dirPath:
    let
      walkDir =
        currentPath:
        let
          currentEntries = builtins.readDir currentPath;
          entryNames = builtins.attrNames currentEntries;

          # Get directories that contain default.nix
          directoriesWithDefault = lib.filter (
            name:
            currentEntries.${name} == "directory" && builtins.pathExists (currentPath + "/${name}/default.nix")
          ) entryNames;

          # Get ALL directories (to recurse into)
          allDirectories = builtins.filter (name: currentEntries.${name} == "directory") entryNames;

          # Import directories that have default.nix
          directoryImports = map (name: currentPath + "/${name}") directoriesWithDefault;

          # Recursively walk ALL subdirectories
          subDirImports = builtins.concatLists (map (dir: walkDir (currentPath + "/${dir}")) allDirectories);
        in
        directoryImports ++ subDirImports;
    in
    walkDir dirPath;

  /**
    Recursively parse systems directory structure.
  */
  parseSystemConfigurations =
    systemsPath:
    let
      entries = builtins.readDir systemsPath;
      systemArchs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      generateSystemConfigs =
        system:
        let
          systemPath = systemsPath + "/${system}";
          hosts = builtins.attrNames (builtins.readDir systemPath);
        in
        genAttrs hosts (hostname: {
          inherit system hostname;
          path = systemPath + "/${hostname}";
        });
    in
    builtins.foldl' (acc: system: acc // generateSystemConfigs system) { } systemArchs;

  /**
    Filter systems for NixOS (Linux).
  */
  filterNixOSSystems =
    systems:
    filterAttrs (
      _name: { system, ... }: hasPrefix "x86_64-linux" system || hasPrefix "aarch64-linux" system
    ) systems;

  /**
    Filter systems for Darwin (macOS).
  */
  filterDarwinSystems =
    systems:
    filterAttrs (
      _name: { system, ... }: hasPrefix "aarch64-darwin" system || hasPrefix "x86_64-darwin" system
    ) systems;

  /**
    Parse homes directory structure for home configurations.
  */
  parseHomeConfigurations =
    homesPath:
    let
      entries = builtins.readDir homesPath;
      systemArchs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      generateHomeConfigs =
        system:
        let
          systemPath = homesPath + "/${system}";
          userAtHosts = builtins.attrNames (builtins.readDir systemPath);

          parseUserAtHost =
            userAtHost:
            let
              # Split "username@hostname" into parts
              parts = builtins.split "@" userAtHost;
              username = builtins.head parts;
              hostname = builtins.elemAt parts 2; # After split: [username, "@", hostname]
            in
            {
              inherit
                system
                username
                hostname
                userAtHost
                ;
              path = systemPath + "/${userAtHost}";
            };
        in
        genAttrs userAtHosts parseUserAtHost;
    in
    builtins.foldl' (acc: system: acc // generateHomeConfigs system) { } systemArchs;
}
