# T26 bundle-consistency check (ADR 0017).
#
# Proves the deployed migration bundles are internally coherent before rollout:
#   - every SDD phase documents the locator model and the `sdd-result/v1` result
#     contract, and no producer still emits the legacy `ok`/`warning` envelope or
#     the legacy `artifacts: [{type, location, change_name}]` list;
#   - archive is gated by the C11 closure contract and calls the adapter's
#     `closure` subcommand;
#   - research is optional (shared handoff plus the three material phases) and
#     the `sdd-research` collector is deployed as a skill plus an authored
#     output-only agent;
#   - the registry is index-first and no skill/agent presents compact-rule
#     authority or hardcodes the OpenCode global path;
#   - every bundle's concrete files exist, and the upstream-only methods that
#     ADR 0017 defers are absent from the tree;
#   - the T25 legacy fixtures remain distinct from the current schema (a legacy
#     `ok` envelope carries no `schema`), so a producer can never be validated
#     against them;
#   - `bundle-verification.md` records the frozen source commit and all five
#     bundle names.
#
# The check is pure: it asserts the on-disk contract, not runtime behavior.
{
  lib,
  pkgs,
  ...
}: let
  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  agentsDir = aiTools + "/agents";
  fixturesDir = ../ai-tools-legacy-compat/fixtures;

  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;

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

  allFiles = regularFiles skillsDir ++ regularFiles agentsDir;

  # --- Bundle inventory (ADR 0017, upstream-sources.md section 4) ----------
  sddPhases = [
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

  bundleFiles = {
    "Authoring" = [
      (skillsDir + "/skill-creator/SKILL.md")
      (skillsDir + "/skill-creator/rules/process-steps.md")
    ];
    "Discovery/loading" = [
      (skillsDir + "/skill-registry/SKILL.md")
      (skillsDir + "/_shared/skill-resolver.md")
      (skillsDir + "/_shared/skill-loading.md")
      (skillsDir + "/_shared/return-envelope.md")
    ];
    "SDD execution" = [
      (skillsDir + "/_shared/sdd-phase-common.md")
      (skillsDir + "/_shared/persistence-contract.md")
      (skillsDir + "/_shared/engram-convention.md")
      (skillsDir + "/_shared/openspec-convention.md")
      (skillsDir + "/sdd-research/SKILL.md")
      (skillsDir + "/sdd-research/metadata.json")
      (agentsDir + "/sdd/sdd-orchestrator.md")
      (agentsDir + "/sdd/sdd-research.nix")
    ];
    "Auxiliary workflows" = [
      (skillsDir + "/judgment-day/SKILL.md")
      (skillsDir + "/branch-pr/SKILL.md")
      (skillsDir + "/chained-pr/SKILL.md")
      (skillsDir + "/work-unit-commits/SKILL.md")
      (skillsDir + "/comment-writer/SKILL.md")
      (skillsDir + "/cognitive-doc-design/SKILL.md")
      (skillsDir + "/issue-creation/SKILL.md")
    ];
    "New methods" = [
      (skillsDir + "/_shared/research-evidence.md")
      (skillsDir + "/bug-diagnosis/SKILL.md")
      (skillsDir + "/impact-analysis/SKILL.md")
      (skillsDir + "/lightweight-change/SKILL.md")
      (skillsDir + "/nix/references/closure-and-dependency-analysis.md")
    ];
  };

  missingBundleFiles =
    lib.concatMap
    (bundle:
      builtins.map
      (file: "  - bundle '${bundle}' references a missing file: ${rel file}")
      (builtins.filter (file: !(builtins.pathExists file)) bundleFiles.${bundle}))
    (builtins.attrNames bundleFiles);

  # Upstream-only methods ADR 0017 defers must not be deployed as skills.
  # `sdd-research` left this list when it was adopted as a collector skill
  # plus an authored agent.
  deferredSkills = [
    "skill-improver"
    "go-testing"
    "rdd-defect-workflow"
    "systemic-issue-triage"
    "hermes-ephemeral-delegation"
    "gentle-ai-bench"
  ];
  deferredProblems =
    builtins.map
    (name: "  - deferred upstream method '${name}' is deployed as a skill")
    (builtins.filter (name: builtins.pathExists (skillsDir + "/${name}")) deferredSkills);

  # --- Producer/consumer contract: sdd-result/v1 + locator model -----------
  phaseProblems =
    lib.concatMap (
      phase: let
        skill = skillsDir + "/${phase}/SKILL.md";
      in
        if !(builtins.pathExists skill)
        then ["  - missing SDD phase skill '${phase}/SKILL.md'"]
        else let
          body = text skill;
        in
          lib.optional (!(lib.hasInfix "sdd-result/v1" body))
          "  - ${phase}/SKILL.md does not document the 'sdd-result/v1' envelope"
          ++ lib.optional
          (!(lib.hasInfix "Artifact Locators" body) && !(lib.hasInfix "sdd-phase-common.md" body))
          "  - ${phase}/SKILL.md does not document the locator model"
    )
    sddPhases;

  envelopeFile = skillsDir + "/_shared/return-envelope.md";
  envelopeBody = text envelopeFile;
  envelopeProblems =
    lib.optional (!(lib.hasInfix "sdd-result/v1" envelopeBody))
    "  - _shared/return-envelope.md does not declare 'sdd-result/v1'"
    ++ lib.optional (!(lib.hasInfix "launch-ack" envelopeBody))
    "  - _shared/return-envelope.md does not define the nonterminal 'launch-ack' kind"
    ++ lib.optional (!(lib.hasInfix "cancelled" envelopeBody))
    "  - _shared/return-envelope.md does not define the 'cancelled' kind"
    ++ lib.optional (!(lib.hasInfix "skill_resolution" envelopeBody))
    "  - _shared/return-envelope.md does not require 'skill_resolution'";

  # No SDD producer may still emit the legacy envelope or artifact list.
  producerFiles = lib.concatMap (phase: regularFiles (skillsDir + "/${phase}")) sddPhases;
  legacyMarkers = [
    ''"status": "ok"''
    ''"status": "warning"''
    "detailed_report"
  ];
  legacyProblems =
    lib.concatMap
    (file:
      builtins.map
      (marker: "  - ${rel file}: still emits legacy envelope marker '${marker}'")
      (builtins.filter (marker: lib.hasInfix marker (text file)) legacyMarkers))
    producerFiles;

  # --- Archive is gated by C11 and the adapter ----------------------------
  archiveSkill = skillsDir + "/sdd-archive/SKILL.md";
  closureGateFile = skillsDir + "/sdd-archive/rules/execution-closure-gate.md";
  closurePolicyFile = skillsDir + "/_shared/closure-policy.md";
  archiveProblems =
    lib.optional (!(builtins.pathExists closureGateFile))
    "  - sdd-archive has no closure-gate rule"
    ++ lib.optional (!(builtins.pathExists closurePolicyFile))
    "  - _shared/closure-policy.md (C11) is missing"
    ++ lib.optional (!(lib.hasInfix "closure" (text archiveSkill)))
    "  - sdd-archive/SKILL.md does not reference the closure gate"
    ++ lib.optional
    (!(lib.hasInfix "aytordev-sdd closure" (text closureGateFile)))
    "  - sdd-archive closure gate does not call the adapter's closure subcommand";

  # --- Research is optional ------------------------------------------------
  researchFile = skillsDir + "/_shared/research-evidence.md";
  researchBody = text researchFile;
  materialPhases = ["sdd-explore" "sdd-propose" "sdd-design"];
  researchProblems =
    lib.optional (!(lib.hasInfix "optional" (lib.toLower researchBody)))
    "  - _shared/research-evidence.md does not mark the handoff optional"
    ++ lib.concatMap
    (phase:
      lib.optional
      (!(lib.hasInfix "Optional Research Evidence" (text (skillsDir + "/${phase}/SKILL.md"))))
      "  - ${phase}/SKILL.md does not present research as optional")
    materialPhases;

  # --- Research collector is deployed as skill + authored agent -----------
  collectorSkill = skillsDir + "/sdd-research/SKILL.md";
  collectorAgent = agentsDir + "/sdd/sdd-research.nix";
  collectorProblems =
    lib.optional (!(builtins.pathExists collectorSkill))
    "  - sdd-research collector skill is missing"
    ++ lib.optional
    ((builtins.pathExists collectorSkill)
      && !(lib.hasInfix "research-evidence" (text collectorSkill)))
    "  - sdd-research/SKILL.md does not return the research-evidence envelope"
    ++ lib.optional
    ((builtins.pathExists collectorSkill)
      && !(lib.hasInfix "Output-only" (text collectorSkill)))
    "  - sdd-research/SKILL.md does not state the output-only boundary"
    ++ lib.optional (!(builtins.pathExists collectorAgent))
    "  - authored sdd-research agent is missing";

  # --- Registry is index-first --------------------------------------------
  registryDir = skillsDir + "/skill-registry";
  registryText =
    text (registryDir + "/SKILL.md")
    + "\n"
    + lib.concatMapStringsSep "\n" text (regularFiles (registryDir + "/rules"));
  indexFields = ["name" "description" "scope" "path" "freshness"];
  registryProblems =
    lib.optional (builtins.pathExists (registryDir + "/rules/execution-generate-compact.md"))
    "  - skill-registry still ships a compact-rule generator"
    ++ lib.optional (!(lib.hasInfix "index" (lib.toLower registryText)))
    "  - skill-registry does not describe an index-first registry"
    ++ builtins.map
    (field: "  - skill-registry does not document index field '${field}'")
    (builtins.filter (field: !(lib.hasInfix field (lib.toLower registryText))) indexFields);

  # --- No compact-rule authority, no client-specific paths ----------------
  bannedAuthority = ["Project Standards" "Compact Rules"];
  hardcodedOpenCode = "~/.config/opencode";
  authorityProblems =
    lib.concatMap
    (file:
      builtins.map
      (marker: "  - ${rel file}: presents '${marker}' as authoritative")
      (builtins.filter (marker: lib.hasInfix marker (text file)) bannedAuthority))
    allFiles;
  hardcodedProblems =
    builtins.map
    (file: "  - ${rel file}: hardcodes client-specific path '${hardcodedOpenCode}'")
    (builtins.filter (file: lib.hasInfix hardcodedOpenCode (text file)) allFiles);

  # --- T25 legacy fixtures stay distinct from the current schema ----------
  legacyEnvelope = builtins.fromJSON (text (fixturesDir + "/legacy-envelope.json"));
  currentEnvelope = builtins.fromJSON (text (fixturesDir + "/current-envelope.json"));
  unknownEnvelope = builtins.fromJSON (text (fixturesDir + "/unknown-envelope.json"));
  fixtureProblems =
    lib.optional ((legacyEnvelope.schema or null) != null)
    "  - T25 legacy envelope fixture unexpectedly carries a schema"
    ++ lib.optional ((currentEnvelope.schema or null) != "sdd-result/v1")
    "  - T25 current envelope fixture is not 'sdd-result/v1'"
    ++ lib.optional ((unknownEnvelope.schema or null) != null)
    "  - T25 unknown envelope fixture unexpectedly carries a schema";

  # --- Bundle verification record -----------------------------------------
  record = ../../docs/ai-tools/bundle-verification.md;
  recordExists = builtins.pathExists record;
  recordText =
    if recordExists
    then text record
    else "";
  bundleNames = builtins.attrNames bundleFiles;
  recordProblems =
    lib.optional (!recordExists)
    "  - bundle-verification.md is missing"
    ++ lib.optional
    (recordExists && !(lib.hasInfix "be49554794917ae92a6dc9dbfa2eb3db5cf70084" recordText))
    "  - bundle-verification.md does not record the frozen gentle-ai commit"
    ++ builtins.map
    (bundle: "  - bundle-verification.md does not name the '${bundle}' bundle")
    (builtins.filter (bundle: !(lib.hasInfix bundle recordText)) bundleNames);

  problems =
    missingBundleFiles
    ++ deferredProblems
    ++ phaseProblems
    ++ envelopeProblems
    ++ legacyProblems
    ++ archiveProblems
    ++ researchProblems
    ++ collectorProblems
    ++ registryProblems
    ++ authorityProblems
    ++ hardcodedProblems
    ++ fixtureProblems
    ++ recordProblems;
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-bundles-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["Compatible AI-tool bundle violations in modules/common/ai-tools (ADR 0017):"]
      ++ problems
      ++ ["Fix the bundle producer/consumer contract or update checks/ai-tools-bundles."]
    ))
