{
  lib,
  pkgs,
  ...
}: let
  root = ../../modules/common/ai-tools;
  entries = builtins.readDir (root + "/skills");
  names = builtins.attrNames entries;
  # Only authored folders carry our metadata contract; upstream is packaged.
  expected = ["aytordev-pen-ops" "dotfiles-coder" "nix" "skill-creator" "skill-registry"];
  published = lib.sort builtins.lessThan (expected ++ ["impeccable"]);
  catalog = import (root + "/catalog.nix");
  expectedKinds = {
    aytordev-pen-ops = "adapted";
    dotfiles-coder = "local";
    impeccable = "upstream";
    nix = "local";
    skill-creator = "adapted";
    skill-registry = "adapted";
  };
  # Independent expectations: comparison evidence never becomes a sync baseline.
  expectedOrigins = {
    aytordev-pen-ops = {
      repository = "https://github.com/Nisus74/pencil-skill";
      path = "skills/pencil-design/SKILL.md";
      baseline = {
        role = "concept-adaptation";
        revision = "28ec61cefe3000a59bdac6b98b83168dbacca9c8";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    dotfiles-coder = null;
    nix = null;
    skill-creator = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-creator/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    skill-registry = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-registry/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
  };
  # Data only: no module arguments, derivations, functions, or store contexts.
  pureData = value:
    if builtins.isAttrs value
    then !(value ? type && value.type == "derivation") && lib.all pureData (builtins.attrValues value)
    else if builtins.isList value
    then lib.all pureData value
    else if builtins.isString value
    then !(builtins.hasContext value)
    else value == null || builtins.isPath value;
  keysAre = keys: value: builtins.isAttrs value && builtins.attrNames value == lib.sort builtins.lessThan keys;
  validEntry = name: entry:
    keysAre (["kind" "source" "update" "tracking" "provenance"]
      ++ (
        if name == "impeccable"
        then ["engine" "dependencies"]
        else ["origin"]
      ))
    entry
    && entry.kind == expectedKinds.${name}
    && entry.tracking == null
    && builtins.isPath entry.provenance
    && builtins.pathExists entry.provenance
    && (
      if name == "impeccable"
      then
        keysAre ["package" "subdir" "payloadPath" "owner" "repo" "version" "rev" "hash"] entry.source
        && entry.source.package == "impeccable-skills"
        && entry.source.subdir == "share/impeccable"
        && entry.update == "manual-pinned"
        && entry.dependencies == ["impeccable-engine"]
        && entry.source.payloadPath == ".pi/skills/impeccable"
        && keysAre ["package" "version" "assets" "release"] entry.engine
        && entry.engine.package == "impeccable-engine"
      else
        keysAre ["path"] entry.source
        && entry.origin == expectedOrigins.${name}
        && entry.source.path == root + "/skills/${name}"
        && builtins.pathExists (entry.source.path + "/SKILL.md")
        && entry.update
        == (
          if entry.kind == "adapted"
          then "manual-adaptation"
          else "manual-local"
        )
    );
  catalogShape = value:
    keysAre published value
    && pureData value
    && lib.all (name: validEntry name value.${name}) published;
  doc = builtins.readFile (root + "/AGENTS.md");
  rows = lib.filter (line: lib.hasPrefix "| " line && !(lib.hasPrefix "| Name " line)) (lib.splitString "\n" doc);
  documented = map (row: lib.trim (builtins.elemAt (lib.splitString "|" row) 1)) rows;
in
  assert lib.assertMsg (builtins.pathExists (root + "/catalog.nix")) "AI skill ownership requires a pure six-entry catalog";
  assert lib.assertMsg (catalogShape catalog) "AI skill catalog ownership, structured origins/tracking, payload location, or pure-data shape drifted";
  # Triangulation: reject plausible ownership/metadata mistakes, not just omissions.
  assert lib.assertMsg (lib.all (value: !(catalogShape value)) [
    (builtins.removeAttrs catalog ["nix"])
    (catalog // {extra = catalog.nix;})
    (catalog // {nix = catalog.nix // {kind = "adapted";};})
    (catalog // {nix = catalog.nix // {description = "duplicated frontmatter";};})
    (catalog // {nix = catalog.nix // {source = {path = root + "/skills/dotfiles-coder";};};})
    (catalog // {impeccable = catalog.impeccable // {dependencies = [];};})
    (catalog // {nix = catalog.nix // {update = _: "automatic";};})
    (catalog // {skill-creator = catalog.skill-creator // {tracking = "main";};})
    (catalog // {skill-creator = catalog.skill-creator // {origin = catalog.skill-creator.origin // {lastSyncRevision = catalog.skill-creator.origin.baseline.revision;};};})
    (catalog // {nix = catalog.nix // {origin = catalog.skill-creator.origin;};})
    (catalog // {impeccable = catalog.impeccable // {source = catalog.impeccable.source // {payloadPath = "skills/impeccable";};};})
  ]) "Catalog shape must reject invalid ownership fixtures";
  assert lib.assertMsg (names == expected) "Expected exactly five authored local skills";
  assert lib.assertMsg (lib.sort builtins.lessThan documented == published) "Expected five local skills plus upstream impeccable in the documented inventory";
  assert lib.all (path: !(builtins.pathExists (root + "/${path}"))) ["default.nix" "agents.nix" "commands.nix" "roles.nix" "registry.nix" "base.md"];
    pkgs.runCommand "ai-tools-inventory-check" {} ''
      touch "$out"
    ''
