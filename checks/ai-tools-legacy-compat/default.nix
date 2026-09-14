# T25 integration check: legacy artifact compatibility and migration.
#
# Proves, on a disposable workspace through the real `aytordev-sdd` adapter:
#   - each supported legacy input is read or converted with a readback;
#   - every conversion preserves the original bytes and previews its output;
#   - an unknown format stops with a reason and leaves the original intact;
#   - a migrated old PASS is never current evidence for new code (the envelope
#     conversion is non-advancing and the C11 gate refuses a legacy report);
#   - a partially failed conversion keeps a recoverable original.
#
# Fixtures are redacted copies of the confirmed legacy surfaces (legacy
# registry cache, legacy phase envelope, bold scenario grammar, legacy verify
# report); they live under `fixtures/` and are copied to a writable directory
# before use so the store originals are never touched.
{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "ai-tools-legacy-check";
    email = "ai-tools-legacy-check@example.test";
    fullName = "AI Tools Legacy Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  mkHome =
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "ai-tools-legacy-check";
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
            programs.terminal.tools.gentle-ai.enable = true;
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  inherit (mkHome.aytordev.programs.terminal.tools.gentle-ai) adapter;
in
  pkgs.runCommand "ai-tools-legacy-compat-check" {
    nativeBuildInputs = [
      pkgs.jq
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.gnugrep
      pkgs.diffutils
    ];
  } ''
    set -eu

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export AYTORDEV_SDD_ROOT="$TMPDIR/ws"
    WS="$AYTORDEV_SDD_ROOT"
    mkdir -p "$WS/openspec/changes"
    printf 'schema: spec-driven\n' > "$WS/openspec/config.yaml"

    ADAPTER="${adapter}/bin/aytordev-sdd"
    FX="$TMPDIR/fixtures"
    cp -R ${./fixtures} "$FX"

    sha() { sha256sum "$1" | cut -d' ' -f1; }
    fail() { echo "LEGACY-COMPAT FAIL: $*" >&2; exit 1; }

    # --- registry cache: legacy cache is detected, preserved, regenerated ----
    cp "$FX/legacy-registry.md" "$TMPDIR/legacy-registry.md"
    before="$(sha "$TMPDIR/legacy-registry.md")"
    set +e
    reg_out="$("$ADAPTER" migrate registry --input "$TMPDIR/legacy-registry.md")"
    reg_rc=$?
    set -e
    [ "$reg_rc" -eq 3 ] || fail "legacy registry must stop with exit 3 (got $reg_rc)"
    echo "$reg_out" | jq --exit-status \
      '.schema == "aytordev-sdd.migrate/v1" and .class == "requires-regeneration" and .originalPreserved == true' >/dev/null \
      || fail "legacy registry verdict"
    [ -f "$TMPDIR/legacy-registry.md.legacy" ] || fail "legacy registry backup not preserved"
    [ "$before" = "$(sha "$TMPDIR/legacy-registry.md")" ] || fail "legacy registry original was mutated"
    grep -q '^## Compact Rules' "$TMPDIR/legacy-registry.md.legacy" || fail "backup is not the legacy bytes"

    index_out="$("$ADAPTER" migrate registry --input "$FX/index-registry.md")"
    echo "$index_out" | jq --exit-status '.class == "already-current"' >/dev/null \
      || fail "index-first registry should be already-current"

    # --- phase envelope: converted to a non-advancing sdd-result/v1 ----------
    cp "$FX/legacy-envelope.json" "$TMPDIR/envelope.json"
    before="$(sha "$TMPDIR/envelope.json")"
    env_out="$("$ADAPTER" migrate envelope --input "$TMPDIR/envelope.json" --output "$TMPDIR/envelope.migrated.json")"
    echo "$env_out" | jq --exit-status '.class == "converted" and .readback == "ok"' >/dev/null \
      || fail "legacy envelope conversion verdict"
    jq --exit-status \
      '.schema == "sdd-result/v1" and .kind == "final" and .status != "success" and .legacy_status == "ok" and (.evidence | length) == 0' \
      "$TMPDIR/envelope.migrated.json" >/dev/null \
      || fail "migrated old PASS must not become advancing current evidence"
    [ "$before" = "$(sha "$TMPDIR/envelope.json")" ] || fail "envelope original was mutated"

    "$ADAPTER" migrate envelope --input "$FX/current-envelope.json" \
      | jq --exit-status '.class == "already-current"' >/dev/null \
      || fail "current sdd-result/v1 should be already-current"

    failed_out="$("$ADAPTER" migrate envelope --input "$FX/failed-envelope.json" --output "$TMPDIR/failed.migrated.json")"
    echo "$failed_out" | jq --exit-status '.class == "converted"' >/dev/null
    jq --exit-status '.status == "failed"' "$TMPDIR/failed.migrated.json" >/dev/null \
      || fail "legacy failed status must map to failed"

    # --- unknown format stops with a reason, original intact -----------------
    cp "$FX/unknown-envelope.json" "$TMPDIR/unknown.json"
    before="$(sha "$TMPDIR/unknown.json")"
    set +e
    unknown_out="$("$ADAPTER" migrate envelope --input "$TMPDIR/unknown.json" 2>/dev/null)"
    unknown_rc=$?
    set -e
    [ "$unknown_rc" -eq 4 ] || fail "unknown envelope must stop with exit 4 (got $unknown_rc)"
    echo "$unknown_out" | jq --exit-status '.class == "unknown" and .originalPreserved == true and (.reason | length) > 0' >/dev/null \
      || fail "unknown envelope verdict"
    [ "$before" = "$(sha "$TMPDIR/unknown.json")" ] || fail "unknown envelope original was mutated"
    [ ! -e "$TMPDIR/unknown.json.migrated" ] || fail "unknown format must not produce output"

    # --- spec grammar: bold scenarios normalized with readback ---------------
    cp "$FX/legacy-spec.md" "$TMPDIR/legacy-spec.md"
    before="$(sha "$TMPDIR/legacy-spec.md")"
    spec_out="$("$ADAPTER" migrate scenarios --input "$TMPDIR/legacy-spec.md" --backend openspec --output "$TMPDIR/spec.canonical.md")"
    echo "$spec_out" | jq --exit-status '.class == "converted" and .readback == "ok"' >/dev/null \
      || fail "legacy scenario conversion verdict"
    [ "$(grep -cE '^#### Scenario:' "$TMPDIR/spec.canonical.md")" -eq 2 ] || fail "expected 2 canonical scenarios"
    [ "$(grep -cE '^\*\*Scenario:' "$TMPDIR/spec.canonical.md" || true)" -eq 0 ] || fail "bold scenarios survived conversion"
    [ "$before" = "$(sha "$TMPDIR/legacy-spec.md")" ] || fail "spec original was mutated"

    "$ADAPTER" migrate scenarios --input "$FX/canonical-spec.md" --backend openspec \
      | jq --exit-status '.class == "already-current"' >/dev/null \
      || fail "canonical spec should be already-current"

    # Backend-aware: memory-backed and ephemeral specs are not file-converted.
    set +e
    engram_out="$("$ADAPTER" migrate scenarios --input "$FX/legacy-spec.md" --backend engram 2>/dev/null)"
    engram_rc=$?
    set -e
    [ "$engram_rc" -eq 3 ] || fail "engram scenario conversion must stop (got $engram_rc)"
    echo "$engram_out" | jq --exit-status '.class == "requires-manual-decision"' >/dev/null \
      || fail "engram scenario verdict"

    # --- partial failure preserves a recoverable original --------------------
    before="$(sha "$TMPDIR/legacy-spec.md")"
    set +e
    "$ADAPTER" migrate scenarios --input "$TMPDIR/legacy-spec.md" --backend openspec --output "$TMPDIR/no-such-dir/out.md" >/dev/null 2>&1
    partial_rc=$?
    set -e
    [ "$partial_rc" -ne 0 ] || fail "conversion into a missing directory must fail"
    [ "$before" = "$(sha "$TMPDIR/legacy-spec.md")" ] || fail "partial failure mutated the original"

    # --- dry run previews without publishing ---------------------------------
    dry_out="$("$ADAPTER" migrate envelope --input "$TMPDIR/envelope.json" --output "$TMPDIR/dry.json" --dry-run)"
    echo "$dry_out" | jq --exit-status '.readback == "preview-only"' >/dev/null \
      || fail "dry run verdict"
    [ ! -e "$TMPDIR/dry.json" ] || fail "dry run must not write output"

    # --- verification reports: legacy report is inadmissible -----------------
    set +e
    legacy_report_out="$("$ADAPTER" migrate verify-report --input "$FX/legacy-verify-report.md" 2>/dev/null)"
    legacy_report_rc=$?
    set -e
    [ "$legacy_report_rc" -eq 3 ] || fail "legacy verify report must stop (got $legacy_report_rc)"
    echo "$legacy_report_out" | jq --exit-status '.class == "requires-reverification"' >/dev/null \
      || fail "legacy verify report verdict"

    "$ADAPTER" migrate verify-report --input "$FX/canonical-verify-report.md" \
      | jq --exit-status '.class == "admissible"' >/dev/null \
      || fail "canonical verify report should be admissible"

    # --- C11 gate: an old PASS is not evidence for new code ------------------
    mkdir -p "$WS/openspec/changes/legacy/specs/core"
    cat > "$WS/openspec/changes/legacy/specs/core/spec.md" <<'EOF'
    ## ADDED Requirements

    ### Requirement: Counter
    The system SHALL increment.

    #### Scenario: Once
    - GIVEN zero
    - WHEN increment runs
    - THEN it is one
    EOF
    printf '# Proposal\n' > "$WS/openspec/changes/legacy/proposal.md"
    printf '# Design\n' > "$WS/openspec/changes/legacy/design.md"
    printf '# Tasks\n- [x] 1.1 Add module\n' > "$WS/openspec/changes/legacy/tasks.md"
    cp "$FX/legacy-verify-report.md" "$WS/openspec/changes/legacy/verify-report.md"
    set +e
    gate_out="$("$ADAPTER" closure legacy 2>/dev/null)"
    gate_rc=$?
    set -e
    [ "$gate_rc" -ne 0 ] || fail "closure gate must refuse a legacy PASS report"
    echo "$gate_out" | jq --exit-status '.disposition == "unverified" and .ready == false' >/dev/null \
      || fail "legacy PASS must be unverified at the closure gate"

    # --- machine-readable fixture --------------------------------------------
    mkdir -p "$out"
    jq --null-input \
      '{
        schema: "ai-tools-legacy-compat/v1",
        registry: {legacyDetected: true, originalPreserved: true, alreadyCurrent: true},
        envelope: {converted: true, nonAdvancing: true, alreadyCurrent: true, unknownStopped: true},
        scenarios: {converted: true, readback: true, alreadyCurrent: true, backendAware: true},
        verifyReport: {legacyInadmissible: true, canonicalAdmissible: true},
        negative: {unknownLeavesOriginal: true, partialFailureRecoverable: true, dryRunNoWrite: true, oldPassNotEvidence: true}
      }' > "$out/legacy-compat-fixture.json"
    cat "$out/legacy-compat-fixture.json"
  ''
