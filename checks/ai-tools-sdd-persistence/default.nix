{
  lib,
  pkgs,
  ...
}: let
  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;

  persistence = skillsDir + "/_shared/persistence-contract.md";
  execution = skillsDir + "/_shared/execution-modes.md";
  phaseCommon = skillsDir + "/_shared/sdd-phase-common.md";
  orchestrator = aiTools + "/agents/sdd/sdd-orchestrator.md";
  initSkill = skillsDir + "/sdd-init/SKILL.md";
  initConstraints = skillsDir + "/sdd-init/rules/constraints-rules.md";
  initBootstrap = skillsDir + "/sdd-init/rules/execution-bootstrap.md";
  initGenerateConfig = skillsDir + "/sdd-init/rules/execution-generate-config.md";
  initConfigFormat = skillsDir + "/sdd-init/references/config-format.md";
  openspecConvention = skillsDir + "/_shared/openspec-convention.md";

  # The contract surface that must agree. `required` markers must be present
  # (the canonical rule exists); `forbidden` markers must be absent (the old
  # contradictory rule was removed, not merely reworded elsewhere).
  contractFiles = {
    persistence = {
      file = persistence;
      required = [
        "## The Four Backends"
        "engram | openspec | hybrid | none"
        "Backend Resolution — New Change"
        "**Explicit choice**"
        "Backend Resolution — Existing Change"
        "keeps its recorded backend"
        "No silent cross-store fallback"
        "Hybrid Partial Writes and Retry"
        "persistence artifacts"
        "write all SDD planning artifacts to Engram only"
        "filesystem persistence file is `openspec/config.yaml`"
      ];
      forbidden = [
        "do NOT write any project files"
        "Otherwise → use `none`"
      ];
    };
    execution = {
      file = execution;
      required = [
        "Two Execution Modes"
        "`interactive`"
        "`automatic`"
        "Pauses That Both Modes MUST Honor"
        "Coordinator Inline Authority"
        "phase work"
      ];
      forbidden = [
        "ALWAYS show the user what was done and ask"
      ];
    };
    phaseCommon = {
      file = phaseCommon;
      required = [
        "Section B — Artifact Locators"
        "Artifact Locators"
        "No Silent Cross-Store Fallback"
        "aytordev-sdd"
      ];
      forbidden = [
        "check filesystem fallback path"
      ];
    };
    orchestrator = {
      file = orchestrator;
      required = [
        "SDD Readiness Guard"
        "Backend Policy"
        "Engine Adapter"
        "Execution Mode"
        "aytordev-sdd status"
        "Artifact Locators"
        "execution-modes.md"
        "persistence-contract.md"
      ];
      forbidden = [
        "If Engram is available, use `engram`"
        "Search Engram: `mem_search(query: \"sdd-init/{project}\""
        "Between sub-agent calls, **ALWAYS** show the user"
      ];
    };
    initSkill = {
      file = initSkill;
      required = [
        "Resolved backend"
        "persistence-contract.md"
        "sdd-phase-common.md"
      ];
      forbidden = [
        "Artifact store mode"
      ];
    };
    initConstraints = {
      file = initConstraints;
      required = [
        "persistence artifacts"
        "recorded backend"
        "openspec/config.yaml"
        "`none` writes nothing"
        "keeps every planning artifact in Engram"
      ];
      forbidden = [
        "NEVER write project files when mode is `engram` or `none`"
        "artifact_store_mode"
      ];
    };
    # The store declaration is a flat, same-line key. Nested `mode:` mappings
    # were invisible to the pinned engine and must not return.
    initGenerateConfig = {
      file = initGenerateConfig;
      required = [
        "artifact_store: {resolved-backend}"
        "### Minimal Template (`engram` only)"
      ];
      forbidden = [
        "artifact_store:\n  mode:"
      ];
    };
    initConfigFormat = {
      file = initConfigFormat;
      required = [
        "artifact_store: string"
        "## Minimal `engram` Example"
      ];
      forbidden = [
        "artifact_store:\n  mode:"
      ];
    };
    initBootstrap = {
      file = initBootstrap;
      required = [
        "openspec/config.yaml"
        "openspec/specs/"
        "openspec/changes/"
      ];
      forbidden = [];
    };
    openspecConvention = {
      file = openspecConvention;
      required = [
        "artifact_store: openspec"
      ];
      forbidden = [];
    };
  };

  markerProblems = spec: let
    missing =
      lib.concatMap
      (marker:
        lib.optional
        (!(lib.hasInfix marker (text spec.file)))
        "  - ${rel spec.file}: missing required rule '${marker}'")
      spec.required;
    forbidden =
      lib.concatMap
      (marker:
        lib.optional
        (lib.hasInfix marker (text spec.file))
        "  - ${rel spec.file}: still contains contradictory rule '${marker}'")
      spec.forbidden;
  in
    missing ++ forbidden;

  # All four backends are documented consistently in the orchestrator too.
  orchestratorModes =
    lib.concatMap
    (mode:
      lib.optional
      (!(lib.hasInfix mode (text orchestrator)))
      "  - ${rel orchestrator}: does not document backend '${mode}'")
    ["engram" "openspec" "hybrid" "none"];

  # Every phase skill consumes the resolved backend and locators instead of
  # deriving paths itself, and none reintroduces the old mode heading.
  phaseSkills = [
    "sdd-init"
    "sdd-explore"
    "sdd-propose"
    "sdd-spec"
    "sdd-design"
    "sdd-tasks"
    "sdd-apply"
    "sdd-verify"
    "sdd-archive"
    "sdd-onboard"
  ];
  phaseFile = name: skillsDir + "/${name}/SKILL.md";
  phaseProblems =
    lib.concatMap
    (name: let
      file = phaseFile name;
      body = text file;
    in
      lib.optional
      (!(lib.hasInfix "Resolved backend" body))
      "  - ${rel file}: records no resolved-backend input"
      ++ lib.optional
      (lib.hasInfix "Artifact store mode" body)
      "  - ${rel file}: still asks each phase to pick the artifact-store mode")
    phaseSkills;

  problems =
    lib.concatMap (name: markerProblems contractFiles.${name}) (lib.attrNames contractFiles)
    ++ orchestratorModes
    ++ phaseProblems;
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-sdd-persistence-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["SDD persistence/execution-mode contract violations in modules/common/ai-tools:"]
      ++ problems
      ++ ["Keep backend resolution and pause policy canonical in skills/_shared/."]
    ))
