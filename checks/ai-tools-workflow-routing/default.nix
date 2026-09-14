{
  lib,
  pkgs,
  ...
}: let
  # Executable reference for the lightweight workflow's routing contract
  # (`skills/lightweight-change`). The corpus is deterministic: it encodes the
  # lifecycle owner for representative tasks and asserts that a method invoked
  # inside a lifecycle returns to its caller rather than becoming a second owner.
  root = ./.;
  skillsDir = ../../modules/common/ai-tools/skills;

  parseJson = file: builtins.fromJSON (builtins.readFile file);
  scenarios = parseJson (root + "/scenarios.json");

  skillEntries = builtins.readDir skillsDir;
  skillExists = name:
    builtins.hasAttr name skillEntries
    && skillEntries.${name} == "directory"
    && builtins.pathExists (skillsDir + "/${name}/SKILL.md");

  inherit (scenarios) cases;
  idOf = scenario: scenario.id or "<unknown>";

  # `entry` -> the lifecycle that owns it. `none` means the task needs no
  # lifecycle at all (a question answered directly).
  lifecycleOf = {
    "none" = "none";
    "bug-diagnosis" = "bug-diagnosis";
    "impact-analysis" = "impact-analysis";
    "lightweight-change" = "lightweight-change";
    "sdd-explore" = "sdd";
    "sdd-propose" = "sdd";
    "judgment-day" = "judgment-day";
  };
  lifecycleOwners = lib.unique (builtins.attrValues lifecycleOf);

  # --- Per-case shape and single-owner validity ---------------------------
  caseProblems = scenario:
    lib.optional (!(scenario ? id)) "a scenario is missing 'id'"
    ++ lib.optional (!(scenario ? entry)) "${idOf scenario}: missing 'entry'"
    ++ lib.optional ((scenario ? entry) && scenario.entry != "none" && !(builtins.hasAttr scenario.entry lifecycleOf)) "${idOf scenario}: entry '${scenario.entry}' is not a known lifecycle entry"
    ++ lib.optional ((scenario ? entry) && scenario.entry != "none" && !(skillExists scenario.entry)) "${idOf scenario}: entry '${scenario.entry}' is not a skill with a SKILL.md"
    ++ lib.optional (!(scenario ? owner)) "${idOf scenario}: missing 'owner'"
    ++ lib.optional ((scenario ? owner) && !(lib.elem scenario.owner lifecycleOwners)) "${idOf scenario}: owner '${scenario.owner}' is not a single known lifecycle"
    ++ lib.optional (!(scenario ? mutates_source) || !(builtins.isBool scenario.mutates_source)) "${idOf scenario}: 'mutates_source' must be a boolean"
    ++ lib.optional (!(scenario ? produces_sdd_artifacts) || !(builtins.isBool scenario.produces_sdd_artifacts)) "${idOf scenario}: 'produces_sdd_artifacts' must be a boolean"
    ++ lib.optional (!(scenario ? return_to_caller) || !(builtins.isBool scenario.return_to_caller)) "${idOf scenario}: 'return_to_caller' must be a boolean";

  # The owner must be the entry's lifecycle unless the entry is a method nested
  # inside the owning lifecycle, in which case it must declare the return.
  ownershipProblems =
    lib.concatMap (
      scenario: let
        entry = scenario.entry or null;
        owner = scenario.owner or null;
      in
        if entry == null || owner == null || !(builtins.hasAttr entry lifecycleOf)
        then []
        else let
          nested = owner != lifecycleOf.${entry};
        in
          lib.optional (nested && !(scenario.return_to_caller or false)) "${idOf scenario}: owner '${owner}' differs from the entry's lifecycle but is not marked return_to_caller"
    )
    cases;

  allProblems = lib.concatMap caseProblems cases ++ ownershipProblems;

  # --- Acceptance read from the corpus ------------------------------------
  exactlyOne = id: builtins.filter (scenario: (scenario.id or null) == id) cases;

  expectCase = id: predicate: description: let
    found = exactlyOne id;
  in
    lib.optional (builtins.length found != 1) "the corpus must have exactly one '${id}' scenario"
    ++ lib.concatMap (scenario: lib.optional (!(predicate scenario)) "${idOf scenario}: ${description}") found;

  acceptanceProblems =
    expectCase "question-only" (s: s.owner == "none" && !s.mutates_source && !s.produces_sdd_artifacts) "a question needs no lifecycle and produces no artifacts"
    ++ expectCase "diagnosis-only" (s: s.owner == "bug-diagnosis" && !s.mutates_source && !s.produces_sdd_artifacts) "diagnosis-only work is owned by the method and makes no change"
    ++ expectCase "small-change" (s: s.owner == "lightweight-change" && s.entry == "lightweight-change" && s.mutates_source && !s.produces_sdd_artifacts) "a small edit is owned by lightweight-change and produces no SDD artifacts"
    ++ expectCase "architecture-only-analysis" (s: s.owner == "sdd" && !s.mutates_source && !s.produces_sdd_artifacts) "architecture-only analysis stays read-only under SDD"
    ++ expectCase "substantial-implementation" (s: s.owner == "sdd" && s.produces_sdd_artifacts) "substantial implementation stays in SDD and produces SDD artifacts"
    ++ expectCase "explicit-sdd-request" (s: s.owner == "sdd" && s.produces_sdd_artifacts) "an explicit SDD request stays in SDD and produces SDD artifacts"
    ++ expectCase "diagnosis-inside-lightweight" (s: s.owner == "lightweight-change" && s.entry == "bug-diagnosis" && s.return_to_caller) "a method invoked inside lightweight-change returns to its caller";

  # Every lifecycle this routing must distinguish appears at least once.
  usedOwners = lib.unique (map (scenario: scenario.owner) (builtins.filter (scenario: scenario ? owner) cases));
  ownerCoverageProblems =
    lib.concatMap
    (owner: lib.optional (!(lib.elem owner usedOwners)) "no scenario routes to lifecycle owner '${owner}'")
    ["none" "bug-diagnosis" "lightweight-change" "sdd"];

  # --- Skill contract markers ---------------------------------------------
  containsAll = text: needles: lib.all (needle: lib.hasInfix needle text) needles;
  skillFile = skillsDir + "/lightweight-change/SKILL.md";
  skillText =
    if skillExists "lightweight-change"
    then builtins.readFile skillFile
    else "";

  markerProblems =
    lib.optional (!(skillExists "lightweight-change")) "skills/lightweight-change/SKILL.md is missing"
    ++ lib.optional (
      skillExists "lightweight-change"
      && !(containsAll skillText [
        "## Entry Conditions"
        "## Phases"
        "## Routing"
        "## Completion"
        "Understand"
        "Change"
        "Verify"
        "create SDD artifacts"
        "Exactly one lifecycle"
      ])
    )
    "lightweight-change/SKILL.md no longer states the three phases, the routing table, and the no-SDD-artifact boundary";

  # --- Self-test: the validator rejects unknown entries and owners ---------
  selfTest =
    caseProblems {
      id = "self-test-unknown-entry";
      entry = "no-such-skill";
      owner = "lightweight-change";
      mutates_source = false;
      produces_sdd_artifacts = false;
      return_to_caller = false;
    }
    != []
    && caseProblems {
      id = "self-test-bad-owner";
      entry = "lightweight-change";
      owner = "made-up-lifecycle";
      mutates_source = false;
      produces_sdd_artifacts = false;
      return_to_caller = false;
    }
    != []
    && caseProblems {
      id = "self-test-valid";
      entry = "lightweight-change";
      owner = "lightweight-change";
      mutates_source = true;
      produces_sdd_artifacts = false;
      return_to_caller = false;
    }
    == [];

  problems =
    allProblems
    ++ acceptanceProblems
    ++ ownerCoverageProblems
    ++ markerProblems
    ++ lib.optional (!selfTest) "routing self-test failed: an unknown entry or owner was accepted";
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-workflow-routing-check" {} ''
      set -euo pipefail
      ${pkgs.gnugrep}/bin/grep -q 'lightweight-change' ${skillFile}
      ${pkgs.gnugrep}/bin/grep -q 'create SDD artifacts' ${skillFile}
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["AI tooling workflow-routing corpus violations:"]
      ++ builtins.map (problem: "  - ${problem}") problems
      ++ ["Fix the corpus or the lightweight-change skill contract."]
    ))
