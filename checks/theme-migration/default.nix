# Regression check for theme file deployment.
#
# Reproduces the class of bug from the retired Pi theme deployment: declaring
# individual files *inside* a directory that Home Manager deploys as a single
# store-backed symlink. The store is read-only, so the activation cannot place
# a child link under it and the whole switch fails.
#
# Two layers:
#
# 1. Structural invariant over every `home.file` entry (Home Manager folds
#    `xdg.configFile` into `home.file`; see `modules/misc/xdg/default.nix`).
#    No entry target may live strictly inside a non-recursive directory source,
#    because that source becomes one symlink to a store directory.
# 2. Transition harness. It executes the *real* Home Manager activation
#    fragments (`checkLinkTargets` and `linkGeneration`) shipped by the
#    evaluated home against temporary HOME directories. It is not a hand-rolled
#    simulation: the exact generated shell is reused. The full `activate`
#    script is intentionally not run — it performs profile installs and
#    platform service management that need a real host.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) boolToString concatMapStrings;

  username = "theme-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # One synthetic home that exercises every generated-theme deployment path.
  # Sora light has no native light resource, so Ghostty and Zed both fall back
  # to palette-generated files; Yazi exercises directory-source themes.
  themeHome = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "theme-migration-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "theme-migration@example.test";
            fullName = "Theme Migration User";
            home = homeDirectory;
          };
          theme = {
            name = "sora";
            variant = "light";
          };
          programs = {
            terminal.tools.yazi.enable = true;
            terminal.emulators.ghostty.enable = true;
            desktop.editors.zed.enable = true;
          };
        };
        # Yazi plugins are unrelated to theme deployment; keep them out so the
        # check builds only the theme artifacts it asserts on.
        programs.yazi.plugins = lib.mkForce {};
        home.stateVersion = "25.11";
      }
    ];
  };
  cfg = themeHome.config;

  # Home Manager's XDG module folds `xdg.configFile` (and the cache/data/state
  # variants) into `home.file` under `${configHome}/<name>`, so iterating
  # `home.file` sees both. Every entry carries a home-relative `target` and a
  # store-backed `source`.
  entries =
    lib.mapAttrsToList (_: v: {
      inherit (v) target source recursive;
    })
    cfg.home.file;
  targets = map (e: e.target) entries;

  # Build-time manifest. Embedding the source store paths in the text makes
  # them build dependencies, so the runCommand can inspect the realized file
  # type of every source. Directory-ness cannot be decided during evaluation:
  # an unbuilt derivation output is not a valid path for `builtins.readDir` /
  # `builtins.readFileType`.
  manifest = pkgs.writeText "theme-migration-manifest.tsv" (
    concatMapStrings (e: "${e.target}\t${toString e.source}\t${boolToString e.recursive}\n") entries
  );

  # Reuse the generated activation fragments verbatim. `hmLib` brings in the
  # `run` / `_i` / `warnEcho` helpers those fragments call.
  hmLib = pkgs.writeText "theme-migration-hm-lib" cfg.lib.bash.initHomeManagerLib;
  checkLinkTargetsData = pkgs.writeText "theme-migration-check-link-targets" cfg.home.activation.checkLinkTargets.data;
  linkGenerationData = pkgs.writeText "theme-migration-link-generation" cfg.home.activation.linkGeneration.data;

  # A synthesized previous generation. The name ends in `-home-manager-files`
  # so the cleanup fragment classifies its links as Home Manager-owned.
  fakeOldFiles = pkgs.runCommand "theme-migration-old-home-manager-files" {} ''
    mkdir -p "$out/.config/yazi/flavors/sora-light.yazi"
    printf 'old-flavor\n' > "$out/.config/yazi/flavors/sora-light.yazi/flavor.toml"
    printf 'old-obsolete\n' > "$out/.config/yazi/flavors/obsolete.yazi"
  '';

  # Pure coverage: retain the same directory-source shape with a surviving
  # themed app. Yazi flavors are directories, like the retired OpenCode themes
  # directory.
  flavorTarget = ".config/yazi/flavors/sora-light.yazi";
  coverageTests = [
    (lib.elem flavorTarget targets)
    (lib.elem ".config/ghostty/themes/aytordev.conf" targets)
    (lib.elem ".config/zed/themes/aytordev.json" targets)
    (lib.elem ".config/ghostty/shaders/cursor_smear.glsl" targets)
    (lib.all (t: !(lib.hasPrefix "${flavorTarget}/") t) targets)
    (lib.length (lib.unique targets) == lib.length targets)
  ];
