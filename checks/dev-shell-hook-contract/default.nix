# Public contract for the auto-discovered dev shells.
#
# Motivating bug 1: entering any wrapped dev shell installed this repository's
# pre-commit Git hooks in the consumer checkout, so reusable language shells
# had to opt out one by one. The policy is now central in
# `flake/dev/dev-shells/default.nix`: there is ONE wrapper, and only the shell
# named `nix` installs Git hooks. This obsoleted the `node-26-minimal` shell,
# whose only utility was hook avoidance.
#
# Motivating bug 2: `just install-hooks` routed to `.#default`, which never
# installs hooks, so the recipe silently did nothing. It must route to the
# hook-installing `.#nix` shell.
#
# Motivating bug 3: the upstream git-hooks-nix installation script overwrites
# or disables what a consumer checkout already has (it rewrites a custom
# `core.hooksPath` and replaces managed hooks such as an existing `pre-push`),
# so the `nix` shell installs through a fail-safe guard: the installer runs
# only on a clean checkout and skips — without touching anything — when a user
# hook or custom hook routing already exists.
#
# This check imports the real wrapper module and evaluates the real per-shell
# hooks from the real `dev-shells/` directory, so a per-shell regression cannot
# slip past it. Most assertions are evaluation-only; the fail-safe guard
# function is additionally exercised at build time against fixture Git
# repositories. Nothing else is built.
{
  lib,
  pkgs,
  ...
}: let
  devShellsModule = import ../../flake/dev/dev-shells/default.nix;

  # Distinctive stand-in for `config.pre-commit.installationScript` so the
  # assertions detect hook installation without depending on git-hooks-nix.
  installationScript = "dev-shell-hook-contract: installation-script marker";

  # Wrap the real pkgs so the wrapper's mkShell exposes the plain attrset
  # instead of a derivation. Common tools and shell arguments stay real, so
  # package-name assertions below are grounded in the actual inputs.
  inspectPkgs =
    pkgs
    // {
      mkShell = rv: {
        inherit (rv) name shellHook nativeBuildInputs packages;
        __wrapperShell = true;
      };
    };

  # WHY a named intermediate: the deeply nested `inherit (...) (expr)` form is
  # not idempotent under the repository's formatter, so the module result is
  # bound first and read from the plain name below.
  devShellConfig =
    (devShellsModule {
      inputs = {};
      self = {inputs = {};};
    })
    .perSystem {
      inherit lib;
      pkgs = inspectPkgs;
      config = {pre-commit = {inherit installationScript;};};
    };

  inherit (devShellConfig) devShells;
  justfile = builtins.readFile ../../Justfile;

  shellNames = lib.attrNames devShells;
  hookShellName = "nix";
  obsoleteShellName = "node-26-minimal";
  commonToolNames = ["git" "git-lfs" "gh" "jq" "htop"];
  nodeShellNames = lib.filter (lib.hasPrefix "node-") shellNames;
  guardFunctionName = "aytordev_should_install_git_hooks";
  guardMarkerOpen = "# >>> aytordev-hook-guard";

  # The real nix shell hook, written to a file so the build-time guard test can
  # extract and exercise the fail-safe function.
  nixShellHookFile = pkgs.writeText "dev-shell-hook-contract-nix-shell-hook" devShells.${hookShellName}.shellHook;

  # Null-safe view: shells are either wrapper attrsets (transparent probe) or
  # real direct derivations (e.g. python-314's pkgs.mkShellNoCC), whose
  # exposed internals differ.
  shellView = name: let
    shell = devShells.${name};
  in {
    inherit shell;
    isWrapperShell = shell ? __wrapperShell;
    hook = shell.shellHook or "";
    packages = shell.packages or [];
    nativeBuildInputs = shell.nativeBuildInputs or [];
  };

  # Hook policy: exactly one shell installs the consumer checkout's Git hooks,
  # and the obsolete hook-avoidance shell is gone from the public interface.
  hookViolations =
    lib.concatMap
    (name: let
      view = shellView name;
    in
      (lib.optionals (!(devShells ? ${hookShellName})) ["the '${hookShellName}' shell is missing"])
      ++ (lib.optionals
        (name == hookShellName && !lib.hasInfix installationScript view.hook)
        ["${hookShellName}: must install the Git hook installation script"])
      ++ (lib.optionals
        (name != hookShellName && lib.hasInfix installationScript view.hook)
        ["${name}: must not install Git hooks; only the '${hookShellName}' shell may"]))
    shellNames
    ++ (lib.optionals (lib.elem obsoleteShellName shellNames) [
      "${obsoleteShellName}: obsolete; hook policy is central and a bare Node 26 toolchain shell has no remaining use"
    ]);

  # Fail-safe guard: the hook-installing shell must wrap the installation
  # script in the guard that skips on existing user hooks or custom routing,
  # and no other shell may carry the guard at all.
  guardViolations =
    (lib.optionals (!(lib.hasInfix guardMarkerOpen devShells.${hookShellName}.shellHook)) [
      "${hookShellName}: shell hook must carry the fail-safe guard for existing hooks and custom routing"
    ])
    ++ (lib.optionals
      (!(lib.hasInfix "if ${guardFunctionName}; then" devShells.${hookShellName}.shellHook))
      ["${hookShellName}: the installation script must only run behind the '${guardFunctionName}' guard"])
    ++ (lib.concatMap
      (name:
        lib.optionals
        (name != hookShellName && lib.hasInfix guardFunctionName (shellView name).hook)
        ["${name}: must not carry the Git hook guard; it installs no hooks"])
      shellNames);

  # `just install-hooks` is the public installation entry point and must reach
  # the only shell that installs hooks.
  justfileViolations =
    (lib.optionals (!(lib.hasInfix "install-hooks:\n    nix develop .#nix" justfile)) [
      "Justfile: install-hooks must route to the '.#nix' dev shell (the only one that installs hooks)"
    ])
    ++ (lib.optionals (lib.hasInfix "nix develop .#default" justfile) [
      "Justfile: install-hooks must not route to '.#default'; that shell never installs hooks"
    ]);

  # Wrapper shells keep the shared common tools the wrapper injects.
  wrapperViolations =
    lib.concatMap
    (name: let
      view = shellView name;
      toolNames =
        lib.map (pkg: pkg.pname or pkg.name or "unknown") view.nativeBuildInputs;
    in
      lib.optionals
      view.isWrapperShell
      ((lib.optionals (lib.length toolNames < 11) [
          "${name}: wrapper shell must still receive the common tools"
        ])
        ++ (lib.concatMap
          (tool:
            lib.optionals
            (!lib.elem tool toolNames)
            ["${name}: common tool '${tool}' is missing from the wrapper shell"])
          commonToolNames)))
    shellNames;

  # Node toolchains survive the wrapper consolidation untouched.
  nodeViolations =
    lib.concatMap
    (name: let
      view = shellView name;
      packageNames =
        lib.map (pkg: pkg.pname or pkg.name or "unknown") view.packages;
    in
      (lib.optionals (!view.isWrapperShell)
        ["${name}: Node shell should be built through the shared wrapper"])
      ++ (lib.optionals
        (view.isWrapperShell
          && !(lib.any (pkgName: lib.hasInfix "nodejs" pkgName) packageNames))
        ["${name}: Node toolchain missing from the shell packages"])
      ++ (lib.optionals
        (view.isWrapperShell
          && !(lib.any (pkgName: lib.hasInfix "yarn" pkgName || lib.hasInfix "pnpm" pkgName) packageNames))
        ["${name}: Node build tools (yarn/pnpm) missing from the shell packages"]))
    nodeShellNames;

  violations = hookViolations ++ guardViolations ++ justfileViolations ++ wrapperViolations ++ nodeViolations;
