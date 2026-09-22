# Package ownership and per-skill file publication; never runs native onboarding.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  username = "ai-ownership-check";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  mkHomeWith = extraModule: tools:
    (inputs.self.lib.system.mkHome {
      inherit username;
      system = pkgs.stdenv.hostPlatform.system;
      hostname = "ai-ownership-check";
      modules = [
        {
          aytordev.user = {
            enable = true;
            name = username;
            email = "ai-ownership@example.test";
            fullName = "AI Ownership Check";
            home = homeDirectory;
          };
          aytordev.programs.terminal.tools = tools;
          home.stateVersion = "25.11";
        }
        extraModule
      ];
    }).config;
  mkHome = mkHomeWith {};
  enabledTools = {
    pi.enable = true;
    gentle-ai.enable = true;
    engram.enable = true;
    ai-skills.enable = true;
  };
  enabled = mkHome enabledTools;
  disabled = mkHome {};
  noSkills = mkHome (enabledTools // {ai-skills.enable = false;});
  noClients = mkHome {ai-skills.enable = true;};
  customHomeDirectory = "${homeDirectory}/custom home";
  custom =
    mkHomeWith {
      aytordev.user.home = lib.mkForce customHomeDirectory;
      xdg.dataHome = "${customHomeDirectory}/Data";
      xdg.configHome = "${customHomeDirectory}/Config";
    }
    enabledTools;
  piOnly = mkHome {
    pi.enable = true;
    ai-skills.enable = true;
  };
  providersTarget = ".pi/agent/models.json";
  withProviders = mkHome (enabledTools
    // {
      pi = {
        enable = true;
        providers = {
          example = {
            baseUrl = "https://example.test/v1";
            api = "openai-completions";
            apiKey = "!cat /nonexistent/key";
            models = [];
          };
        };
      };
    });
  selected = pkgs.writeShellScriptBin "selected-ai" "exit 0";
  overrides = mkHome (enabledTools
    // {
      pi = {
        enable = true;
        package = selected;
      };
      gentle-ai = {
        enable = true;
        package = selected;
      };
      engram = {
        enable = true;
        package = selected;
      };
    });
  installed = home: package: lib.any (p: p.outPath == package.outPath) home.home.packages;
  tools = enabled.aytordev.programs.terminal.tools;
  names = [
    "aytordev-design-system"
    "aytordev-interface-design"
    "aytordev-pen-ops"
    "dotfiles-coder"
    "nix"
    "skill-creator"
    "skill-registry"
  ];
  targets = home: map (file: file.target) (builtins.attrValues home.home.file);
  under = root: home: lib.sort builtins.lessThan (lib.filter (lib.hasPrefix root) (targets home));
  expected = root: map (name: "${root}${name}") names;
  piRoot = ".pi/agent/skills/";
  catalogRoot = ".local/share/aytordev/skills";
  checks = {
    packagesEnabled = lib.all (name: installed enabled tools.${name}.package) ["pi" "gentle-ai" "engram"];
    packagesDisabled = lib.all (name: !(installed disabled tools.${name}.package)) ["pi" "gentle-ai" "engram"];
    packageOverrides = lib.all (name: overrides.aytordev.programs.terminal.tools.${name}.package == selected) ["pi" "gentle-ai" "engram"] && installed overrides selected;
    npmPrerequisite = installed enabled pkgs.nodejs;
    noSelfUpdate = enabled.home.sessionVariables.GENTLE_AI_NO_SELF_UPDATE == "1";
    engramEnvironment =
      enabled.home.sessionVariables.ENGRAM_BIN
      == lib.getExe tools.engram.package
      && enabled.home.sessionVariables.ENGRAM_DATA_DIR == "${homeDirectory}/.local/share/engram"
      && enabled.home.sessionVariables.ENGRAM_NO_UPDATE_CHECK == "1";
    disabledEnvironment = lib.all (name: !(builtins.hasAttr name disabled.home.sessionVariables)) ["GENTLE_AI_NO_SELF_UPDATE" "ENGRAM_BIN" "ENGRAM_DATA_DIR" "ENGRAM_NO_UPDATE_CHECK"];
    engramOverrideShared =
      overrides.home.sessionVariables.ENGRAM_BIN
      == lib.getExe selected;
    noAdapter = !(tools.gentle-ai ? adapter) && !(lib.any (p: lib.getName p == "aytordev-sdd") enabled.home.packages);
    noLegacyOptions =
      builtins.attrNames tools.pi
      == ["agent-profiles" "enable" "package" "providers" "startup-header"]
      && builtins.attrNames tools.gentle-ai == ["enable" "package"];
    noProfile = under ".pi/" noSkills == [] && !(enabled.home.sessionVariables ? PI_CODING_AGENT_DIR);
    piPublishedSkills = under ".pi/" enabled == expected piRoot;
    providersDefaultAbsent = !(lib.elem providersTarget (targets enabled)) && !(lib.elem providersTarget (targets noSkills));
    providersPublished = lib.elem providersTarget (targets withProviders);
    providersOnlyExtra =
      under ".pi/" withProviders
      == lib.sort builtins.lessThan (expected piRoot ++ [providersTarget]);
    providersContent = let
      file = builtins.getAttr providersTarget withProviders.home.file;
    in
      lib.hasInfix "\"providers\"" file.text && lib.hasInfix "\"example\"" file.text;
    skillsDisabled = under piRoot noSkills == [];
    clientsDisabled = under piRoot noClients == [];
    neutralEnabled = enabled.xdg.dataFile ? "aytordev/skills";
    standaloneCollection = under ".local/share/aytordev/" noClients == [catalogRoot];
    neutralDisabled = !(disabled.xdg.dataFile ? "aytordev/skills") && !(noSkills.xdg.dataFile ? "aytordev/skills");
    customHomeAndXdg =
      custom.home.homeDirectory
      == customHomeDirectory
      && under "Data/aytordev/" custom == ["Data/aytordev/skills"]
      && under piRoot custom == expected piRoot;
    clientGates = under piRoot piOnly == expected piRoot;
    noSharedRoot = under ".agents/" enabled == [];
  };
  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);
