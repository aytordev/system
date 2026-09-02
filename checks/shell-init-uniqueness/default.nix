{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "shell-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "shell-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "shell@example.test";
            fullName = "Shell User";
            home = homeDirectory;
          };
        };
        home.stateVersion = "25.11";
      }
      {aytordev.suites.common.enable = true;}
      {aytordev.suites.development.enable = true;}
    ];
  };
  inherit (home) config;

  # A home where one shell is disabled must not pull that shell's integration:
  # tool integrations follow enabledNames, and bash conf.d drop-ins are guarded.
  subsetHome = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "shell-subset";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "shell@example.test";
            fullName = "Shell User";
            home = homeDirectory;
          };
        };
        home.stateVersion = "25.11";
      }
      {aytordev.suites.common.enable = true;}
      {aytordev.suites.development.enable = true;}
      {aytordev.programs.terminal.shells.bash.enable = false;}
    ];
  };
  sc = subsetHome.config;
  subsetTests = [
    (!sc.programs.bash.enable)
    (!sc.programs.zoxide.enableBashIntegration)
    sc.programs.zoxide.enableFishIntegration
    (!sc.programs.starship.enableBashIntegration)
    (!(sc.xdg.configFile ? "bash/conf.d/bat.sh"))
    (!(sc.home.file ? "bash/conf.d/git-aliases.sh"))
  ];
  subsetPass = builtins.all (test: test) subsetTests;

  cfgText = v: v.text or (builtins.readFile v.source);
  bashConfDFiles =
    lib.filterAttrs (
      name: _: lib.hasPrefix "bash/conf.d/" name && lib.hasSuffix ".sh" name
    )
    config.xdg.configFile;
  bashConfD = lib.concatStringsSep "\n" (map cfgText (lib.attrValues bashConfDFiles));
  # Files under bash/conf.d/*/ are never sourced by the top-level glob in
  # shells/bash and are therefore dead configuration.
  bashConfDSubdirs =
    lib.filterAttrs (
      name: _: lib.hasInfix "/" (lib.removePrefix "bash/conf.d/" name)
    )
    bashConfDFiles;

  texts = {
    zshEnv = config.programs.zsh.envExtra;
    zshInit = config.programs.zsh.initContent;
    fishInit = config.programs.fish.shellInit;
    fishInteractive = config.programs.fish.interactiveShellInit;
    bashInit = config.programs.bash.initExtra;
    bashRc = config.programs.bash.bashrcExtra;
    inherit bashConfD;
    nuConfig = config.programs.nushell.extraConfig;
  };
  textFiles = lib.mapAttrs (label: text: pkgs.writeText "shell-${label}" text) texts;

  # Per shell: combined init text and the markers that must appear at most once
  # across that shell's whole startup (each tool initializes exactly once).
  shellChecks = [
    {
      shell = "zsh";
      files = [
        "zshEnv"
        "zshInit"
      ];
      markers = [
        "zoxide init"
        "_carapace"
        "atuin init"
        "&& compinit"
        "&& bashcompinit"
      ];
    }
    {
      shell = "fish";
      files = [
        "fishInit"
        "fishInteractive"
      ];
      markers = [
        "zoxide init"
        "direnv hook"
        "starship init"
        "_carapace"
        "atuin init"
      ];
    }
    {
      shell = "bash";
      files = [
        "bashInit"
        "bashRc"
        "bashConfD"
      ];
      markers = [
        "zoxide init"
        "_carapace"
        "atuin init"
        "starship init"
        "direnv hook"
      ];
    }
    {
      shell = "nushell";
      files = ["nuConfig"];
      markers = [
        "starship prompt"
        "direnv export json"
      ];
    }
  ];

  checksScript = lib.concatLines (
    map (
      c: let
        catFiles = lib.concatStringsSep " " (map (f: textFiles.${f}) c.files);
        markerLines = lib.concatLines (
          map (m: ''
              n="$(${lib.getExe pkgs.gnugrep} -oF -- '${m}' "$TMPDIR/${c.shell}.txt" | ${lib.getExe' pkgs.coreutils "wc"} -l | ${lib.getExe' pkgs.coreutils "tr"} -d ' ' || true)"
            if [ "$n" -gt 1 ]; then
              echo "FAIL: '${m}' appears $n times across ${c.shell} startup" >&2
              failures=1
            fi
          '')
          c.markers
        );
      in ''
        cat ${catFiles} > "$TMPDIR/${c.shell}.txt"
        ${markerLines}
      ''
    )
    shellChecks
  );

  subdirFailLine = lib.optionalString (bashConfDSubdirs != {}) ''
    echo "FAIL: bash/conf.d subdirectory files are never sourced: ${lib.concatStringsSep ", " (lib.attrNames bashConfDSubdirs)}" >&2
    failures=1
  '';
in
  builtins.seq
  (lib.throwIfNot subsetPass "shell-init-uniqueness: a disabled shell pulled shell integration")
  (
    pkgs.runCommand "shell-init-uniqueness"
    {
      nativeBuildInputs = [
        pkgs.bash
        pkgs.coreutils
        pkgs.gnugrep
      ];
    }
    ''
      set -euo pipefail
      failures=0
      ${checksScript}
      ${subdirFailLine}
      if [ "$failures" -ne 0 ]; then
        exit 1
      fi
      touch "$out"
    ''
  )
