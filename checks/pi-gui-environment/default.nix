# Focused tests for the Pi GUI command environment adapter
# (odd/tasks/pi-gui-environment.md).
#
# Strict TDD: GUI-1 observed the intended RED — evaluation failed with
# "The option `aytordev.programs.terminal.tools.pi.guiEnvironment' does not
# exist" before the adapter was implemented. The audit regressions below
# (ownership, private atomic state, rollback, lock serialization, isolated
# activation fragments, reconcile repair entry) were each observed RED before
# their fix went GREEN. Tests stub launchctl and run HM activation fragments
# inline under `set -eu` with a sentinel, never a real launchctl or
# activation; builds write to the Nix sandbox/store only.
{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # Fixture identity only: never a real host or user.
  fixtureIdentity = {
    username = "pi-gui-ci";
    email = "pi-gui-ci@example.test";
    fullName = "Pi GUI CI";
  };

  # Synthetic pi package so the published command is fixture-derived and its
  # absolute executable path is observable without building real Pi.
  piFixture = pkgs.writeShellScriptBin "pi" ''
    # Fixture identity only: never a real Pi executable.
    exit 0
  '';
  piExe = lib.getExe' piFixture "pi";

  # The supported Gentle Pi command override (baseline evidence in the feature
  # document). The adapter must publish this, never a PATH change.
  overrideVar = "GENTLE_PI_AGENTS_PI";

  baseHomeModules = homeSystem: [
    {
      aytordev.user = {
        enable = true;
        name = fixtureIdentity.username;
        inherit (fixtureIdentity) email fullName;
        home =
          if lib.hasSuffix "-darwin" homeSystem
          then "/Users/${fixtureIdentity.username}"
          else "/home/${fixtureIdentity.username}";
      };
      home.stateVersion = "25.11";
    }
  ];

  # Synthetic Home Manager composition. `guiEnable == null` leaves the
  # guiEnvironment option at its default without referencing it. Modules are
  # separate entries: `//` is a shallow merge and would drop sibling paths.
  mkScenario = {
    homeSystem ? pkgs.stdenv.hostPlatform.system,
    piEnable,
    guiEnable ? null,
    launchdEnable ? null,
  }:
    (
      inputs.self.lib.system.mkHome {
        system = homeSystem;
        inherit (fixtureIdentity) username;
        hostname = fixtureIdentity.username;
        modules =
          baseHomeModules homeSystem
          ++ [
            {
              aytordev.programs.terminal.tools.pi = {
                enable = piEnable;
                package = piFixture;
              };
            }
          ]
          ++ lib.optionals (guiEnable != null) [
            {
              aytordev.programs.terminal.tools.pi.guiEnvironment.enable = guiEnable;
            }
          ]
          ++ lib.optionals (launchdEnable != null) [
            {launchd.enable = launchdEnable;}
          ];
      }
    )
    .config;

  # Required default-off matrix: each of these must publish no agent. These
  # scenarios exercise Darwin semantics and are evaluated on Darwin only.
  defaultOff = mkScenario {piEnable = true;};
  piOff = mkScenario {
    piEnable = false;
    guiEnable = true;
  };
  launchdOff = mkScenario {
    piEnable = true;
    guiEnable = true;
    launchdEnable = false;
  };

  # Meaningful Linux guards: the option evaluates, but nothing Darwin-only
  # leaks out (no agent, no cleanup, no reconcile; HM launchd stays off).
  linuxGuiOn = mkScenario {
    homeSystem = "x86_64-linux";
    piEnable = true;
    guiEnable = true;
  };
  linuxDefaultOff = mkScenario {
    homeSystem = "x86_64-linux";
    piEnable = true;
  };

  # Enabled scenario: Pi on, opt-in, Darwin, HM launchd on, custom package.
  enabled = mkScenario {
    piEnable = true;
    guiEnable = true;
    launchdEnable = true;
  };

  linuxGuardAsserts = assert linuxGuiOn.aytordev.programs.terminal.tools.pi.guiEnvironment.enable == true;
  assert linuxDefaultOff.aytordev.programs.terminal.tools.pi.guiEnvironment.enable == false;
  assert linuxGuiOn.launchd.enable == false;
  assert !(linuxGuiOn.launchd.agents ? pi-gui-environment);
  assert !(linuxDefaultOff.launchd.agents ? pi-gui-environment);
  assert !(linuxGuiOn.home.activation ? cleanupPiGuiEnvironment);
  assert !(linuxGuiOn.home.activation ? reconcilePiGuiEnvironment);
  assert !(linuxDefaultOff.home.activation ? cleanupPiGuiEnvironment);
  assert !(linuxDefaultOff.home.activation ? reconcilePiGuiEnvironment); true;
in
  if pkgs.stdenv.hostPlatform.isDarwin
  then let
    enabledAgents = lib.filterAttrs (_: agent: agent.enable) enabled.launchd.agents;
    publisher = lib.head (lib.attrValues enabledAgents);
    publisherConfig = publisher.config;
    # Original command chain as configured (HM's wait4path wrapper only
    # affects the generated plist, not these module values).
    publisherArgs =
      (lib.optionals (publisherConfig.Program or null != null) [publisherConfig.Program])
      ++ (lib.optionals (publisherConfig.ProgramArguments or null != null) publisherConfig.ProgramArguments);
    publisherScript = lib.head publisherArgs;
    keepAlive = publisherConfig.KeepAlive or null;
    cleanupActivation = piOff.home.activation.cleanupPiGuiEnvironment;
    reconcileActivation = enabled.home.activation.reconcilePiGuiEnvironment;
    cleanupFragment = pkgs.writeText "pi-gui-cleanup-fragment" cleanupActivation.data;
    reconcileFragment = pkgs.writeText "pi-gui-reconcile-fragment" reconcileActivation.data;
  in
    assert linuxGuardAsserts;
    assert lib.length (lib.attrNames enabledAgents) == 1;
    # One-shot GUI-domain agent: runs once when loaded and at login.
    assert publisherConfig.RunAtLoad or false;
    assert keepAlive == null || keepAlive == false;
    assert publisher.domain == "gui";
    assert lib.length publisherArgs > 0;
    # Named-agent guards for the negative matrix: the agent is absent, not
    # merely unscanned.
    assert !(defaultOff.launchd.agents ? pi-gui-environment);
    assert !(piOff.launchd.agents ? pi-gui-environment);
    assert !(launchdOff.launchd.agents ? pi-gui-environment);
    # Activation entries: cleanup stays reachable whenever the adapter is
    # not publishing; reconcile exists only while publishing; both are
    # ordered after Home Manager's own agent handling.
    assert lib.elem "setupLaunchAgents" cleanupActivation.after;
    assert lib.elem "setupLaunchAgents" reconcileActivation.after;
    assert !(enabled.home.activation ? cleanupPiGuiEnvironment);
    assert enabled.home.activation ? reconcilePiGuiEnvironment;
    assert defaultOff.home.activation ? cleanupPiGuiEnvironment;
    assert launchdOff.home.activation ? cleanupPiGuiEnvironment;
    assert !(defaultOff.home.activation ? reconcilePiGuiEnvironment);
    assert !(launchdOff.home.activation ? reconcilePiGuiEnvironment);
    assert !(piOff.home.activation ? reconcilePiGuiEnvironment);
      pkgs.runCommand "pi-gui-environment" {
        nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.diffutils pkgs.gnused];
      } ''
              set -euo pipefail
              mkdir -p "$out"

              # --- Configuration contract -------------------------------------
              # The enabled scenario's agent must reference the absolute executable
              # of the configured custom package: directly as an argument, inside a
              # publisher script, or inside a wrapped command string.
              found=""
              for arg in ${lib.escapeShellArgs publisherArgs}; do
                if [ "$arg" = ${lib.escapeShellArg piExe} ]; then
                  found="$arg"
                elif [ -f "$arg" ] && grep -qF ${lib.escapeShellArg piExe} "$arg"; then
                  found="$arg"
                elif printf '%s' "$arg" | grep -qF ${lib.escapeShellArg piExe}; then
                  found="$arg"
                fi
              done
              if [ -z "$found" ]; then
                echo "publisher does not reference the absolute fixture command ${piExe}" >&2
                exit 1
              fi
              # The publisher must not publish a PATH override; it publishes only
              # ${overrideVar}.
              if grep -qE 'launchctl setenv PATH( |$)' "$found"; then
                echo "publisher must not publish a PATH override" >&2
                exit 1
              fi
              if ! grep -qF "${overrideVar}" "$found"; then
                echo "publisher does not publish ${overrideVar}" >&2
                exit 1
              fi
              printf 'PASS publisher references absolute fixture command via %s\n' "$found"

              # --- Stubbed lifecycle (no real launchctl, no HM activation) ----
              sbx="$TMPDIR/lifecycle"
              home="$sbx/home"
              stateDir="$home/.local/state/aytordev/pi-gui-environment"
              stateFile="$stateDir/managed-command"
              guiStore="$sbx/gui-env-store"
              stub="$sbx/bin/launchctl"
              mkdir -p "$home" "$sbx/bin"

              # Test-local rewrites of the baked fixture paths and launchctl hook.
              sed -e 's|/Users/pi-gui-ci|'"$home"'|g' \
                  -e 's|/bin/launchctl|'"$stub"'|g' \
                ${publisherScript} > "$sbx/publisher"
              sed -e 's|/Users/pi-gui-ci|'"$home"'|g' \
                  -e 's|/bin/launchctl|'"$stub"'|g' \
                ${cleanupFragment} > "$sbx/cleanup"
              sed -e 's|/Users/pi-gui-ci|'"$home"'|g' \
                  -e "s|${publisherScript}|$sbx/publisher|g" \
                ${reconcileFragment} > "$sbx/reconcile"
              chmod +x "$sbx/publisher"

              # launchctl stub backed by a file; failure flags inject launchctl errors.
              cat > "$stub" <<'STUB'
        #!/bin/bash
        set -eu
        store="$STUB_STORE"
        cmd="$1"
        shift
        case "$cmd" in
          getenv)
            if [ -f "$store.getenvfail" ]; then
              echo "stub: getenv failure" >&2
              exit 1
            fi
            if [ -f "$store" ]; then
              cat "$store"
            fi
            ;;
          setenv)
            if [ -f "$store.fail" ]; then
              echo "stub: setenv failure" >&2
              exit 1
            fi
            printf '%s\n' "$2" > "$store"
            ;;
          unsetenv)
            if [ -f "$store.fail" ]; then
              echo "stub: unsetenv failure" >&2
              exit 1
            fi
            rm -f "$store"
            ;;
          *)
            echo "stub: unsupported launchctl call: $cmd $*" >&2
            exit 64
            ;;
        esac
        STUB
              chmod +x "$stub"
              export STUB_STORE="$guiStore"

              # Emulates Home Manager's inline execution: the fragment runs under
              # `set -eu` followed by a sentinel, so a stray exit or leaked shell
              # option surfaces as a missing sentinel, and a fragment failure aborts
              # before the sentinel exactly like a failing activation would.
              run_inline() {
                fragment="$1"
                dry="''${2:-}"
                wrapper="$fragment-wrapper"
                {
                  printf 'set -eu\n'
                  cat "$fragment"
                  printf '\necho SENTINEL_REACHED\n'
                } > "$wrapper"
                if DRY_RUN_CMD="$dry" bash "$wrapper" > "$fragment-out" 2> "$fragment-err"; then
                  grep -q '^SENTINEL_REACHED$' "$fragment-out"
                else
                  if grep -q '^SENTINEL_REACHED$' "$fragment-out"; then
                    echo "fragment failed but sentinel was reached: $fragment" >&2
                    exit 1
                  fi
                  return 1
                fi
              }

              clean_state() {
                rm -rf "$stateDir"
                rm -f "$guiStore" "$guiStore.fail" "$guiStore.getenvfail"
              }

              piExe=${lib.escapeShellArg piExe}

              # Fresh publish: empty GUI env, no managed state; private state.
              clean_state
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              test "$(stat -c %a "$stateDir")" = 700
              test "$(stat -c %a "$stateFile")" = 600
              printf 'PASS fresh publish with private 0700/0600 state\n'

              # Idempotent re-run (next login).
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS idempotent re-publish\n'

              # Same-valued foreign publication: a matching live value with no
              # managed state is NOT evidence of ownership, so it is never adopted;
              # a later disable must leave the foreign value untouched.
              clean_state
              printf '%s\n' "$piExe" > "$guiStore"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test ! -e "$stateFile"
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup no-state branch failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test ! -e "$stateFile"
              printf 'PASS same-valued foreign publication not adopted; disable preserves it\n'

              # A matching live value with a different managed state is likewise not
              # adopted.
              printf '/nix/store/0000-old-pi\n' > "$stateFile"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = /nix/store/0000-old-pi
              printf 'PASS matching live value with foreign managed state untouched\n'

              # Foreign override without managed state: preserved, no state created.
              clean_state
              printf '/usr/local/bin/foreign-pi\n' > "$guiStore"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = /usr/local/bin/foreign-pi
              test ! -e "$stateFile"
              printf 'PASS foreign override preserved\n'

              # A foreign value that merely looks like a Nix store path is preserved
              # too (the managed state decides ownership, not a path heuristic).
              printf '/nix/store/0000-old-pi\n' > "$stateFile"
              printf '/nix/store/ffff-foreign-pi\n' > "$guiStore"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = /nix/store/ffff-foreign-pi
              test "$(cat "$stateFile")" = /nix/store/0000-old-pi
              printf 'PASS foreign Nix-looking override preserved\n'

              # Package change: our own stale publication is reconciled.
              clean_state
              "$sbx/publisher"
              sed 's|^desired=.*|desired=/nix/store/0000-old-pi|' "$sbx/publisher" \
                > "$sbx/publisher-old"
              chmod +x "$sbx/publisher-old"
              "$sbx/publisher-old"
              test "$(cat "$guiStore")" = /nix/store/0000-old-pi
              test "$(cat "$stateFile")" = /nix/store/0000-old-pi
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS managed update after package change\n'

              # Failed setenv: non-zero exit, retry state preserved, then success.
              clean_state
              touch "$guiStore.fail"
              if "$sbx/publisher"; then
                echo 'unexpected publisher success during injected setenv failure' >&2
                exit 1
              fi
              test ! -e "$stateFile"
              test ! -e "$guiStore"
              rm "$guiStore.fail"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS setenv failure retry\n'

              # Lost login environment while managed: re-publishes.
              rm -f "$guiStore"
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS re-publish after lost login env\n'

              # Whitespace command: rejected loudly, nothing published or recorded.
              clean_state
              printf '/usr/local/bin/kept-pi\n' > "$guiStore"
              sed "s|^desired=.*|desired='/path with space/pi'|" "$sbx/publisher" \
                > "$sbx/publisher-ws"
              if bash "$sbx/publisher-ws"; then
                echo 'whitespace command unexpectedly published' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = /usr/local/bin/kept-pi
              test ! -e "$stateDir" && test ! -e "$stateFile"
              printf 'PASS whitespace command rejected\n'

              # State-directory failure: publication never half-applies; the run
              # fails loudly and the disable path stays inert (directory failure
              # injection).
              clean_state
              mkdir -p "$home/.local/state/aytordev"
              chmod 555 "$home/.local/state/aytordev"
              if "$sbx/publisher"; then
                echo 'unexpected publisher success during injected state-dir failure' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              chmod 755 "$home/.local/state/aytordev"
              printf 'PASS state-dir failure fails loudly without publishing\n'


              # True staged-write failure: the lock serializes publishers, so
              # the fixed staging path can be pre-occupied by a directory in
              # the sandbox. The updater must compensate back to the previous
              # live value (not merely unset), preserve the previous record,
              # and fail loudly; the retry converges once it is removed.
              clean_state
              "$sbx/publisher"
              mkdir "$stateDir/.managed-command.tmp"
              if "$sbx/publisher-old"; then
                echo 'unexpected success during injected staging failure' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              rmdir "$stateDir/.managed-command.tmp"
              "$sbx/publisher-old"
              test "$(cat "$guiStore")" = /nix/store/0000-old-pi
              test "$(cat "$stateFile")" = /nix/store/0000-old-pi
              printf 'PASS staged-write failure compensates to previous live value\n'

              # Rename-target refusal (directory at the managed record path):
              # both GNU and BSD mv would move the staging file inside it and
              # report success, so recording refuses explicitly. Compensation
              # restores the environment to unset, nothing is committed, and
              # a later disable stays inert on the foreign directory.
              clean_state
              mkdir -p "$stateDir"
              mkdir "$stateFile"
              printf 'sentinel\n' > "$stateFile/keep"
              if "$sbx/publisher"; then
                echo 'unexpected success during injected state-record failure' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              test -d "$stateFile"
              test "$(cat "$stateFile/keep")" = sentinel
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup with unusable state failed' >&2
                exit 1
              fi
              test -d "$stateFile"
              test "$(cat "$stateFile/keep")" = sentinel
              printf 'PASS fresh publication compensation restores unset; disable inert\n'

              # Conservative lock: a live foreign owner is never stolen from.
              # The run waits its bounded budget, then fails loudly naming the
              # lock; lock contents and live state are untouched.
              clean_state
              mkdir -p "$stateDir/lock"
              printf '999999\n' > "$stateDir/lock/token"
              lockStart="$(date +%s)"
              if "$sbx/publisher"; then
                echo 'unexpected success while the lock is held by another owner' >&2
                exit 1
              fi
              lockEnd="$(date +%s)"
              test $((lockEnd - lockStart)) -ge 4
              test "$(cat "$stateDir/lock/token")" = 999999
              test ! -e "$guiStore"
              test ! -e "$stateFile"
              printf 'PASS held lock fails loudly after bounded wait without stealing\n'

              # An abandoned initializer lock (no ownership token) is unknown
              # content: never stolen, never deleted; recovery is operator
              # action, not automatic.
              rm -rf "$stateDir/lock"
              mkdir "$stateDir/lock"
              if "$sbx/publisher"; then
                echo 'unexpected success with an abandoned initializer lock' >&2
                exit 1
              fi
              test -d "$stateDir/lock"
              test ! -e "$stateDir/lock/token"
              test ! -e "$guiStore"
              printf 'PASS abandoned initializer lock preserved and reported\n'

              # Controlled concurrent initialization: the lock serializes the
              # runs; both exit validly (success or lock timeout), the live
              # state ends consistent, and the owner released the lock.
              clean_state
              "$sbx/publisher" > "$sbx/pub-a.log" 2>&1 & pidA=$!
              "$sbx/publisher" > "$sbx/pub-b.log" 2>&1 & pidB=$!
              statusA=0
              wait "$pidA" || statusA=$?
              statusB=0
              wait "$pidB" || statusB=$?
              if [ "$statusA" -ne 0 ] && [ "$statusB" -ne 0 ]; then
                echo 'both concurrent publishers failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              test ! -d "$stateDir/lock"
              printf 'PASS concurrent initialization serialized with consistent state\n'

              # Cleanup fragment, inline with sentinel: all successful branches reach
              # the sentinel; failures abort before it; dry-run stays inert.
              printf '%s\n' "$piExe" > "$stateFile"
              printf '%s\n' "$piExe" > "$guiStore"
              if run_inline "$sbx/cleanup" echo; then :; else
                echo 'cleanup dry-run branch failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test -f "$stateFile"
              printf 'PASS cleanup dry-run is inert and reaches sentinel\n'
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup exact-match branch failed' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              test ! -e "$stateFile"
              printf 'PASS cleanup exact-match unset reaches sentinel\n'

              # Cleanup with a foreign live value: foreign preserved, tracking
              # dropped, sentinel reached.
              printf '/nix/store/0000-old-pi\n' > "$stateFile"
              printf '/usr/local/bin/foreign-pi\n' > "$guiStore"
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup foreign branch failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = /usr/local/bin/foreign-pi
              test ! -e "$stateFile"
              printf 'PASS cleanup preserves foreign override and reaches sentinel\n'

              # Repeated disable and nothing-managed: no-op, no state created.
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup repeated-disable branch failed' >&2
                exit 1
              fi
              test ! -e "$stateFile"
              printf '/usr/local/bin/foreign-pi\n' > "$guiStore"
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup nothing-managed branch failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = /usr/local/bin/foreign-pi
              test ! -e "$stateFile"
              printf 'PASS repeated disable is inert and creates no state\n'

              # Failed cleanup commands abort before the sentinel and keep the retry
              # state, then a healthy retry succeeds.
              printf '%s\n' "$piExe" > "$stateFile"
              printf '%s\n' "$piExe" > "$guiStore"
              touch "$guiStore.fail"
              if run_inline "$sbx/cleanup"; then
                echo 'unexpected cleanup success during injected unsetenv failure' >&2
                exit 1
              fi
              test -f "$stateFile"
              test "$(cat "$guiStore")" = "$piExe"
              rm "$guiStore.fail"
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup retry after unsetenv failure failed' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              test ! -e "$stateFile"
              printf 'PASS cleanup failure aborts activation and retries\n'

              printf '%s\n' "$piExe" > "$stateFile"
              touch "$guiStore.getenvfail"
              if run_inline "$sbx/cleanup"; then
                echo 'unexpected cleanup success during injected getenv failure' >&2
                exit 1
              fi
              test -f "$stateFile"
              rm "$guiStore.getenvfail"
              if run_inline "$sbx/cleanup"; then :; else
                echo 'cleanup retry after getenv failure failed' >&2
                exit 1
              fi
              test ! -e "$stateFile"
              printf 'PASS cleanup getenv failure aborts activation and retries\n'

              # Reconcile activation fragment (inline with sentinel): repairs a lost
              # login environment and a full loss, is inert under dry-run, fails the
              # activation when the publisher fails, and honors the lock.
              clean_state
              "$sbx/publisher"
              rm -f "$guiStore"
              if run_inline "$sbx/reconcile"; then :; else
                echo 'reconcile repair after lost env failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS reconcile repairs lost login environment\n'

              clean_state
              if run_inline "$sbx/reconcile"; then :; else
                echo 'reconcile repair after full loss failed' >&2
                exit 1
              fi
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS reconcile repairs full environment loss\n'

              # Reconcile dry-run begins from an empty environment and no
              # state: any mutation here means the publisher executed.
              clean_state
              if run_inline "$sbx/reconcile" echo; then :; else
                echo 'reconcile dry-run branch failed' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              test ! -e "$stateFile"
              printf 'PASS reconcile dry-run is inert from an empty environment\n'

              clean_state
              touch "$guiStore.fail"
              if run_inline "$sbx/reconcile"; then
                echo 'unexpected reconcile success during injected publisher failure' >&2
                exit 1
              fi
              test ! -e "$stateFile"
              test ! -e "$guiStore"
              rm "$guiStore.fail"
              printf 'PASS reconcile publisher failure aborts activation\n'

              # Reconcile while the lock is held: the bounded wait ends in a
              # loud failure (failing the activation) without mutation, and
              # the foreign lock is preserved.
              clean_state
              "$sbx/publisher"
              rm -f "$guiStore"
              rm -rf "$stateDir/lock"
              mkdir "$stateDir/lock"
              printf '424242\n' > "$stateDir/lock/token"
              if run_inline "$sbx/reconcile"; then
                echo 'unexpected reconcile success while the lock is held' >&2
                exit 1
              fi
              test ! -e "$guiStore"
              test "$(cat "$stateDir/lock/token")" = 424242
              printf 'PASS reconcile lock contention fails the activation without mutation\n'

              # Re-enable after disable/lost login env: publishes again.
              clean_state
              "$sbx/publisher"
              test "$(cat "$guiStore")" = "$piExe"
              test "$(cat "$stateFile")" = "$piExe"
              printf 'PASS re-enable after lost login env\n'

              printf 'PASS pi-gui-environment configuration and lifecycle contract\n'
              touch "$out/passed"
      ''
  # The Darwin evaluation also cross-evaluates the Linux guards above; the
  # Linux evaluation asserts them directly and builds no Darwin lifecycle.
  else
    assert linuxGuardAsserts;
      pkgs.runCommand "pi-gui-environment-linux-guard" {} ''
        mkdir -p "$out"
        printf 'PASS pi-gui-environment linux guards (darwin-only lifecycle skipped)\n'
        touch "$out/passed"
      ''
