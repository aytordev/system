{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    optionalString
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.gentle-ai;

  # The adapter is the single call surface for the pinned gentle-ai engine
  # (ADR 0015, C12 / T27). It owns the environment the engine needs so no
  # client or skill has to know the engine's raw `sdd-*` subcommand names or
  # its `gentle-ai.sdd-status/v2` JSON schema:
  #
  #   - ENGRAM_DATA_DIR: defaults to the same directory the Engram MCP server
  #     writes to (`mcp/default.nix`), so the engine's spawned `engram export`
  #     reads the database the SDD skills write (T28).
  #   - ENGRAM_PROJECT: optional pin for the project-name agreement. The engine
  #     otherwise infers `ENGRAM_PROJECT`, then the git-remote basename, then
  #     the workspace directory basename (all lowercased) and matches stored
  #     observations case-insensitively. When a repo's remote basename differs
  #     from the name the SDD writer stamps, this option aligns them.
  #   - cwd: the engine resolves its workspace from the process working
  #     directory, so the adapter keeps `AYTORDEV_SDD_ROOT` (default `$PWD`) as
  #     the single workspace root.
  #
  # An explicit environment value already set by the caller wins, which keeps
  # the adapter testable with an isolated database/root.
  #
  # Explicitly NOT consumed (the surface is excluded, not wired):
  #   - consent / review ledger / `review` command family
  #   - telemetry / `update` / `upgrade` / `restore`
  #   - model routing (`skill-registry`, provider/model dispatch)
  # Only the workflow read/validate/closure surface used by the SDD phases is
  # exposed. The engine's validators and archive composer are reused as-is
  # (T20/T21); the adapter never reimplements them:
  #
  #   - compose: pass-through to `sdd-archive-compose`, the deterministic
  #     OpenSpec delta composer (unknown/duplicate/malformed deltas are refused
  #     by the engine before it writes anything).
  #   - closure: C11 gate. The engine owns the readiness calculation (complete
  #     tasks + current, validated verification); the adapter translates it to a
  #     stable `aytordev-sdd.closure/v1` verdict and exits non-zero for every
  #     non-success disposition. `--revision` additionally refuses a stale
  #     `evidence_revision`.
  #   - archive: the mechanical OpenSpec move with a pre-move snapshot, a
  #     lossless `diff -r` readback, and collision refusal.
  #   - migrate: legacy artifact compatibility (T25). Converts old on-disk
  #     formats (phase envelopes, bold spec scenarios) or stops with a reason
  #     (legacy compact-rules registries, legacy verify reports). Preview,
  #     preserved originals, atomic publish, and readback are implemented in
  #     `migrate.sh`; the adapter exposes it so no skill handles raw formats.
  adapter = pkgs.writeShellApplication {
    name = "aytordev-sdd";
    runtimeInputs = [
      cfg.package
      cfg.engramPackage
      pkgs.jq
      pkgs.coreutils
      pkgs.diffutils
      pkgs.findutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = ''
      usage() {
        echo "usage: aytordev-sdd <status|continue|attempt|verify|compose|closure|archive|migrate> [args...]"
      }

      # The engine reads its workspace from the process cwd.
      : "''${AYTORDEV_SDD_ROOT:=$PWD}"
      export AYTORDEV_SDD_ROOT
      cd "$AYTORDEV_SDD_ROOT"

      # The adapter owns the database the spawned `engram export` reads. An
      # isolated override is honored so verification never touches real memory.
      export ENGRAM_DATA_DIR="''${ENGRAM_DATA_DIR:-${cfg.engramDataDir}}"
      ${optionalString (cfg.engramProject != null) ''
        export ENGRAM_PROJECT="''${ENGRAM_PROJECT:-${cfg.engramProject}}"
      ''}

      # Engram v2.0.0-rc phones GitHub for release update checks on non-help
      # commands; the adapter's spawned `engram export` must stay offline.
      export ENGRAM_NO_UPDATE_CHECK="1"

      # C11 closure gate. The engine keeps the readiness decision; this only
      # names the disposition and refuses anything but a verified closure.
      closure() {
        if [ "$#" -lt 1 ]; then
          echo "usage: aytordev-sdd closure <change> [--revision <sha256>]" >&2
          exit 64
        fi
        change="$1"
        shift
        revision=""
        while [ "$#" -gt 0 ]; do
          case "$1" in
            --revision)
              revision="''${2:-}"
              if [ -z "$revision" ]; then
                echo "aytordev-sdd closure: --revision needs a value" >&2
                exit 64
              fi
              shift 2
              ;;
            *)
              echo "aytordev-sdd closure: unknown flag '$1'" >&2
              exit 64
              ;;
          esac
        done

        status_json="$(gentle-ai sdd-status "$change" --json)" || {
          echo "aytordev-sdd closure: engine status failed for '$change'" >&2
          exit 2
        }

        all_complete="$(jq -r '.taskProgress.allComplete // false' <<<"$status_json")"
        total="$(jq -r '.taskProgress.total // 0' <<<"$status_json")"
        completed="$(jq -r '.taskProgress.completed // 0' <<<"$status_json")"
        archive="$(jq -r '.dependencies.archive // "blocked"' <<<"$status_json")"
        verify="$(jq -r '.artifacts.verifyReport // "missing"' <<<"$status_json")"
        reason="$(jq -r '.blockedReasons[0] // ""' <<<"$status_json")"
        report="$(jq -r '.artifactPaths.verifyReport[0] // empty' <<<"$status_json")"

        envelope_revision=""
        if [ -n "$report" ] && [ -f "$report" ]; then
          envelope_revision="$(
            awk '/^evidence_revision:/{sub(/^evidence_revision:[[:space:]]*/, ""); print; exit}' "$report" 2>/dev/null || true
          )"
        fi

        if [ "$all_complete" != "true" ]; then
          disposition="incomplete-tasks"
          ready=false
        elif [ "$archive" != "ready" ]; then
          disposition="unverified"
          ready=false
        elif [ -n "$revision" ] && [ "$envelope_revision" != "$revision" ]; then
          disposition="stale-verification"
          ready=false
        else
          disposition="verified"
          ready=true
        fi

        jq -n \
          --arg schema "aytordev-sdd.closure/v1" \
          --arg change "$change" \
          --argjson ready "$ready" \
          --arg disposition "$disposition" \
          --argjson total "$total" \
          --argjson completed "$completed" \
          --argjson allComplete "$all_complete" \
          --arg verify "$verify" \
          --arg envelopeRevision "$envelope_revision" \
          --arg archive "$archive" \
          --arg reason "$reason" \
          '{
            schema: $schema,
            change: $change,
            ready: $ready,
            disposition: $disposition,
            tasks: {total: $total, completed: $completed, allComplete: $allComplete},
            verification: {artifact: $verify, envelopeRevision: $envelopeRevision},
            archive: $archive,
            reason: $reason
          }'

        if [ "$ready" = "true" ]; then exit 0; else exit 3; fi
      }

      # Mechanical OpenSpec archive. Not an engine command: the engine composes
      # deltas but does not move the change. The move is lossless and refuses to
      # overwrite; an interrupted run leaves the snapshot in place and names it.
      archive_change() {
        if [ "$#" -lt 1 ]; then
          echo "usage: aytordev-sdd archive <change> [--root <openspec-dir>] [--date YYYY-MM-DD]" >&2
          exit 64
        fi
        change="$1"
        shift
        root="''${AYTORDEV_SDD_ROOT}/openspec"
        archive_date=""
        while [ "$#" -gt 0 ]; do
          case "$1" in
            --root) root="''${2:-}"; shift 2 ;;
            --date) archive_date="''${2:-}"; shift 2 ;;
            *)
              echo "aytordev-sdd archive: unknown flag '$1'" >&2
              exit 64
              ;;
          esac
        done
        [ -n "$archive_date" ] || archive_date="$(date +%Y-%m-%d)"

        src="$root/changes/$change"
        archive_dir="$root/changes/archive"
        dst="$archive_dir/$archive_date-$change"

        if [ ! -d "$src" ]; then
          echo "aytordev-sdd archive: no active change at '$src'" >&2
          exit 4
        fi
        if [ -e "$dst" ]; then
          echo "aytordev-sdd archive: destination '$dst' already exists; refusing to overwrite" >&2
          exit 5
        fi

        mkdir -p "$archive_dir"
        snapshot="$(mktemp -d "''${TMPDIR:-/tmp}/aytordev-archive.XXXXXX")"
        cp -R "$src/." "$snapshot/"

        mv "$src" "$dst"

        if ! diff -r "$snapshot" "$dst" >/dev/null 2>&1; then
          rm -rf "$src"
          cp -R "$snapshot/." "$src/"
          rm -rf "$dst"
          echo "aytordev-sdd archive: readback mismatch; restored '$src' from snapshot '$snapshot' and removed '$dst'" >&2
          echo "recovery: snapshot preserved at '$snapshot'" >&2
          exit 6
        fi

        files="$(find "$dst" -type f | wc -l | tr -d ' ')"
        rm -rf "$snapshot"

        jq -n \
          --arg schema "aytordev-sdd.archive/v1" \
          --arg change "$change" \
          --arg source "$src" \
          --arg destination "$dst" \
          --arg date "$archive_date" \
          --argjson files "$files" \
          '{schema: $schema, change: $change, source: $source, destination: $destination, date: $date, files: $files}'
        exit 0
      }

      ${builtins.readFile ./migrate.sh}

      if [ "$#" -eq 0 ]; then
        usage >&2
        exit 64
      fi

      command="$1"
      shift
      case "$command" in
        -h | --help)
          usage
          exit 0
          ;;
        status) set -- sdd-status "$@" ;;
        continue) set -- sdd-continue "$@" ;;
        attempt) set -- sdd-attempt "$@" ;;
        verify) set -- sdd-verify-validate "$@" ;;
        compose) set -- sdd-archive-compose "$@" ;;
        closure) closure "$@" ;;
        archive) archive_change "$@" ;;
        migrate) migrate "$@" ;;
        *)
          echo "aytordev-sdd: unknown command '$command'" >&2
          usage >&2
          exit 64
          ;;
      esac

      exec gentle-ai "$@"
    '';
  };
