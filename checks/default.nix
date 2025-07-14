{
  pkgs,
  self,
  ...
} @ args: let
  currentDir = builtins.readDir ./.;
  isCheckDir = name: let
    entryType = currentDir.${name} or "";
    isDir = entryType == "directory";
    checkPath = ./. + "/${name}";
    hasDefaultNix = isDir && builtins.pathExists (checkPath + "/default.nix");
  in
    isDir && hasDefaultNix;
  checkDirs = builtins.filter isCheckDir (builtins.attrNames currentDir);
  importCheck = name: let
    checkPath = ./. + "/${name}";
    imported = import (checkPath + "/default.nix") args;
    isValidDerivation =
      builtins.isAttrs imported
      && (imported.type or "") == "derivation";
    errorMsg =
      "Check '${name}' in ${toString checkPath} "
      + "must evaluate to a derivation";
  in
    if !isValidDerivation
    then throw errorMsg
    else {
      inherit name;
      value = imported;
    };
  importedChecks = map importCheck checkDirs;
  result = builtins.listToAttrs importedChecks;
in
  result
