{lib, ...}: {
  relativeToRoot = path: let
    repoRoot = builtins.toString ../../.;
    joinPath = a: b: let
      aStr =
        if builtins.isPath a
        then builtins.toString a
        else a;
      bStr =
        if builtins.isPath b
        then builtins.toString b
        else b;
      aEndsWithSlash = lib.strings.hasSuffix "/" aStr;
      bStartsWithSlash = lib.strings.hasPrefix "/" bStr;
      needsSeparator = !aEndsWithSlash && !bStartsWithSlash && aStr != "" && bStr != "";
    in
      if aStr == ""
      then bStr
      else if bStr == ""
      then aStr
      else if needsSeparator
      then "${aStr}/${bStr}"
      else aStr + bStr;
    pathStr =
      if builtins.isPath path
      then builtins.toString path
      else path;
    resolvedPath =
      if builtins.isString pathStr
      then
        if lib.strings.hasPrefix "/" pathStr
        then
          pathStr
        else
          joinPath repoRoot pathStr
      else if builtins.isList pathStr
      then
        if pathStr == []
        then throw "relativeToRoot: path component list cannot be empty"
        else lib.foldl' joinPath repoRoot pathStr
      else
        throw ''
          relativeToRoot: Invalid path type
          Expected: String | Path | [String | Path]
          Got: ${builtins.typeOf path}
          Value: ${builtins.toJSON path}
        '';
  in
    if builtins.isPath path
    then builtins.toPath resolvedPath
    else resolvedPath;
}
