{ lib, ... }:
let
  templatesPath = ../../../templates;

  scanTemplates =
    dirPath:
    let
      entries = builtins.readDir dirPath;
      templateDirs = lib.filterAttrs (
        name: type: type == "directory" && name != ".git"
      ) entries;
    in
    lib.mapAttrs (name: _: {
      path = dirPath + "/${name}";
      description = "${name} template";
    }) templateDirs;

  allTemplates = scanTemplates templatesPath;
in
{
  flake.templates = lib.mapAttrs (_name: template: {
    inherit (template) path description;
  }) allTemplates;
}
