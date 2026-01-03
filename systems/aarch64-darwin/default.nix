{
  lib,
  inputs,
  ...
} @ args: let
  isDirectory = path: builtins.pathExists path && (builtins.readFileType path) == "directory";
  safeReadDir = path:
    if builtins.pathExists path
    then builtins.readDir path
    else {};
  findHostConfigs = dir: let
    entries = safeReadDir dir;
    isHostDir = name: (entries.${name} or "") == "directory";
    hostDirs = lib.filter isHostDir (builtins.attrNames entries);
    importHost = name: let
      path = dir + "/${name}";
      config =
        if isDirectory path
        then import (path + "/default.nix") (args // {hostDir = path;})
        else throw "Host directory '${name}' does not contain a default.nix";
    in
      config.darwinConfigurations or {};
    mergeConfigs = acc: name: let
      hostConfig = importHost name;
    in
      if !(builtins.isAttrs hostConfig)
      then throw "Host '${name}' must export a darwinConfigurations attribute set"
      else lib.recursiveUpdate acc hostConfig;
  in
    lib.foldl' mergeConfigs {} hostDirs;
in {
  darwinConfigurations =
    if !(isDirectory ./src)
    then {}
    else findHostConfigs ./src;
}
