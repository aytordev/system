{
  lib,
  pkgs,
  ...
}: let
  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  agentsDir = aiTools + "/agents";

  # Every regular file under a directory tree. Nix symlinks are resolved by
  # `readFile`, so directory walking and content reading stay consistent.
  regularFiles = dir: let
    entries = builtins.readDir dir;
    step = name: type:
      if type == "directory"
      then regularFiles (dir + "/${name}")
      else if type == "regular"
      then [(dir + "/${name}")]
      else [];
  in
    lib.concatLists (lib.mapAttrsToList step entries);

  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;

  # --- 1. Shared protocols must not present compact rules as authoritative ---
  # The migrated loading contract passes exact SKILL.md paths and reads the
  # originals. The old authoritative markers must be gone, and the new
  # path-first contract must be present.
  resolver = skillsDir + "/_shared/skill-resolver.md";
  loading = skillsDir + "/_shared/skill-loading.md";
  envelope = skillsDir + "/_shared/return-envelope.md";
  sharedProtocols = [resolver loading envelope];

  bannedAuthority = ["Project Standards" "Compact Rules"];
  authorityProblems =
    lib.concatMap
    (file:
      builtins.map
      (marker: "  - ${rel file}: shared protocol still presents '${marker}' as authoritative")
      (builtins.filter (marker: lib.hasInfix marker (text file)) bannedAuthority))
    sharedProtocols;

  pathFirstChecks = {
    resolverInjectsPaths = lib.hasInfix "Skills to load before work" (text resolver);
    loadingPrefersPaths = lib.hasInfix "Skills to load before work" (text loading);
    loadingKeepsOriginalsCanonical = lib.hasInfix "source of truth" (text loading);
    envelopeUsesPathsInjected = lib.hasInfix "paths-injected" (text envelope);
  };
  pathFirstProblems =
    lib.optional (!pathFirstChecks.resolverInjectsPaths) "  - skill-resolver.md does not inject exact skill paths"
    ++ lib.optional (!pathFirstChecks.loadingPrefersPaths) "  - skill-loading.md does not prefer injected skill paths"
    ++ lib.optional (!pathFirstChecks.loadingKeepsOriginalsCanonical) "  - skill-loading.md does not state SKILL.md is the source of truth"
    ++ lib.optional (!pathFirstChecks.envelopeUsesPathsInjected) "  - return-envelope.md does not use the paths-injected value";
  # --- 2. No local skill hardcodes the OpenCode global path ------------------
  # Client-neutral paths let the same skill package run under OpenCode and Pi.
  hardcodedOpenCode = "~/.config/opencode";
  scannedFiles = regularFiles skillsDir ++ regularFiles agentsDir;
  hardcodedPathProblems =
    builtins.map
    (file: "  - ${rel file}: hardcodes client-specific path '${hardcodedOpenCode}'")
    (builtins.filter (file: lib.hasInfix hardcodedOpenCode (text file)) scannedFiles);

  # --- 3. Registry contract documents the index fields -----------------------
  registryDir = skillsDir + "/skill-registry";
  registryText =
    text (registryDir + "/SKILL.md")
    + "\n"
    + lib.concatMapStringsSep "\n" text (regularFiles (registryDir + "/rules"));
  indexFieldProblems =
    builtins.map
    (field: "  - skill-registry contract does not document index field '${field}'")
    (
      builtins.filter
      (field: !(lib.hasInfix field (lib.toLower registryText)))
      [
        "name"
        "description"
        "scope"
        "path"
        "freshness"
      ]
    );

  # The compact-rule generator must be gone, not merely renamed.
  compactGeneratorExists = builtins.pathExists (registryDir + "/rules/execution-generate-compact.md");
  compactGeneratorProblems =
    lib.optional compactGeneratorExists "  - skill-registry still ships rules/execution-generate-compact.md";

  problems =
    authorityProblems
    ++ pathFirstProblems
    ++ hardcodedPathProblems
    ++ indexFieldProblems
    ++ compactGeneratorProblems;
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-loading-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["AI tooling discovery/loading contract violations in modules/common/ai-tools:"]
      ++ problems
      ++ ["Keep skills canonical: pass exact SKILL.md paths and document the registry index fields."]
    ))
