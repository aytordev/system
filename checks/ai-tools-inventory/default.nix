{
  lib,
  pkgs,
  ...
}: let
  # Source of truth is the on-disk tree under modules/common/ai-tools.
  aiToolsPath = ../../modules/common/ai-tools;

  # --- Derive the real inventory from disk, one kind at a time -----------

  # skills/: each subdir (except _shared) with a SKILL.md is a skill.
  skillsDir = aiToolsPath + "/skills";
  skillsEntries = builtins.readDir skillsDir;
  skillNames = builtins.filter (name: name != "_shared") (
    builtins.filter (
      name: skillsEntries.${name} == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md")
    ) (builtins.attrNames skillsEntries)
  );

  # commands/<category>/<name>.nix and agents/<category>/<name>.nix — every
  # regular .nix file in a category directory is one entry of that kind.
  namesInCategories = dir: suffix: let
    entries = builtins.readDir dir;
    categories = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
  in
    lib.concatMap (
      category: let
        catEntries = builtins.readDir (dir + "/${category}");
        files =
          builtins.filter
          (file: catEntries.${file} == "regular" && lib.hasSuffix suffix file)
          (builtins.attrNames catEntries);
      in
        builtins.map (file: lib.removeSuffix suffix file) files
    )
    categories;

  commandNames = namesInCategories (aiToolsPath + "/commands") ".nix";
  agentNames = namesInCategories (aiToolsPath + "/agents") ".nix";

  # --- Parse the documented inventory, one section per kind --------------

  agentsDoc = builtins.readFile (aiToolsPath + "/AGENTS.md");

  inventorySection = let
    parts = lib.splitString "## Current Inventory" agentsDoc;
  in
    if lib.length parts >= 2
    then lib.elemAt parts 1
    else "";

  # The inventory keeps one `### <Kind>` subsection per resource kind. Splitting
  # on the marker isolates each table so a name in one kind can never satisfy
  # another kind.
  subsections = lib.splitString "### " inventorySection;

  documentedNames = kind: let
    matches = builtins.filter (section: lib.hasPrefix kind section) subsections;
    section =
      if matches == []
      then ""
      else builtins.head matches;
    lines = lib.splitString "\n" section;
    tableRows = builtins.filter (line: lib.hasPrefix "| " line) lines;
    firstCell = row: let
      cells = builtins.filter (cell: cell != "") (lib.splitString "|" row);
    in
      if lib.length cells >= 1
      then lib.trim (builtins.elemAt cells 0)
      else "";
  in
    lib.unique (
      builtins.filter
      (name: name != "" && name != "Name" && !(lib.hasPrefix "---" name))
      (builtins.map firstCell tableRows)
    );

  # --- Compare per kind ---------------------------------------------------

  # Comparing each kind against its own documented table means a command can no
  # longer mask a missing same-named skill (ADR 0015 F7).
  compareKind = kind: real: documented: let
    missingFromDoc = builtins.filter (name: !(lib.elem name documented)) real;
    staleInDoc = builtins.filter (name: !(lib.elem name real)) documented;
  in
    builtins.map (name: "  + ${kind}: on disk but not documented: ${name}") missingFromDoc
    ++ builtins.map (name: "  - ${kind}: documented but not on disk: ${name}") staleInDoc;

  kinds = {
    agents = {
      real = agentNames;
      documented = documentedNames "Agents";
    };
    commands = {
      real = commandNames;
      documented = documentedNames "Commands";
    };
    skills = {
      real = skillNames;
      documented = documentedNames "Skills";
    };
  };

  problems = lib.concatMap (kind: compareKind kind kinds.${kind}.real kinds.${kind}.documented) (builtins.attrNames kinds);

  # Self-test (pure): when the skills table documents a skill, a same-named
  # command is on disk, but the skill itself is missing, the old union check
  # passed while the per-kind check must fail. Guards against a regression to
  # the masking behavior.
  maskedSkillSelfTest = let
    realSkills = [];
    realCommands = ["sdd-onboard"];
    documentedSkills = ["sdd-onboard"];
    unionWouldPass =
      builtins.filter (name: !(lib.elem name (documentedSkills ++ realCommands))) (realSkills ++ realCommands)
      == []
      && builtins.filter (name: !(lib.elem name (realSkills ++ realCommands))) (documentedSkills ++ realCommands)
      == [];
    perKindFinds = compareKind "skills" realSkills documentedSkills != [];
  in
    unionWouldPass && perKindFinds;
in
  if !maskedSkillSelfTest
  then throw "ai-tools inventory self-test failed: per-kind comparison did not detect a command masking a missing skill"
  else if problems == []
  then
    pkgs.runCommand "ai-tools-inventory-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["AI tooling inventory drift in modules/common/ai-tools/AGENTS.md"]
      ++ problems
      ++ ["Update the Current Inventory tables in modules/common/ai-tools/AGENTS.md."]
    ))