in
  assert lib.all (t: t) coverageTests;
    pkgs.runCommand "theme-migration"
    {
      nativeBuildInputs = [
        pkgs.bash
        pkgs.coreutils
        pkgs.diffutils
        pkgs.findutils
        pkgs.gettext
        pkgs.gnugrep
      ];
    }
    ''
      set -o pipefail

      homeFiles=${cfg.home-files}
      manifest=${manifest}
      hmLib=${hmLib}
      checkData=${checkLinkTargetsData}
      linkData=${linkGenerationData}
      oldFiles=${fakeOldFiles}

      work="$PWD/work"
      mkdir -p "$work"
      gen="$work/gen"
      mkdir -p "$gen"
      ln -s "$homeFiles" "$gen/home-files"

      failures=0
      fail() {
        echo "FAIL: $*" >&2
        failures=1
      }

      # ------------------------------------------------------------------
      # 1. Structural invariant. A non-recursive directory source is a single
      #    store-backed symlink, so nothing may be deployed inside it.
      #    Recursive sources expand to individual links, so descendants are
      #    allowed there.
      #
      #    `scan_invariant` is also run over a known-bad manifest below so the
      #    check cannot pass vacuously.
      # ------------------------------------------------------------------
      SCAN_ENTRIES=0
      SCAN_DIRS=0
      SCAN_VIOLATIONS=0
      scan_invariant() {
        local file="$1"
        declare -a all=()
        declare -a dirs=()
        local target source recursive dir t
        while IFS=$'\t' read -r target source recursive; do
          [ -n "$target" ] || continue
          all+=("$target")
          if [ -d "$source" ] && [ "$recursive" != "true" ]; then
            dirs+=("$target")
          fi
        done < "$file"
        SCAN_ENTRIES="''${#all[@]}"
        SCAN_DIRS="''${#dirs[@]}"
        for dir in "''${dirs[@]}"; do
          for t in "''${all[@]}"; do
            case "$t" in
              "$dir"/*)
                echo "VIOLATION: '$t' is inside directory-source '$dir'"
                SCAN_VIOLATIONS=$((SCAN_VIOLATIONS + 1))
                ;;
            esac
          done
        done
      }

      scan_invariant "$manifest"
      if [ "$SCAN_DIRS" -eq 0 ]; then
        fail "no directory-source entries found; invariant would be vacuous"
      fi
      if [ "$SCAN_VIOLATIONS" -ne 0 ]; then
        fail "real manifest has $SCAN_VIOLATIONS invariant violation(s)"
      fi
      echo "structural: $SCAN_ENTRIES entries, $SCAN_DIRS directory sources, 0 violations"

      # Self-test: a file nested inside a directory symlink must be flagged.
      bad_manifest="$work/bad-manifest.tsv"
      printf '.config/yazi/flavors/sora-light.yazi\t%s/.config/yazi/flavors/sora-light.yazi\tfalse\n' "$oldFiles" > "$bad_manifest"
      printf '.config/yazi/flavors/sora-light.yazi/flavor.toml\t%s/.config/yazi/flavors/sora-light.yazi/flavor.toml\tfalse\n' "$oldFiles" >> "$bad_manifest"
      SCAN_VIOLATIONS=0
      scan_invariant "$bad_manifest"
      if [ "$SCAN_VIOLATIONS" -eq 0 ]; then
        fail "invariant self-test missed a known violation"
      fi
      echo "structural self-test: caught $SCAN_VIOLATIONS known violation(s)"

      # ------------------------------------------------------------------
      # 2. Transition harness running the real Home Manager fragments.
      # ------------------------------------------------------------------
      run_links() {
        local home="$1"
        local old="''${2:-}"
        (
          export HOME="$home"
          export newGenPath="$gen"
          export VERBOSE_ARG=""
          unset DRY_RUN DRY_RUN_CMD VERBOSE || true
          if [ -n "$old" ]; then
            export oldGenPath="$old"
          else
            unset oldGenPath || true
          fi
          cd "$HOME"
          . "$hmLib"
          . "$linkData"
        )
      }

      expect_link() {
        local home="$1" target="$2" dest
        if [ ! -L "$home/$target" ]; then
          fail "$target ($home) is not a symlink"
          return
        fi
        dest="$(readlink "$home/$target")"
        case "$dest" in
          "$homeFiles"/*) : ;;
          *) fail "$target -> $dest does not point into the new generation" ;;
        esac
      }

      # No prior state: every managed target is linked.
      s1="$work/s1"
      mkdir -p "$s1/home"
      run_links "$s1/home"
      expect_link "$s1/home" ".config/yazi/flavors/sora-light.yazi"
      expect_link "$s1/home" ".config/ghostty/themes/aytordev.conf"
      expect_link "$s1/home" ".config/zed/themes/aytordev.json"

      # Managed links from a previous generation: live links are relinked and
      # orphans are cleaned up.
      s2="$work/s2"
      mkdir -p "$s2/home/.config/yazi/flavors"
      ln -s "$oldFiles/.config/yazi/flavors/sora-light.yazi" "$s2/home/.config/yazi/flavors/sora-light.yazi"
      ln -s "$oldFiles/.config/yazi/flavors/obsolete.yazi" "$s2/home/.config/yazi/flavors/obsolete.yazi"
      oldgen="$work/oldgen"
      mkdir -p "$oldgen"
      ln -s "$oldFiles" "$oldgen/home-files"
      run_links "$s2/home" "$oldgen"
      expect_link "$s2/home" ".config/yazi/flavors/sora-light.yazi"
      if [ -e "$s2/home/.config/yazi/flavors/obsolete.yazi" ] || [ -L "$s2/home/.config/yazi/flavors/obsolete.yazi" ]; then
        fail "orphan link .config/yazi/flavors/obsolete.yazi was not cleaned up"
      fi

      # Broken symlink at the target: still ours, so it is replaced.
      s3="$work/s3"
      mkdir -p "$s3/home/.config/yazi/flavors"
      ln -s "$work/does-not-exist" "$s3/home/.config/yazi/flavors/sora-light.yazi"
      run_links "$s3/home"
      expect_link "$s3/home" ".config/yazi/flavors/sora-light.yazi"

      # Foreign regular directory: the real activation runs `checkLinkTargets`
      # before `linkGeneration` and aborts on a collision. Assert it fails and
      # never touches the user's data.
      s4="$work/s4"
      mkdir -p "$s4/home/.config/yazi/flavors/sora-light.yazi"
      printf 'user-owned-dir\n' > "$s4/home/.config/yazi/flavors/sora-light.yazi/keep.txt"
      if (
        export HOME="$s4/home"
        export newGenPath="$gen"
        export VERBOSE_ARG=""
        unset DRY_RUN DRY_RUN_CMD VERBOSE || true
        cd "$HOME"
        . "$hmLib"
        . "$checkData"
      ); then
        fail "checkLinkTargets accepted a foreign directory in the way"
      fi
      [ "$(cat "$s4/home/.config/yazi/flavors/sora-light.yazi/keep.txt")" = "user-owned-dir" ] || fail "foreign directory contents were modified"
      [ ! -L "$s4/home/.config/yazi/flavors/sora-light.yazi" ] || fail "foreign directory was replaced by a symlink"

      if [ "$failures" -ne 0 ]; then
        exit 1
      fi
      echo "transitions: s1=fresh s2=previous-gen+cleanup s3=broken-symlink s4=foreign-data all passed"
      touch "$out"
    ''
