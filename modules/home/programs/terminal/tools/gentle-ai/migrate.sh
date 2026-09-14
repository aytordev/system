#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Legacy artifact compatibility (T25).
#
# Reads the legacy on-disk formats the SDD workflow produced before
# `sdd-result/v1` / the engine verify envelope / the index-first registry and
# either converts them losslessly or stops with a useful reason. Every
# conversion:
#   - previews the converted bytes,
#   - never mutates the input file,
#   - writes through a temp file and publishes atomically (interruption/retry
#     safe),
#   - reads its own result back before reporting success.
# No conversion fabricates a PASS, re-initializes a change, deletes a memory or
# observation, or overwrites a spec. Unknown shapes stop with a reason and
# leave the original byte-identical.
#
# Kept as a separate file so the embedded adapter stays readable; it is
# inlined into the `aytordev-sdd` writeShellApplication via `builtins.readFile`.
# ---------------------------------------------------------------------------

emit_migrate() {
    # $1 kind, $2 class, $3 output, $4 original_preserved, $5 readback,
    # $6 reason, $7 exit code.
    jq -n \
        --arg schema "aytordev-sdd.migrate/v1" \
        --arg kind "$1" \
        --arg class "$2" \
        --arg backend "$backend" \
        --arg input "$input" \
        --arg output "$3" \
        --argjson originalPreserved "$4" \
        --arg readback "$5" \
        --arg reason "$6" \
        '{schema: $schema, kind: $kind, class: $class, backend: $backend, input: $input, output: $output, originalPreserved: $originalPreserved, readback: $readback, reason: $reason}'
    exit "$7"
}

preview_file() {
    echo "--- preview (first 20 lines of converted output) ---" >&2
    sed -n '1,20p' "$1" >&2
    echo "--- end preview ---" >&2
}

publish_file() {
    # $1 temp, $2 output. Refuses to publish into a missing directory.
    [ -d "$(dirname "$2")" ] || return 1
    mv "$1" "$2"
}

migrate_registry() {
    if grep -q '^## Index' "$input" 2>/dev/null; then
        emit_migrate "registry" "already-current" "" true "ok" \
            "index-first registry; no conversion needed" 0
    fi
    if grep -qE '^## (Compact Rules|Skills Index)' "$input" 2>/dev/null; then
        backup="$input.legacy"
        n=1
        while [ -e "$backup" ]; do
            backup="$input.legacy.$n"
            n=$((n + 1))
        done
        if [ "$dry_run" -eq 1 ]; then
            emit_migrate "registry" "requires-regeneration" "$backup" true "preview-only" \
                "legacy registry cannot satisfy the index-first contract; regenerate with the skill-registry skill (dry run: nothing written)" 3
        fi
        cp -p "$input" "$backup"
        emit_migrate "registry" "requires-regeneration" "$backup" true "original-bytes-preserved" \
            "legacy registry cannot satisfy the index-first contract; original preserved at '$backup'; regenerate with the skill-registry skill" 3
    fi
    emit_migrate "registry" "unknown" "" true "none" \
        "unrecognized registry format; refusing to treat it as an index; original untouched" 4
}