in {
  options.aytordev.programs.terminal.tools.gentle-ai = {
    enable = mkEnableOption "the pinned gentle-ai SDD engine behind the aytordev adapter";

    package = lib.mkPackageOption pkgs "gentle-ai" {
      default = [
        "aytordev"
        "gentle-ai"
      ];
    };

    engramPackage = lib.mkPackageOption pkgs "engram" {
      default = [
        "aytordev"
        "engram"
      ];
      extraDescription = "Package providing the `engram` CLI the engine spawns for `engram export`.";
    };

    engramDataDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/engram";
      description = ''
        Engram data directory exported to the engine so its spawned
        `engram export` reads the same database as the Engram MCP server.
        Defaults to the MCP server's directory (T28).
      '';
    };

    engramProject = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Project name pinned for the engine (`ENGRAM_PROJECT`). Null lets the
        engine infer the git-remote basename or workspace directory basename.
        Set this when the SDD writer stamps a project name that differs from
        the inferred one (T28 project-name agreement).
      '';
    };

    adapter = mkOption {
      type = types.package;
      readOnly = true;
      description = "The `aytordev-sdd` wrapper: the single call surface clients and skills use.";
    };
  };

  config = mkIf cfg.enable {
    aytordev.programs.terminal.tools.gentle-ai.adapter = adapter;

    home.packages = [
      cfg.package
      adapter
    ];
  };
}
