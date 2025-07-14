{lib, ...} @ args: let
  getNixFiles = dir: let
    allFiles = builtins.attrNames (builtins.readDir dir);
    isNixFileOrDir = file: let
      isNixFile = lib.strings.hasSuffix ".nix" file;
      isNotDefault = file != "default.nix";
      isDir = (builtins.readDir dir)."${file}" == "directory";
    in
      (isNixFile && isNotDefault) || isDir;
    filteredFiles = builtins.filter isNixFileOrDir allFiles;
    processSubdir = file:
      if (builtins.readDir dir)."${file}" == "directory"
      then let
        subdir = dir + "/${file}";
        subFiles = getNixFiles subdir;
      in
        builtins.map (f: "${file}/${f}") subFiles
      else [];
    subdirFiles = builtins.concatMap processSubdir filteredFiles;
    allNixFiles = filteredFiles ++ subdirFiles;
  in
    allNixFiles;
  importFile = file: let
    filePath = ./. + "/${file}";
    imported = import filePath args;
    result =
      if builtins.isFunction imported
      then imported args
      else if builtins.isAttrs imported
      then imported
      else throw "" "
            Error in ${file}:
            Imported file must return an attribute set or function that returns an attribute set.
            Got: ${builtins.typeOf imported}
          " "";
  in
    result;
  importedModules = map importFile (getNixFiles ./.);
  combinedModules = lib.foldl' lib.recursiveUpdate {} importedModules;
  publicApi = {
    inherit (combinedModules) relativeToRoot macosSystem;
    inherit lib;
    _internal = {
      inherit getNixFiles importFile;
    };
  };
in
  combinedModules // publicApi
