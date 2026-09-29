# Exercise the real pinned HM fragments, not a simulation or full activation.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  names = [
    "aytordev-pen-ops"
    "dotfiles-coder"
    "impeccable"
    "nix"
    "skill-creator"
    "skill-registry"
  ];
  # Historical source requirements stay fixed if publication expands later.
  oldNames = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
  oldSkills = pkgs.runCommand "old-skills-shape-fixture" {} ''
    for name in ${lib.escapeShellArgs (oldNames ++ ["retired-fixture"])}; do
      mkdir -p "$out/$name"
      printf 'old-%s\n' "$name" > "$out/$name/SKILL.md"
    done
    mkdir -p "$out/_shared"
    printf 'old-resolver\n' > "$out/_shared/skill-resolver.md"
  '';
  mkHome = module:
    (inputs.self.lib.system.mkHome {
      username = "skills-transition";
      hostname = "skills-transition";
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        {
          aytordev.user = {
            enable = true;
            name = "skills-transition";
            email = "skills@example.test";
            fullName = "Skills Transition";
            home =
              if pkgs.stdenv.hostPlatform.isDarwin
              then "/Users/skills-transition"
              else "/home/skills-transition";
          };
          home.stateVersion = "25.11";
        }
        module
      ];
    }).config;
  old = mkHome {
    home.file.".pi/agent/skills".source = oldSkills;
  };
  current = mkHome {
    aytordev.programs.terminal.tools = {
      pi.enable = true;
      ai-skills.enable = true;
    };
  };
  # Separate fixture for the later seven-skill per-file publication. Do not
  # change the historical four-skill whole-root migration above.
  retiredNames = ["aytordev-design-system" "aytordev-interface-design"];
  retiredSkills = pkgs.runCommand "retired-design-skills-fixture" {} ''
    for name in ${lib.escapeShellArgs retiredNames}; do
      mkdir -p "$out/$name/references"
      printf 'retired-%s\n' "$name" > "$out/$name/SKILL.md"
      printf '{}\n' > "$out/$name/metadata.json"
      printf 'retired support\n' > "$out/$name/references/guide.md"
    done
  '';
  previous = mkHome {
    home.file = lib.genAttrs (map (name: ".pi/agent/skills/${name}") (lib.filter (name: name != "impeccable") names ++ retiredNames)) (target: let
      name = baseNameOf target;
    in {
      source =
        if lib.elem name retiredNames
        then "${retiredSkills}/${name}"
        else ../../modules/common/ai-tools/skills + "/${name}";
      recursive = true;
    });
  };
  fragment = config: name: pkgs.writeText "skills-${name}" config.home.activation.${name}.data;
  hmLib = pkgs.writeText "skills-hm-lib" current.lib.bash.initHomeManagerLib;
  prepare = ../../modules/common/ai-tools/scripts/prepare-pi-skills.sh;
