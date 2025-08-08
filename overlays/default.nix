let
  currentDir = builtins.readDir ./.;
  isOverlayDir = name:
    currentDir.${name}
    == "directory"
    && builtins.pathExists (./. + "/${name}/default.nix");
  overlayDirs = builtins.filter isOverlayDir (builtins.attrNames currentDir);
  importOverlay = dir: let
    path = ./. + "/${dir}";
    overlay = import path;
  in
    if !(builtins.isFunction overlay)
    then throw "Overlay '${dir}' must evaluate to a function with signature (final: prev: { ... })"
    else overlay;
  importedOverlays = builtins.listToAttrs (
    builtins.map
    (dir: {
      name = dir;
      value = importOverlay dir;
    })
    overlayDirs
  );
in
  importedOverlays