in
  if violations == []
  then
    pkgs.runCommand "dev-shell-hook-contract-check"
    {
      nativeBuildInputs = [pkgs.bash pkgs.git pkgs.diffutils];
    } ''
      echo "Checked ${toString shellNames} dev shells: only '${hookShellName}' installs consumer Git hooks" > "$out"
      echo >> "$out"

      # --- Extract the fail-safe guard from the real nix shell hook ---------
      scratch="$(mktemp -d)"
      awk '/# >>> aytordev-hook-guard/,/# <<< aytordev-hook-guard/' \
        "${nixShellHookFile}" > "$scratch/guard.sh"
      test -s "$scratch/guard.sh"

      source "$scratch/guard.sh"

      # NOTE: the stdenv builder enforces `set -e`; a command substitution in an
      # assignment propagates its failure, so the expected non-zero guard exit
      # must be neutralized while keeping the original status in `rc`.
      lastGuardOutput=""
      expect_rc() {
        local expected rc
        expected="$1"
        shift
        rc=0
        lastGuardOutput="$(cd "$1" && ${guardFunctionName} 2>&1)" || rc=$?
        if [ "$rc" != "$expected" ]; then
          echo "FAIL: $2 (expected rc=$expected, got rc=$rc; output: $lastGuardOutput)" >&2
          return 1
        fi
        echo "ok: $2 (rc=$rc)"
        if [ -n "$lastGuardOutput" ]; then
          echo "      reason: $lastGuardOutput"
        fi
      }

      # 1. A clean checkout must still get the hooks installed.
      git init -q "$scratch/clean"
      echo "ok-setup: clean fixture" > "$scratch/.setup"
      expect_rc 0 "$scratch/clean" \
        "a clean checkout must allow Git hook installation"

      # 2. An existing user hook (the upstream script used to delete managed
      #    pre-push hooks) must never be overwritten or disabled.
      git init -q "$scratch/existing"
      printf '#!/bin/sh\necho sentinel-user-hook\n' > "$scratch/existing/.git/hooks/pre-push"
      chmod +x "$scratch/existing/.git/hooks/pre-push"
      cp "$scratch/existing/.git/hooks/pre-push" "$scratch/pre-push.expected"
      expect_rc 1 "$scratch/existing" \
        "an existing user hook (pre-push) must make the installer skip"
      cmp -s "$scratch/pre-push.expected" "$scratch/existing/.git/hooks/pre-push" || {
        echo "FAIL: the user pre-push hook was modified" >&2
        exit 1
      }
      test -x "$scratch/existing/.git/hooks/pre-push"
      test ! -e "$scratch/existing/.git/hooks/pre-commit"

      # 3. Custom hook routing must be left untouched, config included.
      git init -q "$scratch/routing"
      git -C "$scratch/routing" config core.hooksPath .githooks
      mkdir "$scratch/routing/.githooks"
      expect_rc 1 "$scratch/routing" \
        "custom core.hooksPath routing must make the installer skip"
      case "$lastGuardOutput" in
        *core.hooksPath*) : ;;
        *) echo "FAIL: skip reason must mention core.hooksPath (got: $lastGuardOutput)" >&2; exit 1 ;;
      esac
      test "$(git -C "$scratch/routing" config --get core.hooksPath)" = ".githooks"
      test "$(find "$scratch/routing/.githooks" -mindepth 1 | wc -l)" = 0

      # 4. Hooks present in the default directory are skipped even when
      #    core.hooksPath names the default directory explicitly.
      git init -q "$scratch/ownhooks"
      git -C "$scratch/ownhooks" config core.hooksPath .git/hooks
      printf '#!/bin/sh\necho sentinel-again\n' > "$scratch/ownhooks/.git/hooks/pre-commit"
      expect_rc 1 "$scratch/ownhooks" \
        "any existing hook in the hooks directory must make the installer skip"

      # 5. Outside a Git checkout the installer must skip, not crash or write.
      mkdir "$scratch/norepo"
      expect_rc 1 "$scratch/norepo" \
        "outside a Git checkout the installer must skip"

      # 6. `git init --template=` produces a checkout with NO hooks directory;
      #    the pre-guard baseline installed successfully there, so a missing
      #    directory is a clean checkout, not custom routing and not an
      #    existing hook. Routing set to a missing or empty directory inside
      #    must still skip (case 2 catches it), and case 3 must stay intact.
      git init -q --template= "$scratch/nohooksdir"
      test ! -d "$scratch/nohooksdir/.git/hooks"
      expect_rc 0 "$scratch/nohooksdir" \
        "a checkout without a hooks directory must allow installation like the baseline"

      echo "guard behavior cases passed: clean install, user-hook skip (pre-push preserved), custom-routing skip, existing-hooks skip, no-repo skip, missing-hooks-dir install" >> "$out"
      rm -rf "$scratch"
    ''
  else throw "Dev shell hook contract violations:\n${lib.concatStringsSep "\n" violations}"