in
  assert lib.all (file: !file.force) (builtins.attrValues current.home.file);
    pkgs.runCommand "ai-skills-transition" {
      nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.findutils pkgs.diffutils pkgs.gettext];
    } ''
      set -euo pipefail
      mkdir -p "$out" "$TMPDIR/old-generation" "$TMPDIR/new-generation"
      # Keep variable diagnostics in the build log, not the store output.
        ln -s ${old.home-files} "$TMPDIR/old-generation/home-files"
        ln -s ${current.home-files} "$TMPDIR/new-generation/home-files"
        mkdir "$TMPDIR/previous-generation"
        ln -s ${previous.home-files} "$TMPDIR/previous-generation/home-files"

        # A fresh shell per fragment matches activation's fail-fast boundary.
        hm() (
          export HOME="$1" HOME_MANAGER_BACKUP_EXT="$2"
          export HOME_MANAGER_BACKUP_COMMAND="" HOME_MANAGER_BACKUP_OVERWRITE=""
          export VERBOSE_ARG="" newGenPath="$TMPDIR/new-generation" oldGenPath="''${4:-$TMPDIR/old-generation}"
          unset DRY_RUN DRY_RUN_CMD VERBOSE || true
          cd "$HOME"
          . ${hmLib}
          . "$3"
        )
        seed_old() {
          mkdir -p "$1"
          (export HOME="$1" newGenPath="$TMPDIR/old-generation" VERBOSE_ARG=""
           unset oldGenPath DRY_RUN DRY_RUN_CMD VERBOSE || true
           . ${hmLib}
           . ${fragment old "linkGeneration"})
          test -L "$1/.pi/agent/skills"
        }
        transition() { HOME="$1" bash ${prepare}; }
        check_links() { hm "$1" "$2" ${fragment current "checkLinkTargets"}; }
        link_generation() { hm "$1" "$2" ${fragment current "linkGeneration"}; }
        expect_refusal() {
          local home="$1"
        if transition "$home"; then
          echo "unexpected transition success: $home" >&2; exit 1
        else
          test "$?" -eq 1
          fi
        }

        # Both without backups and with the real Darwin hm.old policy.
        for backups in "" hm.old; do
          home="$TMPDIR/baseline-''${backups:-none}"
          seed_old "$home"
          old_target="$(readlink "$home/.pi/agent/skills")"
          if check_links "$home" "$backups"; then
            # Identical old leaves can pass checkLinkTargets, but the readonly
            # parent still prevents linking new content, even with hm.old.
            if link_generation "$home" "$backups"; then
              echo "baseline Pi root unexpectedly activated" >&2; exit 1
            fi
        fi
        test "$(readlink "$home/.pi/agent/skills")" = "$old_target"
        # Start the positive case from an untouched old generation.
        home="$TMPDIR/transition-''${backups:-none}"
        seed_old "$home"
        transition "$home"
          test ! -e "$home/.pi/agent/skills"
        test "$(readlink "$home/.pi/agent/skills.hm-before-native/skills")" = "$old_target"
        test "$(stat -c %a "$home/.pi/agent/skills.hm-before-native")" = 700
          check_links "$home" "$backups"
          link_generation "$home" "$backups"
          for root in .pi/agent/skills; do
            test ! -L "$home/$root"
            for name in ${lib.escapeShellArgs names}; do
              test ! -L "$home/$root/$name"
              test "$(readlink "$home/$root/$name/SKILL.md")" = "${current.home-files}/$root/$name/SKILL.md"
            done
          done
          test ! -e "$home/.pi/agent/skills/retired-fixture/SKILL.md"
          test -f "$home/.pi/agent/skills.hm-before-native/skills/retired-fixture/SKILL.md"
          printf 'PASS baseline transition and old content preserved: backups=%s\n' "$backups"
        done

        # The preparation step refuses foreign files, directories, live/broken
        # links, and an HM-looking directory outside the immutable store.
        for kind in file directory symlink dangling fake-hm; do
          home="$TMPDIR/foreign-$kind"
          mkdir -p "$home/.pi/agent" "$home/foreign-home-manager-files/.pi/agent/skills"
          printf 'foreign\n' > "$home/foreign-home-manager-files/.pi/agent/skills/keep"
          target="$home/.pi/agent/skills"
          case "$kind" in
            file) printf 'foreign\n' > "$target" ;;
            directory) mkdir "$target"; printf 'foreign\n' > "$target/keep" ;;
          symlink) ln -s "$home/foreign-home-manager-files" "$target" ;;
          fake-hm) ln -s "$home/foreign-home-manager-files/.pi/agent/skills" "$target" ;;
            dangling) ln -s "$home/absent" "$target" ;;
          esac
          cp -a "$home" "$home-before"
          expect_refusal "$home"
          diff -r --no-dereference "$home-before" "$home"
        printf 'PASS foreign %s refused unchanged\n' "$kind"
      done

      home="$TMPDIR/foreign-parent"
      mkdir -p "$home/external/agent"
      ln -s "$home/external" "$home/.pi"
      ln -s "${old.home-files}/.pi/agent/skills" "$home/.pi/agent/skills"
      cp -a "$home" "$home-before"
      expect_refusal "$home"
      diff -r --no-dereference "$home-before" "$home"
      printf 'PASS symlinked ancestor refused unchanged\n'

      home="$TMPDIR/not-old-shape"
      mkdir -p "$home/.pi/agent"
      ln -s "${current.home-files}/.pi/agent/skills" "$home/.pi/agent/skills"
      expect_refusal "$home"
      test "$(readlink "$home/.pi/agent/skills")" = "${current.home-files}/.pi/agent/skills"
      test ! -e "$home/.pi/agent/skills.hm-before-native"
      printf 'PASS newer HM directory shape refused unchanged\n'

        for kind in file directory symlink dangling; do
          home="$TMPDIR/backup-$kind"
          seed_old "$home"
          backup="$home/.pi/agent/skills.hm-before-native"
          case "$kind" in
            file) printf 'saved\n' > "$backup" ;;
            directory) mkdir "$backup"; printf 'saved\n' > "$backup/keep" ;;
            symlink) ln -s ${oldSkills} "$backup" ;;
            dangling) ln -s "$home/absent" "$backup" ;;
          esac
          cp -a "$home" "$home-before"
          expect_refusal "$home"
          diff -r --no-dereference "$home-before" "$home"
          printf 'PASS existing backup %s not clobbered\n' "$kind"
        done

        # HM's own file collisions after transition: no-backup refuses, Darwin
        # backups preserve a foreign real file, existing hm.old refuses overwrite,
        # and a foreign live symlink is never redirected.
        home="$TMPDIR/hm-collision"
        seed_old "$home"
        transition "$home"
        # Materialize the current per-file Pi layout, then introduce foreign
        # collisions at a managed leaf.
        check_links "$home" ""
        link_generation "$home" ""
        leaf="$home/.pi/agent/skills/nix/SKILL.md"
        rm "$leaf"
        printf 'foreign-leaf\n' > "$leaf"
        if check_links "$home" ""; then exit 1; fi
        test "$(cat "$leaf")" = foreign-leaf
        printf 'older-backup\n' > "$leaf.hm.old"
        if check_links "$home" hm.old; then exit 1; fi
        test "$(cat "$leaf.hm.old")" = older-backup
        rm "$leaf.hm.old"
        check_links "$home" hm.old
        link_generation "$home" hm.old
        test "$(cat "$leaf.hm.old")" = foreign-leaf
        rm "$leaf"
        printf 'external\n' > "$home/external"
        ln -s "$home/external" "$leaf"
        if check_links "$home" hm.old; then exit 1; fi
        test "$(readlink "$leaf")" = "$home/external"
        test "$(cat "$home/external")" = external
        printf 'PASS HM collisions, Darwin backups, and foreign symlink preservation\n'
        # Retire only HM-owned leaves from the current per-file layout. Keep
        # native skills/profile files, additions inside retained/retired folders,
        # and foreign replacements at previously managed paths.
        for backups in "" hm.old; do
          for kind in managed file symlink; do
            home="$TMPDIR/retirement-''${backups:-none}-$kind"
            mkdir -p "$home"
            (export HOME="$home" newGenPath="$TMPDIR/previous-generation" VERBOSE_ARG=""
             unset oldGenPath DRY_RUN DRY_RUN_CMD VERBOSE || true
             . ${hmLib}
             . ${fragment previous "linkGeneration"})
            mkdir -p "$home/.pi/agent/skills/native-skill"
            printf 'native skill\n' > "$home/.pi/agent/skills/native-skill/SKILL.md"
            printf 'native settings\n' > "$home/.pi/agent/settings.json"
            printf 'native pen support\n' > "$home/.pi/agent/skills/aytordev-pen-ops/native.txt"
            for name in ${lib.escapeShellArgs retiredNames}; do
              directory="$home/.pi/agent/skills/$name"
              test -L "$directory/SKILL.md"
              printf 'native addition\n' > "$directory/keep.txt"
              case "$kind" in
                file) rm "$directory/SKILL.md"; printf 'foreign skill\n' > "$directory/SKILL.md" ;;
                symlink)
                  rm "$directory/SKILL.md"
                  printf 'external skill\n' > "$home/external-$name"
                  ln -s "$home/external-$name" "$directory/SKILL.md"
                  ;;
              esac
            done
            hm "$home" "$backups" ${fragment current "checkLinkTargets"} "$TMPDIR/previous-generation"
            hm "$home" "$backups" ${fragment current "linkGeneration"} "$TMPDIR/previous-generation"
            for name in ${lib.escapeShellArgs names}; do
              test ! -L "$home/.pi/agent/skills/$name"
              test "$(readlink "$home/.pi/agent/skills/$name/SKILL.md")" = "${current.home-files}/.pi/agent/skills/$name/SKILL.md"
            done
            for name in ${lib.escapeShellArgs retiredNames}; do
              directory="$home/.pi/agent/skills/$name"
              test ! -e "$directory/metadata.json" && test ! -L "$directory/metadata.json"
              test ! -e "$directory/references/guide.md" && test ! -L "$directory/references/guide.md"
              test "$(cat "$directory/keep.txt")" = 'native addition'
              case "$kind" in
                managed) test ! -e "$directory/SKILL.md" && test ! -L "$directory/SKILL.md" ;;
                file) test ! -L "$directory/SKILL.md"; test "$(cat "$directory/SKILL.md")" = 'foreign skill' ;;
                symlink)
                  test "$(readlink "$directory/SKILL.md")" = "$home/external-$name"
                  test "$(cat "$directory/SKILL.md")" = 'external skill'
                  ;;
              esac
            done
            test "$(cat "$home/.pi/agent/skills/native-skill/SKILL.md")" = 'native skill'
            test "$(cat "$home/.pi/agent/settings.json")" = 'native settings'
            test "$(cat "$home/.pi/agent/skills/aytordev-pen-ops/native.txt")" = 'native pen support'
            printf 'PASS per-file retirement preserves native files: backups=%s kind=%s\n' "$backups" "$kind"
          done
        done
        touch "$out/passed"
    ''
