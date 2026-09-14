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
  # Only the workflow read/validate surface used by the SDD phases is exposed.
  # The engine's validators and archive composer are reused as-is (T20/T21).
  adapter = pkgs.writeShellApplication {
    name = "aytordev-sdd";
    runtimeInputs = [cfg.package cfg.engramPackage];
    text = ''
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

      if [ "$#" -eq 0 ]; then
        echo "usage: aytordev-sdd <status|continue|attempt|verify> [args...]" >&2
        exit 64
      fi

      command="$1"
      shift
      case "$command" in
        status) set -- sdd-status "$@" ;;
        continue) set -- sdd-continue "$@" ;;
        attempt) set -- sdd-attempt "$@" ;;
        verify) set -- sdd-verify-validate "$@" ;;
        *)
          echo "aytordev-sdd: unknown command '$command' (want status|continue|attempt|verify)" >&2
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
