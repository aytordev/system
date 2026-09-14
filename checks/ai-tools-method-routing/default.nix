{
  lib,
  pkgs,
  ...
}: let
  # Executable reference for the entry/return contracts of the two lightweight
  # method skills (`skills/bug-diagnosis`, `skills/impact-analysis`). The corpus
  # is deterministic and cheap: routing is asserted from data, and the impact
  # fixture proves a real affected consumer with a discriminating check.
  root = ./.;
  skillsDir = ../../modules/common/ai-tools/skills;
  fixture = root + "/fixtures/impact";

  parseJson = file: builtins.fromJSON (builtins.readFile file);

  scenarios = parseJson (root + "/scenarios.json");
  impactCase = parseJson (fixture + "/case.json");

  skillEntries = builtins.readDir skillsDir;
  skillExists = name:
    builtins.hasAttr name skillEntries
    && skillEntries.${name} == "directory"
    && builtins.pathExists (skillsDir + "/${name}/SKILL.md");

  inherit (scenarios) cases;
  idOf = scenario: scenario.id or "<unknown>";
  methodEntries = ["bug-diagnosis" "impact-analysis"];

  # --- Per-case shape and routing validity ---------------------------------
  caseProblems = scenario:
    lib.optional (!(scenario ? id)) "a scenario is missing 'id'"
    ++ lib.optional (!(scenario ? entry)) "${idOf scenario}: missing 'entry'"
    ++ lib.optional ((scenario ? entry) && !(skillExists scenario.entry)) "${idOf scenario}: entry '${scenario.entry}' is not a skill with a SKILL.md"
    ++ lib.optional (!(scenario ? owner)) "${idOf scenario}: missing 'owner'"
    ++ lib.optional (!(scenario ? mutates_source) || !(builtins.isBool scenario.mutates_source)) "${idOf scenario}: 'mutates_source' must be a boolean"
    ++ lib.optional (!(scenario ? return_to_caller) || !(builtins.isBool scenario.return_to_caller)) "${idOf scenario}: 'return_to_caller' must be a boolean";

  allProblems = lib.concatMap caseProblems cases;

  entries = lib.unique (map (scenario: scenario.entry) (builtins.filter (scenario: scenario ? entry) cases));
  coverageProblems =
    lib.concatMap (method: lib.optional (!(builtins.elem method entries)) "no scenario routes to '${method}'") methodEntries;

  # --- Acceptance read from the corpus ------------------------------------
  exactlyOne = id: builtins.filter (scenario: scenario.id or null == id) cases;

  diagnosisOnly = exactlyOne "diagnosis-only";
  diagnosisProblems =
    lib.optional (builtins.length diagnosisOnly != 1) "the corpus must have exactly one 'diagnosis-only' scenario"
    ++ lib.concatMap (scenario: lib.optional scenario.mutates_source "the diagnosis-only scenario must declare mutates_source = false") diagnosisOnly;

  impactShip = exactlyOne "impact-before-ship";
  impactProblems =
    lib.optional (builtins.length impactShip != 1) "the corpus must have exactly one 'impact-before-ship' scenario"
    ++ lib.concatMap (scenario: lib.optional scenario.mutates_source "the impact-before-ship scenario must declare mutates_source = false") impactShip;

  # A scenario with a different owner than its entry is nested inside another
  # lifecycle and must return to the caller.
  nested = builtins.filter (scenario: scenario ? owner && scenario ? entry && scenario.owner != scenario.entry) cases;
  nestedProblems =
    lib.concatMap (scenario: lib.optional (!scenario.return_to_caller) "${idOf scenario}: a nested scenario must declare return_to_caller = true") nested;

  # --- Skill contract markers ---------------------------------------------
  containsAll = text: needles: lib.all (needle: lib.hasInfix needle text) needles;
  bugSkill = builtins.readFile (skillsDir + "/bug-diagnosis/SKILL.md");
  impactSkill = builtins.readFile (skillsDir + "/impact-analysis/SKILL.md");

  markerProblems =
    lib.optional (!(containsAll bugSkill ["## Entry Conditions" "## Return to Caller" "Read-Only Boundary" "does not implement, refactor,"]))
    "bug-diagnosis/SKILL.md no longer states entry conditions and a non-owning return"
    ++ lib.optional (!(containsAll impactSkill ["## Entry Conditions" "## Return to Caller" "beyond the diff" "never take over the lifecycle"]))
    "impact-analysis/SKILL.md no longer states entry conditions and a non-owning return";

  # --- Impact fixture: real consumer plus a discriminating check -----------
  symbol = impactCase.change.symbol;
  producerText = builtins.readFile (fixture + "/producer.nix");
  consumerText = builtins.readFile (fixture + "/consumer.nix");
  unrelatedText = builtins.readFile (fixture + "/unrelated.nix");

  consumerProblems =
    lib.optional (!(lib.hasInfix symbol producerText)) "the impact fixture producer does not define '${symbol}'"
    ++ lib.optional (!(lib.hasInfix symbol consumerText)) "the impact fixture expected consumer does not reference '${symbol}'"
    ++ lib.optional (lib.hasInfix symbol unrelatedText) "the impact fixture 'unaffected' file must not reference '${symbol}'"
    ++ lib.optional (impactCase.expected_consumers != ["consumer.nix"]) "the impact fixture must name exactly the real affected consumer";

  # --- Self-test: the validator rejects an unknown entry -------------------
  selfTest =
    caseProblems {
      id = "self-test-unknown";
      entry = "no-such-skill";
      owner = "no-such-skill";
      mutates_source = false;
      return_to_caller = true;
    }
    != []
    && caseProblems {
      id = "self-test-valid";
      entry = "bug-diagnosis";
      owner = "bug-diagnosis";
      mutates_source = false;
      return_to_caller = false;
    }
    == [];

  problems =
    allProblems
    ++ coverageProblems
    ++ diagnosisProblems
    ++ impactProblems
    ++ nestedProblems
    ++ markerProblems
    ++ consumerProblems
    ++ lib.optional (!selfTest) "routing self-test failed: an unknown entry was accepted";
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-method-routing-check" {} ''
      set -euo pipefail
      ${pkgs.gnugrep}/bin/grep -q '${symbol}' ${fixture + "/consumer.nix"}
      if ${pkgs.gnugrep}/bin/grep -q '${symbol}' ${fixture + "/unrelated.nix"}; then
        echo "impact fixture discriminating check failed: the unaffected file references ${symbol}" >&2
        exit 1
      fi
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["AI tooling method-routing corpus violations:"]
      ++ builtins.map (problem: "  - ${problem}") problems
      ++ ["Fix the corpus/fixture or the method skill contracts."]
    ))
