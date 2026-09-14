{
  lib,
  pkgs,
  ...
}: let
  # Executable reference for the T22 optional research/evidence handoff:
  #   - `skills/_shared/research-evidence.md` (evidence format + optionality)
  #   - `skills/sdd-explore`, `sdd-propose`, `sdd-design` (entry points)
  #
  # The pure helpers model the contract. The assertions prove the negative cases
  # the deliverable requires: a changing external claim retains source/revision
  # and gaps, an unsupported claim cannot masquerade as a confirmed product
  # choice, and `none` stays inline with no writes.
  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;
  containsAll = body: needles: lib.all (needle: lib.hasInfix needle body) needles;

  inherit (lib) optional;

  # --- Backend-aware persistence of the optional handoff -------------------
  evidenceTopic = "sdd/{change-name}/research-evidence";
  evidencePath = "openspec/changes/{change-name}/research-evidence.md";

  writesFor = backend:
    if backend == "engram"
    then [
      {
        kind = "observation";
        topic_key = evidenceTopic;
      }
    ]
    else if backend == "openspec"
    then [
      {
        kind = "file";
        path = evidencePath;
      }
    ]
    else if backend == "hybrid"
    then [
      {
        kind = "file";
        path = evidencePath;
      }
      {
        kind = "observation";
        topic_key = evidenceTopic;
      }
    ]
    else if backend == "none"
    then []
    else throw "unknown backend '${backend}'";

  hasWriteKind = kind: backend: lib.any (w: w.kind == kind) (writesFor backend);
  isInlineOnly = backend: writesFor backend == [];

  # --- Evidence handoff model ----------------------------------------------
  sourceAnchored = source:
    builtins.hasAttr "accessed" source || builtins.hasAttr "revision" source;
  sourceWellFormed = source:
    builtins.hasAttr "id" source
    && builtins.hasAttr "class" source
    && builtins.hasAttr "title" source
    && builtins.hasAttr "url" source
    && sourceAnchored source;

  sourceIds = handoff: map (s: s.id) (handoff.sources or []);
  claimById = handoff: id:
    lib.findFirst (c: c.id == id) null (handoff.claims or []);

  # A claim with no source can only exist as `unsupported`; any cited source ID
  # must resolve. A `supported` claim therefore always has real provenance.
  claimSourced = handoff: claim:
    if (claim.sources or []) == []
    then (claim.status or "unsupported") == "unsupported"
    else lib.all (sid: lib.elem sid (sourceIds handoff)) claim.sources;

  # A changing external claim must retain a gap or a revalidation trigger; the
  # pinned/accessed anchor itself is enforced by `sourceWellFormed`.
  changingClaimsHaveGaps = handoff:
    lib.all
    (claim:
      !(claim.changing or false)
      || (handoff.unresolvedGaps or []) != []
      || ((handoff.freshness or {}).revalidate or []) != [])
    (handoff.claims or []);

  duplicateSourceIds = handoff: let
    ids = sourceIds handoff;
    uniq = lib.unique ids;
  in
    builtins.length ids != builtins.length uniq;

  validateHandoff = handoff: let
    sources = handoff.sources or [];
    claims = handoff.claims or [];
    choices = handoff.confirmedProductChoices or [];

    sourceProblems =
      lib.concatMap
      (source: optional (!(sourceWellFormed source)) "source '${source.id or "?"}' lacks class/title/url or an accessed/revision anchor")
      sources
      ++ optional (duplicateSourceIds handoff) "sources contain duplicate ids";

    claimProblems =
      lib.concatMap
      (claim:
        optional (!(claimSourced handoff claim)) "claim '${claim.id or "?"}' cites a missing source"
        ++ optional ((claim.status or "") == "supported" && (claim.sources or []) == []) "supported claim '${claim.id or "?"}' has no source")
      claims;

    changingProblems =
      optional (!(changingClaimsHaveGaps handoff)) "a changing claim has neither an unresolved gap nor a revalidation trigger";

    choiceProblems =
      lib.concatMap
      (choice:
        optional (!(builtins.hasAttr "decided_by" choice)) "confirmed product choice '${choice.choice or "?"}' has no decided_by (consent cannot be inferred)"
        ++ lib.concatMap
        (cid: let
          claim = claimById handoff cid;
        in
          optional (claim == null) "confirmed product choice cites unknown claim '${cid}'"
          ++ optional (claim != null && ((claim.status or "") != "supported"))
          "confirmed product choice cites non-supported claim '${cid}'")
        (choice.evidence or []))
      choices;
  in {
    valid = sourceProblems ++ claimProblems ++ changingProblems ++ choiceProblems == [];
    inherit sourceProblems claimProblems changingProblems choiceProblems;
  };

  # --- Fixtures ------------------------------------------------------------
  docSource = {
    id = "S1";
    class = "official-docs";
    title = "Vendor API reference";
    url = "https://example.test/api";
    accessed = "2026-09-14";
  };

  docClaim = {
    id = "C1";
    claim = "API v2 returns an opaque pagination cursor";
    sources = ["S1"];
    status = "supported";
    affects = "pagination design";
  };

  goodHandoff = {
    questions = [
      {
        id = "Q1";
        question = "How does the vendor paginate?";
        material_to = "pagination design";
      }
    ];
    sources = [docSource];
    claims = [docClaim];
    contradictions = [];
    unresolvedGaps = [];
    freshness = {collected_at = "2026-09-14";};
    confirmedProductChoices = [
      {
        choice = "Use cursor pagination";
        decided_by = "user";
        evidence = ["C1"];
      }
    ];
  };

  changingSource = {
    id = "S-api";
    class = "source-code";
    title = "Vendor client v2.1.0";
    url = "https://example.test/client/v2.1.0";
    revision = "v2.1.0";
  };

  changingClaim = {
    id = "C-api";
    claim = "Client v2.1.0 supports cursor pagination";
    sources = ["S-api"];
    status = "supported";
    changing = true;
    affects = "pagination design";
  };

  changingHandoff = {
    questions = [
      {
        id = "Q1";
        question = "Is cursor pagination stable across vendor versions?";
        material_to = "pagination design";
      }
    ];
    sources = [changingSource];
    claims = [changingClaim];
    contradictions = [];
    unresolvedGaps = ["Vendor may change cursor semantics in v3; recheck release notes."];
    freshness = {
      collected_at = "2026-09-14";
      revalidate = [
        {
          sources = ["S-api"];
          when = "vendor ships API v3";
        }
      ];
    };
    confirmedProductChoices = [];
  };

  # Removing the pinned anchor from a changing claim's only source.
  changingNoAnchor =
    changingHandoff
    // {
      sources = [(builtins.removeAttrs changingSource ["revision"])];
    };

  # Removing the retained gap and the revalidation trigger.
  changingNoGap =
    changingHandoff
    // {
      unresolvedGaps = [];
      freshness = {collected_at = "2026-09-14";};
    };

  unsupportedClaim = {
    id = "C2";
    claim = "The vendor supports infinite page size";
    sources = [];
    status = "unsupported";
    affects = "page size";
  };

  # An unsupported claim a product choice tries to cite as its basis.
  unsupportedAsChoice =
    goodHandoff
    // {
      claims = [docClaim unsupportedClaim];
      confirmedProductChoices = [
        {
          choice = "Request unlimited page size";
          decided_by = "user";
          evidence = ["C2"];
        }
      ];
    };

  # The same unsupported claim recorded as a gap, with no choice resting on it.
  unsupportedAllowed =
    goodHandoff
    // {
      claims = [docClaim unsupportedClaim];
      confirmedProductChoices = [];
    };

  # A "choice" with no decided_by infers consent from the evidence.
  choiceWithoutConsent =
    goodHandoff
    // {
      confirmedProductChoices = [
        {
          choice = "Use cursor pagination";
          evidence = ["C1"];
        }
      ];
    };

  # --- Executable assertions -----------------------------------------------
  behaviorChecks = {
    goodHandoffValid = (validateHandoff goodHandoff).valid;
    changingHandoffValid = (validateHandoff changingHandoff).valid;

    # A changing external claim retains source/revision...
    changingLosesAnchor = !(validateHandoff changingNoAnchor).valid;
    # ...and its retained gap / revalidation trigger.
    changingLosesGap = !(validateHandoff changingNoGap).valid;

    # A supported claim without a real source is rejected.
    supportedNeedsSource =
      !(validateHandoff (goodHandoff
        // {
          claims = [docClaim (unsupportedClaim // {status = "supported";})];
        }))
      .valid;

    # An unsupported claim may be recorded as a gap...
    unsupportedClaimAllowed = (validateHandoff unsupportedAllowed).valid;
    # ...but cannot masquerade as a confirmed product choice.
    unsupportedCannotBecomeChoice = !(validateHandoff unsupportedAsChoice).valid;
    # Consent is never inferred: a choice without decided_by is rejected.
    choiceRequiresConsent = !(validateHandoff choiceWithoutConsent).valid;

    # `none` is inline-only and writes nothing; single stores never cross over.
    noneNoWrites = isInlineOnly "none";
    noneHasNoFile = !(hasWriteKind "file" "none");
    engramNoFile = !(hasWriteKind "file" "engram");
    openspecNoObservation = !(hasWriteKind "observation" "openspec");
    hybridWritesBoth = hasWriteKind "file" "hybrid" && hasWriteKind "observation" "hybrid";
    unknownBackendThrows = !(builtins.tryEval (writesFor "bogus")).success;
  };

  # --- Contract markers in the prose agents follow -------------------------
  researchFile = skillsDir + "/_shared/research-evidence.md";
  researchMarkers = [
    "optional"
    "questions"
    "sources"
    "accessed"
    "revision"
    "claims"
    "contradictions"
    "unresolved gaps"
    "freshness"
    "confirmed product choices"
    "infer consent"
    "inline"
    "impact-analysis"
    "bug-diagnosis"
  ];

  phaseSkills = {
    explore = skillsDir + "/sdd-explore/SKILL.md";
    propose = skillsDir + "/sdd-propose/SKILL.md";
    design = skillsDir + "/sdd-design/SKILL.md";
  };

  markerProblems =
    optional (!(containsAll (text researchFile) researchMarkers))
    "  - ${rel researchFile}: missing one of the evidence-format markers ${builtins.toJSON researchMarkers}"
    ++ lib.concatMap
    (name: let
      file = phaseSkills.${name};
    in
      optional (!(containsAll (text file) ["research-evidence.md" "Optional Research Evidence"]))
      "  - ${rel file}: missing a concise research-evidence entry point")
    (builtins.attrNames phaseSkills);

  failedBehaviors = builtins.attrNames (lib.filterAttrs (_: ok: !ok) behaviorChecks);
  problems = builtins.map (name: "  - behavior '${name}' failed") failedBehaviors ++ markerProblems;
in
  if problems != []
  then
    throw (lib.concatStringsSep "\n" (
      ["Optional research/evidence handoff violations in modules/common/ai-tools:"]
      ++ problems
      ++ ["Keep skills/_shared/research-evidence.md optional, source-backed, and consent-neutral."]
    ))
  else
    pkgs.runCommand "ai-tools-sdd-research-check" {} ''
      touch "$out"
    ''