migrate_envelope() {
    if ! jq -e . "$input" >/dev/null 2>&1; then
        emit_migrate "envelope" "unknown" "" true "none" \
            "input is not valid JSON; refusing to convert; original untouched" 4
    fi
    current_schema="$(jq -r '.schema // empty' "$input")"
    if [ "$current_schema" = "sdd-result/v1" ]; then
        emit_migrate "envelope" "already-current" "" true "ok" \
            "already sdd-result/v1; no conversion needed" 0
    fi
    legacy_status="$(jq -r '.status // empty' "$input")"
    case "$legacy_status" in
    ok | warning | blocked | failed) ;;
    *)
        emit_migrate "envelope" "unknown" "" true "none" \
            "unrecognized legacy envelope: missing known 'status' (got '$legacy_status'); original untouched" 4
        ;;
    esac
    if ! jq -e '.artifacts | type == "array"' "$input" >/dev/null 2>&1; then
        emit_migrate "envelope" "unknown" "" true "none" \
            "unrecognized legacy envelope: 'artifacts' is not a list; original untouched" 4
    fi
    case "$legacy_status" in
    ok | warning) new_status="partial" ;;
    blocked) new_status="blocked" ;;
    *) new_status="failed" ;;
    esac
    if [ -z "$output" ]; then
        output="$input.migrated"
    fi
    if [ ! -d "$(dirname "$output")" ]; then
        emit_migrate "envelope" "unknown" "" true "none" \
            "output directory '$(dirname "$output")' does not exist; original untouched" 5
    fi
    tmp="$(mktemp "$(dirname "$output")/.aytordev-migrate.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    jq \
        --arg newStatus "$new_status" \
        --arg legacy "$legacy_status" \
        '{
            schema: "sdd-result/v1",
            kind: "final",
            status: $newStatus,
            legacy_status: $legacy,
            executive_summary: (.executive_summary // "Migrated legacy envelope"),
            artifacts: [ .artifacts[] | if type == "object" then ((.type // "artifact") + ": " + (.location // "unknown")) else tostring end ],
            evidence: [],
            next_recommended: (.next_recommended // ""),
            risks: ((.risks // []) + ["Migrated legacy envelope (legacy status " + $legacy + "): historical, not current evidence; re-establish evidence before advancing."]),
            skill_resolution: "none"
        }' "$input" >"$tmp"
    if ! jq -e '.schema == "sdd-result/v1" and .kind == "final" and .status != "success" and (.evidence | length) == 0' "$tmp" >/dev/null 2>&1; then
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "envelope" "unknown" "" true "readback-failed" \
            "converted output failed readback; original untouched" 5
    fi
    preview_file "$tmp"
    if [ "$dry_run" -eq 1 ]; then
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "envelope" "converted" "$output" true "preview-only" \
            "dry run: no output written; original untouched" 0
    fi
    publish_file "$tmp" "$output" || {
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "envelope" "unknown" "" true "publish-failed" \
            "could not publish output; original untouched" 5
    }
    trap - EXIT
    emit_migrate "envelope" "converted" "$output" true "ok" \
        "converted legacy status '$legacy_status' to non-advancing sdd-result/v1" 0
}

migrate_scenarios() {
    case "$backend" in
    engram)
        emit_migrate "scenarios" "requires-manual-decision" "" true "none" \
            "spec is stored in Engram memory; convert through the phase skill, not the file adapter; original untouched" 3
        ;;
    none)
        emit_migrate "scenarios" "requires-manual-decision" "" true "none" \
            "none backend has no persisted spec file to convert; original untouched" 3
        ;;
    openspec | hybrid) ;;
    *)
        emit_migrate "scenarios" "unknown" "" true "none" \
            "unknown backend '$backend'" 4
        ;;
    esac
    canonical="$(grep -cE '^#### Scenario:' "$input" || true)"
    legacy="$(grep -cE '^\*\*Scenario: .*\*\*[[:space:]]*$' "$input" || true)"
    if [ "$legacy" -eq 0 ] && [ "$canonical" -gt 0 ]; then
        emit_migrate "scenarios" "already-current" "" true "ok" \
            "already canonical (#### Scenario:)" 0
    fi
    if [ "$legacy" -eq 0 ]; then
        emit_migrate "scenarios" "unknown" "" true "none" \
            "no scenario headings in either supported grammar; refusing to convert; original untouched" 4
    fi
    if [ -z "$output" ]; then
        output="$input.canonical.md"
    fi
    if [ ! -d "$(dirname "$output")" ]; then
        emit_migrate "scenarios" "unknown" "" true "none" \
            "output directory '$(dirname "$output")' does not exist; original untouched" 5
    fi
    tmp="$(mktemp "$(dirname "$output")/.aytordev-migrate.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    sed -E \
        -e '/^#### Scenarios[[:space:]]*$/d' \
        -e 's/^[[:space:]]*\*\*Scenario: (.*)\*\*[[:space:]]*$/#### Scenario: \1/' \
        "$input" >"$tmp"
    new_canonical="$(grep -cE '^#### Scenario:' "$tmp" || true)"
    leftover="$(grep -cE '^\*\*Scenario:' "$tmp" || true)"
    expected=$((canonical + legacy))
    if [ "$new_canonical" -ne "$expected" ] || [ "$leftover" -ne 0 ]; then
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "scenarios" "unknown" "" true "readback-failed" \
            "conversion readback mismatch (canonical $new_canonical/$expected, leftover bold $leftover); original untouched" 5
    fi
    preview_file "$tmp"
    if [ "$dry_run" -eq 1 ]; then
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "scenarios" "converted" "$output" true "preview-only" \
            "dry run: no output written; original untouched" 0
    fi
    publish_file "$tmp" "$output" || {
        rm -f "$tmp"
        trap - EXIT
        emit_migrate "scenarios" "unknown" "" true "publish-failed" \
            "could not publish output; original untouched" 5
    }
    trap - EXIT
    emit_migrate "scenarios" "converted" "$output" true "ok" \
        "normalized $legacy legacy scenario heading(s) to #### Scenario:" 0
}

migrate_verify_report() {
    first="$(awk 'NF { print; exit }' "$input")"
    if [ "$first" = '```yaml' ]; then
        schema="$(awk '
            !seen && NF { if ($0 == "```yaml") { seen = 1; next } else { exit } }
            seen && /^```/ { exit }
            seen && /^schema:[[:space:]]*/ { sub(/^schema:[[:space:]]*/, ""); print; exit }
        ' "$input")"
        if [ "$schema" = "gentle-ai.verify-result/v1" ]; then
            emit_migrate "verify-report" "admissible" "" true "ok" \
                "engine verify envelope present; report is admissible" 0
        fi
        emit_migrate "verify-report" "requires-reverification" "" true "none" \
            "first fence is yaml but not the engine verify schema; re-run sdd-verify; never fabricate a PASS; original untouched" 3
    fi
    emit_migrate "verify-report" "requires-reverification" "" true "none" \
        "legacy markdown report without the engine verify envelope; re-run sdd-verify; never fabricate a PASS; original untouched" 3
}

migrate() {
    if [ "$#" -lt 1 ]; then
        echo "usage: aytordev-sdd migrate <registry|envelope|scenarios|verify-report> --input <file> [--output <file>] [--backend <engram|openspec|hybrid|none>] [--dry-run]" >&2
        exit 64
    fi
    kind="$1"
    shift
    input=""
    output=""
    backend="openspec"
    dry_run=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
        --input)
            input="${2:-}"
            shift 2
            ;;
        --output)
            output="${2:-}"
            shift 2
            ;;
        --backend)
            backend="${2:-}"
            shift 2
            ;;
        --dry-run)
            dry_run=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "aytordev-sdd migrate: unknown flag '$1'" >&2
            exit 64
            ;;
        esac
    done
    if [ -z "$input" ]; then
        echo "aytordev-sdd migrate: --input is required" >&2
        exit 64
    fi
    if [ ! -f "$input" ]; then
        emit_migrate "$kind" "unknown" "" true "none" \
            "input '$input' is not a readable file" 4
    fi
    case "$kind" in
    registry) migrate_registry ;;
    envelope) migrate_envelope ;;
    scenarios) migrate_scenarios ;;
    verify-report) migrate_verify_report ;;
    *)
        echo "aytordev-sdd migrate: unknown kind '$kind' (want registry|envelope|scenarios|verify-report)" >&2
        exit 64
        ;;
    esac
}
