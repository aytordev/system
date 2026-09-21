{
  lib,
  pkgs,
  ...
}: let
  # Source of truth is the on-disk skill tree under modules/common/ai-tools.
  skillsDir = ../../modules/common/ai-tools/skills;
  entries = builtins.readDir skillsDir;

  # Every directory is expected to be a self-contained skill package. Listing
  # them all (instead of filtering on SKILL.md) lets a missing entry point fail
  # with a named skill rather than being silently skipped.
  skillNames =
    builtins.filter
    (name: entries.${name} == "directory")
    (builtins.attrNames entries);

  # --- Frontmatter ---------------------------------------------------------
  # The authoring contract (skill-creator) defines:
  #   - SKILL.md starts with a `---` frontmatter block.
  #   - `name` equals the directory name.
  #   - `description` is one physical line, double-quoted, YAML-safe.
  isDoubleQuoted = v:
    v
    != null
    && lib.hasPrefix "\"" v
    && lib.hasSuffix "\"" v
    && lib.stringLength v >= 2
    && lib.length (lib.splitString "\"" v) == 3;

  unquoteDouble = v:
    if isDoubleQuoted v
    then lib.substring 1 (lib.stringLength v - 2) v
    else null;

  parseSkill = name: let
    skillFile = skillsDir + "/${name}/SKILL.md";
    exists = builtins.pathExists skillFile;
    content =
      if exists
      then builtins.readFile skillFile
      else "";
    parts = lib.splitString "---" content;
    hasFence = exists && lib.length parts >= 3 && lib.trim (builtins.head parts) == "";
    fmLines =
      if hasFence
      then lib.splitString "\n" (builtins.elemAt parts 1)
      else [];
    parseLine = line: let
      m = builtins.match "([A-Za-z0-9_-]+): *(.*)" line;
    in
      if m == null
      then null
      else {
        key = builtins.elemAt m 0;
        value = builtins.elemAt m 1;
      };
    pairs = lib.filter (p: p != null) (map parseLine fmLines);
    valuesOf = key: map (p: p.value) (lib.filter (p: p.key == key) pairs);
    nameValues = valuesOf "name";
    descriptionValues = valuesOf "description";
  in {
    inherit exists hasFence nameValues descriptionValues;
    name =
      if lib.length nameValues == 1
      then lib.trim (builtins.head nameValues)
      else null;
    description =
      if lib.length descriptionValues == 1
      then unquoteDouble (builtins.head descriptionValues)
      else null;
  };

  checkSkill = name: let
    fm = parseSkill name;
    metaFile = skillsDir + "/${name}/metadata.json";
    metaExists = builtins.pathExists metaFile;
    metaAttempt =
      if metaExists
      then builtins.tryEval (builtins.fromJSON (builtins.readFile metaFile))
      else {
        success = false;
        value = null;
      };
    meta =
      if metaAttempt.success
      then metaAttempt.value
      else null;
    metaIsObject = builtins.isAttrs meta;
    metaField = key:
      if metaIsObject && builtins.hasAttr key meta
      then meta.${key}
      else null;

    frontmatterProblems =
      if !fm.exists
      then ["SKILL.md is missing"]
      else
        lib.optional (!fm.hasFence) "SKILL.md is missing a '---' YAML frontmatter block"
        ++ lib.optional (lib.length fm.nameValues != 1) "frontmatter must declare exactly one 'name' field"
        ++ lib.optional (fm.name != null && fm.name != name) "frontmatter name '${fm.name}' does not match directory name '${name}'"
        ++ lib.optional (lib.length fm.descriptionValues != 1) "frontmatter must declare exactly one 'description' field"
        ++ lib.optional (lib.length fm.descriptionValues == 1 && fm.description == null)
        "description must be a single double-quoted YAML scalar on one line";

    metadataProblems =
      if !metaExists
      then ["metadata.json is missing"]
      else if !metaAttempt.success
      then ["metadata.json is not valid JSON"]
      else if !metaIsObject
      then ["metadata.json must contain a JSON object"]
      else
        lib.optional (fm.name != null && metaField "name" != fm.name)
        "metadata.json name '${toString (metaField "name")}' disagrees with SKILL.md frontmatter '${fm.name}'"
        ++ lib.optional (fm.description != null && metaField "description" != fm.description)
        "metadata.json description disagrees with SKILL.md frontmatter"
        ++ lib.optional (!(builtins.hasAttr "version" meta)) "metadata.json is missing the 'version' field"
        ++ lib.optional (!(builtins.hasAttr "organization" meta)) "metadata.json is missing the 'organization' field";
  in
    frontmatterProblems ++ metadataProblems;

  problems =
    lib.concatMap
    (name: map (problem: "  - ${name}: ${problem}") (checkSkill name))
    skillNames;
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-skill-contract-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["Skill authoring contract violations in modules/common/ai-tools/skills:"]
      ++ problems
      ++ ["Fix the offending package or update the contract in modules/common/ai-tools/skills/skill-creator."]
    ))
