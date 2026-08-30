{
  lib,
  pkgs,
  ...
}: let
  # Source of truth is the on-disk tree under modules/common/ai-tools.
  aiToolsPath = ../../modules/common/ai-tools;

  # --- Derive the real inventory from disk -------------------------------

  # skills/: each subdir (except _shared) with a SKILL.md is a skill.
  skillsDir = aiToolsPath + "/skills";
  skillsEntries = builtins.readDir skillsDir;
  skillNames = builtins.filter (name: name != "_shared") (
    builtins.filter (
      name: skillsEntries.${name} == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md")
    ) (builtins.attrNames skillsEntries)
  );

  # commands/<category>/<name>.nix — every .nix file is a slash command.
  commandsDir = aiToolsPath + "/commands";
  commandNames = builtins.filter (name: name != "") (
    lib.concatMap (
      cat: let
        catEntries = builtins.readDir (commandsDir + "/${cat}");
      in
        builtins.map (
          f:
            if catEntries.${f} == "regular" && lib.hasSuffix ".nix" f
            then lib.removeSuffix ".nix" f
            else ""
        ) (builtins.attrNames catEntries)
    ) (lib.attrNames (builtins.readDir commandsDir))
  );

  # agents/<category>/<name>.nix — every .nix file is an agent.
  agentsDir = aiToolsPath + "/agents";
  agentNames = builtins.filter (name: name != "") (
    lib.concatMap (
      cat: let
        catEntries = builtins.readDir (agentsDir + "/${cat}");
      in
        builtins.map (
          f:
            if catEntries.${f} == "regular" && lib.hasSuffix ".nix" f
            then lib.removeSuffix ".nix" f
            else ""
        ) (builtins.attrNames catEntries)
    ) (lib.attrNames (builtins.readDir agentsDir))
  );

  # --- Parse the documented inventory from ai-tools/AGENTS.md -------------

  agentsDoc = builtins.readFile (aiToolsPath + "/AGENTS.md");
  # A documented entry is any table row where the first cell is a bare name.
  # Cells are `<name> | <category> | <description>` inside "Current Inventory".
  inventorySection = let
    parts = lib.splitString "## Current Inventory" agentsDoc;
  in
    if lib.length parts >= 2
    then lib.elemAt parts 1
    else "";
  # Extract names from the tables that follow (skip the section header rows).
  tableRows = lib.filter (line: lib.hasPrefix "| " line) (lib.splitString "\n" inventorySection);
  documentedNames = lib.unique (
    lib.filter
    (n: n != "" && !(lib.hasPrefix "---" n) && !(lib.hasPrefix "|" n) && !(lib.hasPrefix "Name" n))
    (
      lib.concatMap (
        row: let
          cells = lib.filter (c: c != "") (lib.splitString "|" row);
        in
          if lib.length cells >= 1
          then [(lib.trim (lib.elemAt cells 0))]
          else []
      )
      tableRows
    )
  );

  # --- Compare ------------------------------------------------------------

  real = skillNames ++ commandNames ++ agentNames;
  missingFromDoc = builtins.filter (n: !(lib.elem n documentedNames)) real;
  staleInDoc = builtins.filter (n: !(lib.elem n real)) documentedNames;

  message = lib.concatLists [
    ["AI tooling inventory drift in modules/common/ai-tools/AGENTS.md"]
    ["On disk but not documented:"]
    (builtins.map (n: "  + ${n}") missingFromDoc)
    ["Documented but not on disk:"]
    (builtins.map (n: "  - ${n}") staleInDoc)
    ["Update the Current Inventory tables in modules/common/ai-tools/AGENTS.md."]
  ];
in
  if missingFromDoc == [] && staleInDoc == []
  then
    pkgs.runCommand "ai-tools-inventory-check" {} ''
      touch "$out"
    ''
  else throw (builtins.concatStringsSep "\n" message)
