# T21 integration check: lossless archive and the C11 closure policy.
#
# Two layers:
#   - A pure model of the adapter's closure disposition and the promotion gate,
#     with negative assertions (stale/failed/incomplete never promote, never a
#     fabricated success).
#   - Executable facts through the real `aytordev-sdd` adapter on disposable
#     OpenSpec fixtures: the engine composer preserves unrelated requirements,
#     refuses malformed deltas without writing, applies or refuses renames, the
#     mechanical archive refuses a collision and moves losslessly, and the
#     closure gate blocks incomplete/stale/unverified changes.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "ai-tools-archive-check";
    email = "ai-tools-archive-check@example.test";
    fullName = "AI Tools Archive Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  aiTools = ../../modules/common/ai-tools;
  skillsDir = aiTools + "/skills";
  rel = file: lib.removePrefix (toString aiTools + "/") (toString file);
  text = file: builtins.readFile file;

  # --- Pure C11 closure model ---------------------------------------------
  candidate = "sha256:${lib.concatStrings (lib.genList (_: "a") 64)}";
  otherRevision = "sha256:${lib.concatStrings (lib.genList (_: "b") 64)}";

  dispositionOf = {
    allComplete,
    archiveReady,
    verdict,
    envelopeRevision,
    revisionGiven ? true,
  }:
    if !allComplete
    then "incomplete-tasks"
    else if !archiveReady || verdict != "pass"
    then "unverified"
    else if revisionGiven && envelopeRevision != candidate
    then "stale-verification"
    else "verified";

  promotable = disposition: disposition == "verified";

  envelopeStatus = disposition:
    if disposition == "verified"
    then "success"
    else if disposition == "paused"
    then "partial"
    else if disposition == "abandoned"
    then "failed"
    else "blocked";

  nonSuccessDispositions = ["incomplete-tasks" "unverified" "stale-verification" "paused" "abandoned"];

  behaviorChecks = {
    verifiedPromotes = promotable (dispositionOf {
      allComplete = true;
      archiveReady = true;
      verdict = "pass";
      envelopeRevision = candidate;
    });
    incompleteTasksBlocked =
      !(promotable (dispositionOf {
        allComplete = false;
        archiveReady = true;
        verdict = "pass";
        envelopeRevision = candidate;
      }));
    unverifiedBlocked =
      !(promotable (dispositionOf {
        allComplete = true;
        archiveReady = false;
        verdict = "pass";
        envelopeRevision = candidate;
      }));
    failedVerdictBlocked =
      !(promotable (dispositionOf {
        allComplete = true;
        archiveReady = true;
        verdict = "fail";
        envelopeRevision = candidate;
      }));
    staleRevisionBlocked =
      !(promotable (dispositionOf {
        allComplete = true;
        archiveReady = true;
        verdict = "pass";
        envelopeRevision = otherRevision;
      }));
    noRevisionCheckStillPromotes = promotable (dispositionOf {
      allComplete = true;
      archiveReady = true;
      verdict = "pass";
      envelopeRevision = otherRevision;
      revisionGiven = false;
    });
    nonSuccessNeverSuccess =
      lib.all (d: envelopeStatus d != "success") nonSuccessDispositions;
    pausedNeverSuccess = envelopeStatus "paused" == "partial";
    abandonedNeverSuccess = envelopeStatus "abandoned" == "failed";
  };

  # --- Prose contract markers ---------------------------------------------
  closurePolicy = skillsDir + "/_shared/closure-policy.md";
  archiveSkill = skillsDir + "/sdd-archive/SKILL.md";
  archiveConstraints = skillsDir + "/sdd-archive/rules/constraints-rules.md";
  closureGate = skillsDir + "/sdd-archive/rules/execution-closure-gate.md";
  syncSpecs = skillsDir + "/sdd-archive/rules/execution-sync-specs.md";
  moveArchive = skillsDir + "/sdd-archive/rules/execution-move-archive.md";
  verifyArchive = skillsDir + "/sdd-archive/rules/execution-verify-archive.md";
  verifyReport = skillsDir + "/sdd-verify/rules/execution-return-report.md";

  requiredMarkers = {
    closurePolicy = {
      file = closurePolicy;
      markers = [
        "Successful Closure"
        "Non-Success Dispositions"
        "unverified"
        "paused"
        "abandoned"
        "Canonical Spec Promotion"
        "Never Fabricate a PASS"
        "aytordev-sdd closure"
      ];
    };
    archiveSkill = {
      file = archiveSkill;
      markers = [
        "aytordev-sdd closure"
        "aytordev-sdd compose"
        "sdd-result/v1"
        "closure-policy.md"
        "verified"
      ];
    };
    archiveConstraints = {
      file = archiveConstraints;
      markers = [
        "closure gate"
        "NEVER overwrite"
        "fabricated PASS"
        "diff -r"
        "sdd-result/v1"
      ];
    };
    closureGate = {
      file = closureGate;
      markers = [
        "aytordev-sdd.closure/v1"
        "incomplete-tasks"
        "unverified"
        "stale-verification"
        "--revision"
        "blocked"
      ];
    };
    syncSpecs = {
      file = syncSpecs;
      markers = [
        "aytordev-sdd compose"
        "RENAMED"
        "preserve"
        "refuse"
        "staging"
        "full spec"
      ];
    };
    moveArchive = {
      file = moveArchive;
      markers = [
        "diff -r"
        "collision"
        "snapshot"
        "recovery"
        "refusing to overwrite"
      ];
    };
    verifyArchive = {
      file = verifyArchive;
      markers = [
        "sdd-result/v1"
        "blocked"
        "partial"
        "cancelled"
        "never"
      ];
    };
    verifyReport = {
      file = verifyReport;
      markers = [
        "gentle-ai.verify-result/v1"
        "evidence_revision"
        "non-empty"
      ];
    };
  };

  markerProblems =
    lib.concatMap
    (name: let
      spec = requiredMarkers.${name};
    in
      lib.optional
      (!(lib.all (needle: lib.hasInfix needle (text spec.file)) spec.markers))
      "  - ${rel spec.file}: missing one of ${builtins.toJSON spec.markers}")
    (builtins.attrNames requiredMarkers);

  failedBehaviors = builtins.attrNames (lib.filterAttrs (_: ok: !ok) behaviorChecks);
  problems = builtins.map (name: "  - closure behavior '${name}' failed") failedBehaviors ++ markerProblems;

  # --- Home/adapters for the executable layer ------------------------------
  mkHome = {enable ? true}:
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "ai-tools-archive-check";
      extraSpecialArgs = {inherit identity;};
      modules = [
        {
          aytordev = {
            user = {
              enable = true;
              name = identity.username;
              inherit (identity) email fullName;
              home = homeDirectory;
            };
            programs.terminal.tools.gentle-ai = {inherit enable;};
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  engineCfg = mkHome {};
  inherit (engineCfg.aytordev.programs.terminal.tools.gentle-ai) adapter engramPackage;
in
  if problems != []
  then
    throw (lib.concatStringsSep "\n" (
      ["AI-tools archive/closure violations in modules/common/ai-tools:"]
      ++ problems
      ++ ["Keep the C11 gate, deterministic compose, and lossless archive canonical in skills/sdd-archive and _shared/closure-policy.md."]
    ))
  else
    pkgs.runCommand "ai-tools-archive-check" {
      nativeBuildInputs = [
        pkgs.jq
        pkgs.coreutils
        pkgs.diffutils
        pkgs.findutils
        pkgs.gnugrep
        pkgs.gnused
        engramPackage
      ];
    } ''
      set -eu

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      export AYTORDEV_SDD_ROOT="$TMPDIR/ws"
      WS="$AYTORDEV_SDD_ROOT"
      ADAPTER="${adapter}/bin/aytordev-sdd"

      mkdir -p "$WS/openspec/changes"
      printf 'schema: spec-driven\n' > "$WS/openspec/config.yaml"

      hash_of() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

      # ---------- deterministic composition --------------------------------
      mkdir -p "$WS/openspec/specs/auth"
      cat > "$WS/openspec/specs/auth/spec.md" <<'EOF'
      # Auth Spec

      ### Requirement: Login
      Users MUST log in.

      #### Scenario: Valid login
      - Given a user
      - When they log in
      - Then they are in

      ### Requirement: Logout
      Users MUST log out.

      #### Scenario: Valid logout
      - Given a session
      - When they log out
      - Then it ends
      EOF

      mkdir -p "$WS/openspec/changes/add-token/specs/auth"
      cat > "$WS/openspec/changes/add-token/specs/auth/spec.md" <<'EOF'
      ## ADDED Requirements

      ### Requirement: Token Refresh
      Tokens MUST refresh.

      #### Scenario: Refresh
      - Given an expiring token
      - When it is used
      - Then it is refreshed
      EOF

      "$ADAPTER" compose \
        --canonical "$WS/openspec/specs/auth/spec.md" \
        --delta "$WS/openspec/changes/add-token/specs/auth/spec.md" \
        --output "$WS/staged.spec.md"

      # Unrelated canonical requirements survive byte-for-byte.
      grep -q '^### Requirement: Login$' "$WS/staged.spec.md"
      grep -q '^### Requirement: Logout$' "$WS/staged.spec.md"
      grep -q '^### Requirement: Token Refresh$' "$WS/staged.spec.md"
      grep -q '^Users MUST log in\.$' "$WS/staged.spec.md"
      # The canonical spec is not touched by a staged compose.
      grep -q '^### Requirement: Token Refresh$' "$WS/openspec/specs/auth/spec.md" \
        && { echo "canonical spec was mutated by a staged compose" >&2; exit 1; } || true

      # ---------- malformed delta writes nothing ---------------------------
      cat > "$WS/bad-delta.md" <<'EOF'
      ## MODIFIED Requirements

      ### Requirement: Ghost
      This names a requirement that does not exist.
      EOF
      printf 'SENTINEL\n' > "$WS/bad-out.md"
      set +e
      "$ADAPTER" compose \
        --canonical "$WS/openspec/specs/auth/spec.md" \
        --delta "$WS/bad-delta.md" \
        --output "$WS/bad-out.md" >/dev/null 2>&1
      bad_exit=$?
      set -e
      [ "$bad_exit" -ne 0 ]
      grep -q '^SENTINEL$' "$WS/bad-out.md"

      # ---------- renames: applied or explicitly refused --------------------
      cat > "$WS/rename-ok.md" <<'EOF'
      ## RENAMED Requirements

      ### Requirement: Logout → Session End
      (Reason: clearer name)
      EOF
      "$ADAPTER" compose \
        --canonical "$WS/openspec/specs/auth/spec.md" \
        --delta "$WS/rename-ok.md" \
        --output "$WS/renamed.spec.md"
      grep -q '^### Requirement: Session End$' "$WS/renamed.spec.md"
      grep -q '^### Requirement: Logout$' "$WS/renamed.spec.md" \
        && { echo "rename was not applied" >&2; exit 1; } || true

      cat > "$WS/rename-bad.md" <<'EOF'
      ## RENAMED Requirements

      ### Requirement: Logout → Session End
      EOF
      set +e
      "$ADAPTER" compose \
        --canonical "$WS/openspec/specs/auth/spec.md" \
        --delta "$WS/rename-bad.md" \
        --output "$WS/rename-bad-out.md" >/dev/null 2>&1
      rename_exit=$?
      set -e
      [ "$rename_exit" -ne 0 ]

      # ---------- mechanical archive: collision + lossless move -------------
      mkdir -p "$WS/openspec/changes/keepme"
      printf 'source\n' > "$WS/openspec/changes/keepme/proposal.md"
      mkdir -p "$WS/openspec/changes/archive/2020-01-01-keepme"
      printf 'AUDIT\n' > "$WS/openspec/changes/archive/2020-01-01-keepme/proposal.md"
      set +e
      "$ADAPTER" archive keepme --date 2020-01-01 >/dev/null 2>&1
      collide_exit=$?
      set -e
      [ "$collide_exit" -ne 0 ]
      grep -q '^AUDIT$' "$WS/openspec/changes/archive/2020-01-01-keepme/proposal.md"
      grep -q '^source$' "$WS/openspec/changes/keepme/proposal.md"

      mkdir -p "$WS/openspec/changes/moveme/specs/core"
      printf 'proposal\n' > "$WS/openspec/changes/moveme/proposal.md"
      printf '# Spec\n' > "$WS/openspec/changes/moveme/specs/core/spec.md"
      archive_json="$("$ADAPTER" archive moveme --date 2020-01-02)"
      [ ! -e "$WS/openspec/changes/moveme" ]
      [ -f "$WS/openspec/changes/archive/2020-01-02-moveme/proposal.md" ]
      [ -f "$WS/openspec/changes/archive/2020-01-02-moveme/specs/core/spec.md" ]
      echo "$archive_json" | jq --exit-status '.schema == "aytordev-sdd.archive/v1" and .files == 2' >/dev/null

      # ---------- closure gate: block stale/failed/incomplete ---------------
      mk_spec() {
        mkdir -p "$WS/openspec/changes/$1/specs/core"
        cat > "$WS/openspec/changes/$1/specs/core/spec.md" <<'EOF'
      ## ADDED Requirements

      ### Requirement: Counter
      The system SHALL increment.

      #### Scenario: Once
      - GIVEN zero
      - WHEN increment runs
      - THEN it is one
      EOF
        printf '# Design\n' > "$WS/openspec/changes/$1/design.md"
        printf '# Proposal\n' > "$WS/openspec/changes/$1/proposal.md"
      }

      # incomplete tasks
      mk_spec full
      printf '# Tasks\n- [ ] 1.1 Add module\n' > "$WS/openspec/changes/full/tasks.md"
      set +e
      full_out="$("$ADAPTER" closure full 2>/dev/null)"
      full_exit=$?
      set -e
      [ "$full_exit" -ne 0 ]
      echo "$full_out" | jq --exit-status '.disposition == "incomplete-tasks" and .ready == false' >/dev/null

      # tasks complete, verification missing
      mk_spec blocked
      printf '# Tasks\n- [x] 1.1 Add module\n' > "$WS/openspec/changes/blocked/tasks.md"
      set +e
      blocked_out="$("$ADAPTER" closure blocked 2>/dev/null)"
      blocked_exit=$?
      set -e
      [ "$blocked_exit" -ne 0 ]
      echo "$blocked_out" | jq --exit-status '.disposition == "unverified" and .ready == false' >/dev/null

      # tasks complete + failed verification verdict is also unverified
      failed_rev="sha256:$(hash_of failed-rev)"
      mk_spec failed
      printf '# Tasks\n- [x] 1.1 Add module\n' > "$WS/openspec/changes/failed/tasks.md"
      {
        printf '```yaml\n'
        printf 'schema: gentle-ai.verify-result/v1\n'
        printf 'evidence_revision: %s\n' "$failed_rev"
        printf 'verdict: fail\n'
        printf 'blockers: 0\n'
        printf 'critical_findings: 1\n'
        printf 'requirements: 1/1\n'
        printf 'scenarios: 1/1\n'
        printf 'test_command: true\n'
        printf 'test_exit_code: 1\n'
        printf 'test_output_hash: %s\n' "sha256:$(hash_of failed-tests)"
        printf 'build_command: true\n'
        printf 'build_exit_code: 0\n'
        printf 'build_output_hash: %s\n' "sha256:$(hash_of failed-build)"
        printf '```\n\n# Verification Report\n'
      } > "$WS/openspec/changes/failed/verify-report.md"
      set +e
      failed_out="$("$ADAPTER" closure failed 2>/dev/null)"
      failed_exit=$?
      set -e
      [ "$failed_exit" -ne 0 ]
      echo "$failed_out" | jq --exit-status '.disposition == "unverified" and .ready == false' >/dev/null

      # tasks complete + valid engine verify envelope bound to a revision
      rev="sha256:$(hash_of rev)"
      out_hash="sha256:$(hash_of tests)"
      build_hash="sha256:$(hash_of build)"
      mk_spec verified
      printf '# Tasks\n- [x] 1.1 Add module\n' > "$WS/openspec/changes/verified/tasks.md"
      {
        printf '```yaml\n'
        printf 'schema: gentle-ai.verify-result/v1\n'
        printf 'evidence_revision: %s\n' "$rev"
        printf 'verdict: pass\n'
        printf 'blockers: 0\n'
        printf 'critical_findings: 0\n'
        printf 'requirements: 1/1\n'
        printf 'scenarios: 1/1\n'
        printf 'test_command: true\n'
        printf 'test_exit_code: 0\n'
        printf 'test_output_hash: %s\n' "$out_hash"
        printf 'build_command: true\n'
        printf 'build_exit_code: 0\n'
        printf 'build_output_hash: %s\n' "$build_hash"
        printf '```\n\n# Verification Report\n'
      } > "$WS/openspec/changes/verified/verify-report.md"

      "$ADAPTER" closure verified --revision "$rev" \
        | jq --exit-status '.disposition == "verified" and .ready == true and .tasks.allComplete == true' >/dev/null

      # a well-formed but stale revision is refused
      stale_rev="sha256:$(hash_of stale)"
      set +e
      stale_out="$("$ADAPTER" closure verified --revision "$stale_rev" 2>/dev/null)"
      stale_exit=$?
      set -e
      [ "$stale_exit" -ne 0 ]
      echo "$stale_out" | jq --exit-status '.disposition == "stale-verification" and .ready == false' >/dev/null

      # ---------- closure gate: Engram resolves the revision from memory -----
      # In an Engram store `artifactPaths.verifyReport` is a topic key
      # (`sdd/<change>/verify-report`), not a file path, so the adapter must
      # read the report body back from memory. The gate is unchanged: a
      # matching revision promotes and a different one is refused as stale.
      ENGRAM_WS="$TMPDIR/ws-engram"
      mkdir -p "$ENGRAM_WS/openspec"
      printf 'artifact_store: engram\n' > "$ENGRAM_WS/openspec/config.yaml"
      export ENGRAM_DATA_DIR="$TMPDIR/engram-data"
      export ENGRAM_NO_UPDATE_CHECK=1
      engram_project="$(basename "$ENGRAM_WS")"
      engram_rev="sha256:$(hash_of engram-rev)"

      cat > "$TMPDIR/engram-spec.md" <<'EOF'
      ## ADDED Requirements

      ### Requirement: Counter
      The system SHALL increment.

      #### Scenario: Once
      - GIVEN zero
      - WHEN increment runs
      - THEN it is one
      EOF

      {
        printf '```yaml\n'
        printf 'schema: gentle-ai.verify-result/v1\n'
        printf 'evidence_revision: %s\n' "$engram_rev"
        printf 'verdict: pass\n'
        printf 'blockers: 0\n'
        printf 'critical_findings: 0\n'
        printf 'requirements: 1/1\n'
        printf 'scenarios: 1/1\n'
        printf 'test_command: true\n'
        printf 'test_exit_code: 0\n'
        printf 'test_output_hash: %s\n' "sha256:$(hash_of engram-tests)"
        printf 'build_command: true\n'
        printf 'build_exit_code: 0\n'
        printf 'build_output_hash: %s\n' "sha256:$(hash_of engram-build)"
        printf '```\n\n# Verification Report\n'
      } > "$TMPDIR/engram-report.md"

      engram save "sdd/eng/proposal" "# Proposal" --project "$engram_project" --scope project >/dev/null
      engram save "sdd/eng/spec" "$(cat "$TMPDIR/engram-spec.md")" --project "$engram_project" --scope project >/dev/null
      engram save "sdd/eng/design" "# Design" --project "$engram_project" --scope project >/dev/null
      engram save "sdd/eng/tasks" "$(printf '# Tasks\n- [x] 1.1 Add module\n')" --project "$engram_project" --scope project >/dev/null
      engram save "sdd/eng/verify-report" "$(cat "$TMPDIR/engram-report.md")" --project "$engram_project" --scope project >/dev/null

      # The revision is read from Engram and a match promotes.
      set +e
      AYTORDEV_SDD_ROOT="$ENGRAM_WS" "$ADAPTER" closure eng --revision "$engram_rev" > "$TMPDIR/engram-ok.json" 2>/dev/null
      engram_ok_exit=$?
      set -e
      [ "$engram_ok_exit" -eq 0 ]
      jq --exit-status --arg rev "$engram_rev" \
        '.disposition == "verified" and .ready == true and .verification.envelopeRevision == $rev' \
        "$TMPDIR/engram-ok.json" >/dev/null

      # A different revision is still refused as stale (gate intact).
      engram_stale="sha256:$(hash_of engram-stale)"
      set +e
      AYTORDEV_SDD_ROOT="$ENGRAM_WS" "$ADAPTER" closure eng --revision "$engram_stale" > "$TMPDIR/engram-stale.json" 2>/dev/null
      engram_stale_exit=$?
      set -e
      [ "$engram_stale_exit" -ne 0 ]
      jq --exit-status '.disposition == "stale-verification" and .ready == false' "$TMPDIR/engram-stale.json" >/dev/null

      # ---------- machine-readable fixture ---------------------------------
      mkdir -p "$out"
      jq --null-input \
        '{
          schema: "ai-tools-archive/v1",
          closure: {verified: true, staleBlocked: true, incompleteBlocked: true, unverifiedBlocked: true, failedBlocked: true, engramVerified: true, engramStaleBlocked: true},
          compose: {unrelatedSurvive: true, malformedWritesNothing: true, renameApplied: true, renameRefused: true},
          archive: {collisionRefused: true, losslessMove: true}
        }' > "$out/archive-fixture.json"
      cat "$out/archive-fixture.json"
    ''