in
  if failed != []
  then throw "AI ownership failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-native-ownership-check" {
      nativeBuildInputs = [pkgs.diffutils pkgs.python3];
    } ''
      # Realize the public archive and HM leaf publication without executing a CLI.
      test -x ${tools.gentle-ai.package}/bin/gentle-ai
      ${lib.concatMapStringsSep "\n" (name: ''
          test -d ${enabled.home-files}/${piRoot}${name}
          test ! -L ${enabled.home-files}/${piRoot}${name}
          test -L ${enabled.home-files}/${piRoot}${name}/SKILL.md
          test -f ${enabled.home-files}/${piRoot}${name}/SKILL.md
          # The Pi projection and the standalone collection contain the full
          # canonical folder, not just its entry point or a digest.
          for root in ${enabled.home-files}/${catalogRoot} \
            ${enabled.home-files}/${piRoot} \
            ${noClients.home-files}/${catalogRoot} \
            ${custom.home-files}/Data/aytordev/skills; do
            diff -r ${../../modules/common/ai-tools/skills}/${name} "$root/${name}"
          done
          mkdir "$TMPDIR/isolated-${name}"
          cp -RL ${noClients.home-files}/${catalogRoot}/${name} "$TMPDIR/isolated-${name}/${name}"
          python ${./portable-folder.py} "$TMPDIR/isolated-${name}/${name}"
        '')
        names}
      python -c 'import os, sys; assert sorted(os.listdir(sys.argv[1])) == sys.argv[2:]' \
        ${noClients.home-files}/${catalogRoot} ${lib.escapeShellArgs names}
      # Running --help uses the copied Nix helper, without invoking Nix builds.
      python "$TMPDIR/isolated-nix/nix/scripts/package-diff-report.py" --help > /dev/null
      # Prove missing support is detected in a completely separate copied folder.
      chmod -R u+w "$TMPDIR/isolated-skill-registry"
      rm "$TMPDIR/isolated-skill-registry/skill-registry/references/skill-resolver.md"
      if python ${./portable-folder.py} "$TMPDIR/isolated-skill-registry/skill-registry"; then
        echo 'Missing portable resolver was not detected' >&2
        exit 1
      fi
      echo 'PASS missing bundled support rejected; neutral and client contents match'
      touch "$out"
    ''
