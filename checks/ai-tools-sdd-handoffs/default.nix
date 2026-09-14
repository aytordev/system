{
  lib,
  pkgs,
  ...
}: let
  # Executable reference for the T20 handoff contracts:
  #   - `skills/_shared/return-envelope.md` (sdd-result/v1 phases)
  #   - `skills/sdd-tasks/`  (Review Workload Forecast + per-unit evidence)
  #   - `skills/sdd-apply/`  (update + re-read persisted tasks, cumulative progress)
  #   - `skills/sdd-verify/` (spec counts + revision-bound evidence)
  #
  # The pure helpers below model the producer/consumer contract. The assertions
  # prove the negative cases the deliverable requires: a missing forecast is
  # detected, an oversized forecast reaches the delivery decision, stale PASS /
  # incomplete units cannot advance, and invalid terminal envelopes are rejected.
  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;

  containsAll = body: needles: lib.all (needle: lib.hasInfix needle body) needles;

  # --- Review Workload Forecast: producer/consumer -------------------------

  forecastFields = [
    "Estimated changed lines"
    "400-line budget risk"
    "Chained PRs recommended"
    "Decision needed before apply"
  ];

  fieldValue = key: body: let
    lines = lib.splitString "\n" body;
    matches = builtins.filter (line: lib.hasInfix key line) lines;
  in
    if matches == []
    then null
    else let
      parts = lib.splitString ":" (builtins.head matches);
    in
      if lib.length parts < 2
      then null
      else lib.trim (lib.concatStringsSep ":" (builtins.tail parts));

  parseForecast = body:
    builtins.listToAttrs (builtins.map (key: {
        name = key;
        value = fieldValue key body;
      })
      forecastFields);

  forecastComplete = forecast: lib.all (key: (forecast.${key} or null) != null) forecastFields;

  numericValue = value:
    if value == null
    then null
    else let
      digits = lib.replaceStrings [","] [""] value;
      m = builtins.match "[^0-9]*([0-9]+).*" digits;
    in
      if m == null
      then null
      else builtins.fromJSON (builtins.elemAt m 0);

  needsDeliveryDecision = forecast: let
    lines = numericValue (forecast."Estimated changed lines" or null);
  in
    (forecast."400-line budget risk" or "")
    == "High"
    || (forecast."Chained PRs recommended" or "") == "Yes"
    || (forecast."Decision needed before apply" or "") == "Yes"
    || (lines != null && lines > 400);

  # Mirrors the orchestrator's Review Workload Guard: the cached delivery
  # strategy only matters once the forecast is complete and over budget.
  deliveryDecision = strategy: forecast:
    if !(forecastComplete forecast)
    then "missing-forecast"
    else if !(needsDeliveryDecision forecast)
    then "proceed"
    else if strategy == "ask-on-risk"
    then "ask"
    else if strategy == "auto-chain"
    then "auto-chain"
    else if strategy == "single-pr"
    then "size-exception"
    else if strategy == "exception-ok"
    then "exception-ok"
    else "unknown-strategy";

  # --- Result envelope: sdd-result/v1 --------------------------------------

  resultSchema = "sdd-result/v1";
  resultKinds = ["launch-ack" "progress" "cancelled" "final"];
  finalStatuses = ["success" "partial" "blocked" "failed"];
  finalRequired = [
    "status"
    "executive_summary"
    "artifacts"
    "evidence"
    "next_recommended"
    "risks"
    "skill_resolution"
  ];

  evidenceCurrent = candidate: evidence:
    builtins.isList evidence
    && evidence
    != []
    && lib.all
    (entry:
      (entry.revision or null)
      == candidate
      && (entry.exit or 1) == 0
      && (entry.result or "fail") == "pass")
    evidence;

  # A terminal `final`/`success` envelope only advances with current evidence.
  # Nonterminal acknowledgements and cancellations never advance.
  validateEnvelope = candidate: envelope:
    if !(builtins.isAttrs envelope)
    then {
      valid = false;
      terminal = false;
      advances = false;
      reason = "not-an-object";
    }
    else if (envelope.schema or null) != resultSchema
    then {
      valid = false;
      terminal = false;
      advances = false;
      reason = "missing-or-unknown-schema";
    }
    else if !(lib.elem (envelope.kind or null) resultKinds)
    then {
      valid = false;
      terminal = false;
      advances = false;
      reason = "unknown-kind";
    }
    else if envelope.kind != "final"
    then {
      valid = true;
      terminal = envelope.kind == "cancelled";
      advances = false;
      reason = envelope.kind;
    }
    else let
      missing = builtins.filter (key: !(builtins.hasAttr key envelope)) finalRequired;
    in
      if missing != []
      then {
        valid = false;
        terminal = true;
        advances = false;
        reason = "final-missing-fields";
      }
      else if !(lib.elem envelope.status finalStatuses)
      then {
        valid = false;
        terminal = true;
        advances = false;
        reason = "invalid-final-status";
      }
      else if !(builtins.isList envelope.evidence)
      then {
        valid = false;
        terminal = true;
        advances = false;
        reason = "evidence-not-a-list";
      }
      else if envelope.status == "success" && !(evidenceCurrent candidate envelope.evidence)
      then {
        valid = false;
        terminal = true;
        advances = false;
        reason = "stale-or-empty-evidence";
      }
      else {
        valid = true;
        terminal = true;
        advances = envelope.status == "success";
        reason = envelope.status;
      };

  # A work unit is completable only when persisted as checked AND its evidence is
  # current. Prose in an envelope can never complete an unchecked/stale unit.
  completableUnit = candidate: unit:
    (unit.checked or false)
    && evidenceCurrent candidate (unit.evidence or null);

  # --- Spec grammar + counts -----------------------------------------------

  inherit (lib) trim;

  countSpec = body: let
    lines = builtins.map trim (lib.splitString "\n" body);
    count = predicate: builtins.length (builtins.filter predicate lines);
  in {
    requirements = count (line: lib.hasPrefix "### Requirement:" line || lib.hasPrefix "## Requirement:" line);
    canonicalScenarios = count (line: lib.hasPrefix "#### Scenario:" line);
    legacyScenarios = count (line: lib.hasInfix "**Scenario:" line);
  };

  scenarioTotal = counts: counts.canonicalScenarios + counts.legacyScenarios;

  specCountsMatch = body: report: let
    counts = countSpec body;
  in
    counts.requirements
    > 0
    && scenarioTotal counts > 0
    && counts.requirements == (report.requirements or (-1))
    && scenarioTotal counts == (report.scenarios or (-1));

  # --- Fixtures ------------------------------------------------------------

  candidate = "3752d5c";

  forecastMissing = ''
    # Tasks: demo

    ## Phase 1: Foundation
    - [ ] 1.1 Create thing — check: `true`; scenario: N/A — docs; rollback: remove thing
  '';

  forecastOversized = ''
    ## Review Workload Forecast

    - Estimated changed lines: 820
    - 400-line budget risk: High
    - Chained PRs recommended: Yes
    - Decision needed before apply: Yes
    - Suggested PR slices: slice 1; slice 2
    - Delivery strategy: ask-on-risk
  '';

  forecastSmall = ''
    ## Review Workload Forecast

    - Estimated changed lines: 120
    - 400-line budget risk: Low
    - Chained PRs recommended: No
    - Decision needed before apply: No
  '';

  # Only the numeric line count crosses the budget: the flags alone are not the
  # trigger, and the existing delivery decision must still fire.
  forecastNumericOversized = ''
    ## Review Workload Forecast

    - Estimated changed lines: 512
    - 400-line budget risk: Medium
    - Chained PRs recommended: No
    - Decision needed before apply: No
  '';

  legacySpec = ''
    ### Requirement: Auth
    #### Scenarios

    **Scenario: Login**
    - Given: a user
    - When: they log in
    - Then: a session exists

    **Scenario: Logout**
    - Given: a session
    - When: they log out
    - Then: the session ends
  '';

  canonicalSpec = ''
    ## ADDED Requirements

    ### Requirement: Auth
    #### Scenario: Login
    - Given: a user

    #### Scenario: Logout
    - Given: a session

    ### Requirement: Session
    #### Scenario: Expiry
    - Given: an idle session
  '';

  validEnvelope = {
    schema = resultSchema;
    kind = "final";
    status = "success";
    executive_summary = "done";
    artifacts = ["task-artifact"];
    evidence = [
      {
        check = "nix flake check --no-build";
        exit = 0;
        result = "pass";
        revision = candidate;
        relevant = "REQ-01/S1";
      }
    ];
    next_recommended = "verify";
    risks = [];
    skill_resolution = "paths-injected";
  };

  completeUnit = {
    checked = true;
    evidence = [
      {
        exit = 0;
        result = "pass";
        revision = candidate;
      }
    ];
  };

  # --- Executable assertions -----------------------------------------------

  behaviorChecks = {
    # Missing forecast is detected and blocks the delivery decision.
    detectsMissingForecast = !(forecastComplete (parseForecast forecastMissing));
    missingForecastDecision = deliveryDecision "ask-on-risk" (parseForecast forecastMissing) == "missing-forecast";

    # An oversized forecast reaches the existing delivery decision per strategy.
    oversizedAsk = deliveryDecision "ask-on-risk" (parseForecast forecastOversized) == "ask";
    oversizedAutoChain = deliveryDecision "auto-chain" (parseForecast forecastOversized) == "auto-chain";
    oversizedSinglePr = deliveryDecision "single-pr" (parseForecast forecastOversized) == "size-exception";
    oversizedExceptionOk = deliveryDecision "exception-ok" (parseForecast forecastOversized) == "exception-ok";
    numericOversizedAsks = deliveryDecision "ask-on-risk" (parseForecast forecastNumericOversized) == "ask";
    smallForecastProceeds = deliveryDecision "ask-on-risk" (parseForecast forecastSmall) == "proceed";

    # Valid terminal success advances; stale PASS cannot.
    validFinalAdvances = (validateEnvelope candidate validEnvelope).advances;
    stalePassRejected =
      !(validateEnvelope candidate (validEnvelope
        // {
          evidence = [
            {
              check = "c";
              exit = 0;
              result = "pass";
              revision = "older-revision";
              relevant = "REQ-01/S1";
            }
          ];
        }))
      .valid;
    stalePassDoesNotAdvance =
      !(validateEnvelope candidate (validEnvelope
        // {
          evidence = [
            {
              check = "c";
              exit = 0;
              result = "pass";
              revision = "older-revision";
              relevant = "REQ-01/S1";
            }
          ];
        }))
      .advances;

    # Nonterminal acknowledgements and cancellation never advance.
    launchAckDoesNotAdvance =
      !(validateEnvelope candidate {
        schema = resultSchema;
        kind = "launch-ack";
        run_id = "run-1";
      })
      .advances;
    progressDoesNotAdvance =
      !(validateEnvelope candidate {
        schema = resultSchema;
        kind = "progress";
        summary = "half";
      })
      .advances;
    cancelledDoesNotAdvance = let
      result = validateEnvelope candidate {
        schema = resultSchema;
        kind = "cancelled";
        summary = "stopped";
      };
    in
      result.terminal && !result.advances;

    # Malformed / invalid terminal envelopes are rejected.
    emptyEnvelopeRejected = !(validateEnvelope candidate {}).valid;
    nonObjectRejected = !(validateEnvelope candidate "not-an-object").valid;
    unknownKindRejected = !(validateEnvelope candidate (validEnvelope // {kind = "weird";})).valid;
    missingSchemaRejected = !(validateEnvelope candidate (builtins.removeAttrs validEnvelope ["schema"])).valid;
    finalMissingFieldRejected = !(validateEnvelope candidate (builtins.removeAttrs validEnvelope ["evidence"])).valid;
    invalidStatusRejected = !(validateEnvelope candidate (validEnvelope // {status = "ok";})).valid;
    partialDoesNotAdvance =
      (validateEnvelope candidate (validEnvelope
        // {
          status = "partial";
          evidence = [];
        }))
      .valid
      && !(validateEnvelope candidate (validEnvelope
        // {
          status = "partial";
          evidence = [];
        }))
      .advances;

    # Incomplete / stale units never complete from prose.
    completeUnitAdvances = completableUnit candidate completeUnit;
    incompleteUnitBlocked = !(completableUnit candidate (completeUnit // {checked = false;}));
    staleUnitBlocked =
      !(completableUnit candidate (completeUnit
        // {
          evidence = [
            {
              exit = 0;
              result = "pass";
              revision = "older-revision";
            }
          ];
        }));

    # Both spec grammars are counted.
    legacyCounts = let
      counts = countSpec legacySpec;
    in
      counts.requirements == 1 && counts.legacyScenarios == 2 && counts.canonicalScenarios == 0;
    canonicalCounts = let
      counts = countSpec canonicalSpec;
    in
      counts.requirements == 2 && counts.canonicalScenarios == 3 && counts.legacyScenarios == 0;
    legacyCountsMatch = specCountsMatch legacySpec {
      requirements = 1;
      scenarios = 2;
    };
    canonicalCountsMatch = specCountsMatch canonicalSpec {
      requirements = 2;
      scenarios = 3;
    };
    countMismatchDetected =
      !(specCountsMatch legacySpec {
        requirements = 2;
        scenarios = 3;
      });
  };

  # --- Contract markers in the prose agents follow -------------------------

  envelopeFile = skillsDir + "/_shared/return-envelope.md";
  tasksWrite = skillsDir + "/sdd-tasks/rules/execution-write-tasks.md";
  tasksReturn = skillsDir + "/sdd-tasks/rules/execution-return-summary.md";
  tasksConstraints = skillsDir + "/sdd-tasks/rules/constraints-rules.md";
  tasksSkill = skillsDir + "/sdd-tasks/SKILL.md";
  applyComplete = skillsDir + "/sdd-apply/rules/execution-mark-complete.md";
  applyConstraints = skillsDir + "/sdd-apply/rules/constraints-rules.md";
  applySkill = skillsDir + "/sdd-apply/SKILL.md";
  specCounts = skillsDir + "/sdd-verify/rules/execution-spec-counts.md";
  verifyReport = skillsDir + "/sdd-verify/rules/execution-return-report.md";
  verifyMatrix = skillsDir + "/sdd-verify/rules/execution-compliance-matrix.md";
  verifySkill = skillsDir + "/sdd-verify/SKILL.md";
  orchestrator = aiTools + "/agents/sdd/sdd-orchestrator.md";

  requiredMarkers = {
    orchestrator = {
      file = orchestrator;
      markers = ["sdd-result/v1" "launch-ack" "stale"];
    };
    envelope = {
      file = envelopeFile;
      markers = [
        "sdd-result/v1"
        "launch-ack"
        "progress"
        "cancelled"
        "May advance"
        "Freshness"
        "stale"
        "aytordev-sdd"
      ];
    };
    tasksWrite = {
      file = tasksWrite;
      markers = [
        "Review Workload Forecast"
        "Estimated changed lines"
        "400-line budget risk"
        "Chained PRs recommended"
        "Decision needed before apply"
        "check:"
        "scenario:"
        "rollback:"
      ];
    };
    tasksReturn = {
      file = tasksReturn;
      markers = ["Review Workload Forecast" "workload_forecast"];
    };
    tasksConstraints = {
      file = tasksConstraints;
      markers = ["Review Workload Forecast" "check:" "per-unit evidence"];
    };
    tasksSkill = {
      file = tasksSkill;
      markers = ["sdd-result/v1" "Review Workload Forecast" "rollback"];
    };
    applyComplete = {
      file = applyComplete;
      markers = ["re-read" "cumulative" "apply-progress" "tasks_readback" "sdd-result/v1"];
    };
    applyConstraints = {
      file = applyConstraints;
      markers = ["Re-read the persisted tasks artifact" "cumulative" "sdd-result/v1"];
    };
    applySkill = {
      file = applySkill;
      markers = ["sdd-result/v1" "re-read" "cumulative"];
    };
    specCounts = {
      file = specCounts;
      markers = ["#### Scenario:" "**Scenario:" "candidate revision" "stale"];
    };
    verifyReport = {
      file = verifyReport;
      markers = ["sdd-result/v1" "Candidate Revision" "Spec Grammar & Counts"];
    };
    verifyMatrix = {
      file = verifyMatrix;
      markers = ["Revision" "stale"];
    };
    verifySkill = {
      file = verifySkill;
      markers = ["sdd-result/v1" "execution-spec-counts.md"];
    };
  };

  markerProblems =
    lib.concatMap
    (name: let
      spec = requiredMarkers.${name};
    in
      lib.optional
      (!(containsAll (text spec.file) spec.markers))
      "  - ${rel spec.file}: missing one of ${builtins.toJSON spec.markers}")
    (builtins.attrNames requiredMarkers);

  failedBehaviors = builtins.attrNames (lib.filterAttrs (_: ok: !ok) behaviorChecks);
  problems = builtins.map (name: "  - behavior '${name}' failed") failedBehaviors ++ markerProblems;
in
  if problems != []
  then
    throw (lib.concatStringsSep "\n" (
      ["SDD phase/task/evidence handoff violations in modules/common/ai-tools:"]
      ++ problems
      ++ ["Keep the sdd-result/v1 schema, the workload forecast, apply readback, and verify counts canonical."]
    ))
  else
    pkgs.runCommand "ai-tools-sdd-handoffs-check" {} ''
      touch "$out"
    ''
