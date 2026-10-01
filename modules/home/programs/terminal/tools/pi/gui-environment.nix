# Contained Darwin GUI adapter for the Pi capability. It publishes exactly one
# supported override (Gentle Pi's subagent command, `GENTLE_PI_AGENTS_PI`) into
# the user's GUI login launchd context, and never touches PATH or any other
# variable. See README.md in this directory for effects and limitations.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;

  cfg = config.aytordev.programs.terminal.tools.pi;
  gui = cfg.guiEnvironment;

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # Absolute command derived from the configured package; never a hardcoded
  # user or profile path.
  piCommand = lib.getExe' cfg.package "pi";

  # Private state: only the successfully published value is tracked, with
  # 0700 directory and 0600 file permissions.
  stateDir = "${config.xdg.stateHome}/aytordev/pi-gui-environment";
  managedStateFile = "${stateDir}/managed-command";

  # Shared by the one-shot RunAtLoad agent and the Home Manager
  # reconciliation entry; the lock serializes them (see below).
  publisher = pkgs.writeShellScript "pi-gui-environment-publisher" ''
    set -euo pipefail

    var="GENTLE_PI_AGENTS_PI"
    desired=${lib.escapeShellArg piCommand}
    stateDir=${lib.escapeShellArg stateDir}
    stateFile=${lib.escapeShellArg managedStateFile}
    launchctl=/bin/launchctl
    lockDir="$stateDir/lock"

    # Gentle Pi's override parser splits the value on whitespace into a
    # command plus arguments, so an executable path containing whitespace
    # would be silently misparsed. Reject it instead of publishing a broken
    # command.
    case "$desired" in
      *[[:space:]]*)
        echo "pi-gui-environment: refusing to publish whitespace command '$desired' (the GENTLE_PI_AGENTS_PI parser is whitespace-sensitive)" >&2
        exit 2
        ;;
    esac

    # The private state directory also holds the lock, so it is created up
    # front; a failure here must be loud rather than a silent skip that would
    # stall every future publication on a fresh machine.
    if ! mkdir -p "$stateDir" || ! chmod 700 "$stateDir"; then
      echo "pi-gui-environment: cannot create private state directory '$stateDir'; nothing changed" >&2
      exit 6
    fi

    # Conservative, bounded lock with a PID ownership token. No stealing
    # based on age or metadata: an abandoned lock (crash between creation and
    # release) must be removed by an operator who can verify no publisher is
    # running, so a contender never deletes a live or initializing lock.
    # Release touches only our own token and never recursively deletes
    # unknown or foreign lock contents.
    lockWaitAttempts=10
    release_lock() {
      if [ "$(cat "$lockDir/token" 2>/dev/null)" = "$$" ]; then
        rm -f "$lockDir/token" 2>/dev/null || true
        rmdir "$lockDir" 2>/dev/null || true
      fi
    }
    acquire_lock() {
      attempts="$lockWaitAttempts"
      while [ "$attempts" -gt 0 ]; do
        if mkdir "$lockDir" 2>/dev/null; then
          if printf '%s\n' "$$" > "$lockDir/token"; then
            return 0
          fi
          echo "pi-gui-environment: could not write the lock ownership token" >&2
          rm -f "$lockDir/token" 2>/dev/null || true
          rmdir "$lockDir" 2>/dev/null || true
          return 1
        fi
        attempts=$((attempts - 1))
        if [ "$attempts" -gt 0 ]; then
          sleep 0.5
        fi
      done
      return 1
    }

    if ! acquire_lock; then
      echo "pi-gui-environment: could not acquire the publication lock '$lockDir' after a bounded wait; if no publisher is running, remove the abandoned lock manually" >&2
      exit 7
    fi
    trap release_lock EXIT

    if ! live="$("$launchctl" getenv "$var")"; then
      echo "pi-gui-environment: could not read live $var; nothing changed" >&2
      exit 3
    fi

    managed=""
    if [ -f "$stateFile" ]; then
      managed="$(cat "$stateFile")"
    fi

    # Private, atomically staged state record. The lock serializes
    # publishers, so a fixed staging name is safe; the previous record
    # survives every failure because the staged file is renamed into place
    # only after it was fully written. Runs under a caller condition context
    # (errexit suspended): every step checks and returns failure explicitly.
    record_state() {
      umask 077
      if ! mkdir -p "$stateDir"; then
        echo "pi-gui-environment: could not create '$stateDir'" >&2
        return 1
      fi
      if ! chmod 700 "$stateDir"; then
        echo "pi-gui-environment: could not restrict '$stateDir' to 0700" >&2
        return 1
      fi
      # Refuse to record over a directory: both GNU and BSD mv would move the
      # staging file inside it and report success.
      if [ -d "$stateFile" ]; then
        echo "pi-gui-environment: '$stateFile' is a directory; refusing to record state" >&2
        return 1
      fi
      stage="$stateDir/.managed-command.tmp"
      if ! printf '%s\n' "$desired" > "$stage"; then
        echo "pi-gui-environment: could not stage the state record" >&2
        return 1
      fi
      if ! chmod 600 "$stage"; then
        echo "pi-gui-environment: could not restrict the staged record to 0600" >&2
        rm -f "$stage" 2>/dev/null || true
        return 1
      fi
      if ! mv -f "$stage" "$stateFile"; then
        echo "pi-gui-environment: could not move the staged record into place" >&2
        rm -f "$stage" 2>/dev/null || true
        return 1
      fi
    }

    # Conditional compensation for the two-resource (env + state) window:
    # unset the just-published value only if it is still live, so an attempted
    # publication is never silently treated as proven ownership.
    compensate_publication() {
      restore="$1"
      if ! current="$("$launchctl" getenv "$var")"; then
        echo "pi-gui-environment: UNCONFIRMED compensation: could not re-read live $var" >&2
        return 1
      fi
      if [ "$current" != "$desired" ]; then
        echo "pi-gui-environment: live $var changed during the failure; left untouched" >&2
        return 0
      fi
      if [ -z "$restore" ]; then
        if "$launchctl" unsetenv "$var"; then
          return 0
        fi
        echo "pi-gui-environment: UNCONFIRMED compensation: unsetenv failed" >&2
        return 1
      fi
      if "$launchctl" setenv "$var" "$restore"; then
        return 0
      fi
      echo "pi-gui-environment: UNCONFIRMED compensation: could not restore the previous live value" >&2
      return 1
    }

    fail_after_publication() {
      restore="$1"
      echo "pi-gui-environment: state record failed after publishing; compensating" >&2
      if compensate_publication "$restore"; then
        echo "pi-gui-environment: publication compensated; retrying at next run" >&2
      else
        echo "pi-gui-environment: compensation incomplete; inspect live $var and '$stateFile' manually" >&2
      fi
      exit 5
    }

    # Exact match: already correct. A matching live value with missing or
    # different managed state is not evidence that we own it (it may be a
    # same-valued foreign publication), so ownership is never manufactured.
    if [ "$live" = "$desired" ]; then
      exit 0
    fi

    # Our own stale publication (e.g. after a package update): reconcile it.
    if [ -n "$managed" ] && [ "$live" = "$managed" ]; then
      if ! "$launchctl" setenv "$var" "$desired"; then
        echo "pi-gui-environment: failed to update $var; retrying at next run" >&2
        exit 4
      fi
      if ! record_state; then
        # Compensate back to the previous live value, not merely unset.
        fail_after_publication "$managed"
      fi
      exit 0
    fi

    # No live override: publish for the first time.
    if [ -z "$live" ]; then
      if ! "$launchctl" setenv "$var" "$desired"; then
        echo "pi-gui-environment: failed to publish $var; retrying at next run" >&2
        exit 4
      fi
      if ! record_state; then
        # Restore the environment to unset.
        fail_after_publication ""
      fi
      exit 0
    fi

    # Foreign override: never clobber or unset it, including after package
    # changes. The exact comparison is not atomic against concurrent writers.
    echo "pi-gui-environment: preserving foreign $var override" >&2
    exit 0
  '';

  # Reachable whenever the adapter is not publishing (Pi off, opt-in off,
  # launchd off), after Home Manager has loaded/unloaded its agents. It unsets
  # only the exact managed value and only removes tracking when the managed
  # value is no longer live. Isolated in a subshell so its exit codes and
  # shell options can neither abort nor leak into the surrounding activation.
  cleanupActivation = lib.hm.dag.entryAfter ["setupLaunchAgents"] ''
    (
      set -u
      DRY_RUN_CMD="''${DRY_RUN_CMD:-}"

      var="GENTLE_PI_AGENTS_PI"
      stateFile=${lib.escapeShellArg managedStateFile}
      launchctl=/bin/launchctl

      # Nothing was ever managed successfully; do not create state.
      if [ ! -f "$stateFile" ]; then
        exit 0
      fi
      managed="$(cat "$stateFile")"
      if ! live="$("$launchctl" getenv "$var")"; then
        echo "cleanupPiGuiEnvironment: could not read live $var; keeping state for retry" >&2
        exit 1
      fi
      if [ "$live" != "$managed" ]; then
        # The managed value is no longer live (lost login env or a foreign
        # override): drop tracking only, never unset a foreign value.
        $DRY_RUN_CMD rm -f "$stateFile"
        exit 0
      fi
      if $DRY_RUN_CMD "$launchctl" unsetenv "$var"; then
        $DRY_RUN_CMD rm -f "$stateFile"
        exit 0
      fi
      echo "cleanupPiGuiEnvironment: launchctl unsetenv failed; keeping state for retry" >&2
      exit 1
    )
  '';

  # Repair path for every activation while the adapter is publishing: the
  # one-shot RunAtLoad agent is not rerun by an unchanged activation, so a
  # lost login environment or a failed agent run is repaired here. Dry-run
  # stays inert; the publisher serializes against the asynchronous agent with
  # a bounded lock. Isolated like the cleanup fragment.
  reconcileActivation = lib.hm.dag.entryAfter ["setupLaunchAgents"] ''
    (
      DRY_RUN_CMD="''${DRY_RUN_CMD:-}"
      $DRY_RUN_CMD ${publisher}
    )
  '';

  publication = cfg.enable && gui.enable && isDarwin && config.launchd.enable;
in {
  config = mkMerge [
    (mkIf publication {
      launchd.agents.pi-gui-environment = {
        enable = true;
        config = {
          # One-shot: runs once when the agent is loaded and at each login.
          ProgramArguments = ["${publisher}"];
          RunAtLoad = true;
          KeepAlive = false;
          StandardOutPath = "${config.xdg.cacheHome}/pi-gui-environment-publisher.log";
          StandardErrorPath = "${config.xdg.cacheHome}/pi-gui-environment-publisher.log";
        };
      };

      home.activation.reconcilePiGuiEnvironment = reconcileActivation;
    })
    (mkIf (isDarwin && !publication) {
      home.activation.cleanupPiGuiEnvironment = cleanupActivation;
    })
  ];
}
