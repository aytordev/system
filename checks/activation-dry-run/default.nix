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
      {
        aytordev.programs.desktop.security.bitwarden = {
          enable = true;
          installPackage = false;
        };
      }
    ];
  };
  inherit (home) config;

  # Activation entries owned by the terminal/shell modules and by the desktop
  # security modules. Home Manager builtin entries (onFilesChange, copyApps, ...)
  # wrap mutations in the `run` shell function and are out of scope here.
  relevantNames = [
    "bitwardenStateFile"
    "createFzfDataDir"
    "createSshControlmastersDir"
    "createStarshipTmpDir"
    "createXdgDirs"
    "createZoxideDataDir"
    "fishDirs"
    "piThemeDefault"
    "zshDir"
    "zshSessionDir"
  ];

  # Every activation entry's script text. Mutation commands must be wrapped in
  # $DRY_RUN_CMD so `home-manager check` (dry run) does not write to the live
  # HOME.
  writeEntries = lib.mapAttrsToList (name: v: {
    inherit name;
    file = pkgs.writeText "activation-${name}" v.data;
  }) (lib.filterAttrs (name: _: lib.elem name relevantNames) config.home.activation);

  entryChecks = lib.concatLines (
    map (e: ''
      if ${lib.getExe pkgs.gnugrep} -nE '(^|[;|&[:space:]])[[:space:]]*(mkdir|chmod|mv|rm|ln|install)[[:space:]]' ${e.file} \
        | ${lib.getExe pkgs.gnugrep} -v '\$DRY_RUN_CMD' \
        | ${lib.getExe pkgs.gnugrep} -q .; then
        echo "FAIL: activation entry ${e.name} mutates without \$DRY_RUN_CMD:" >&2
        ${lib.getExe pkgs.gnugrep} -nE '(^|[;|&[:space:]])[[:space:]]*(mkdir|chmod|mv|rm|ln|install)[[:space:]]' ${e.file} \
          | ${lib.getExe pkgs.gnugrep} -v '\$DRY_RUN_CMD' || true
        failures=1
      fi
    '')
    writeEntries
  );

  # Darwin's shell-tool layout is split and cannot be inferred from Linux
  # habit: `ln`, `echo`, `rm`, `mkdir`, `bash` and `sh` live in /bin, while
  # `readlink`, `arch`, `true`, `env`, `find`, `touch` and `sw_vers` live in
  # /usr/bin and `softwareupdate` in /usr/sbin; `/bin/readlink` and
  # `/usr/bin/ln` do not exist at all. Every entry was probed on a real macOS
  # host (macOS 27.0.0). This is an allow-list of *vetted* paths, not a census
  # of everything Darwin ships: a path missing here is merely unverified, so
  # the diagnostic tells the reader to probe, repair, or extend it.
  vettedDarwinTools = [
    "/bin/bash"
    "/bin/echo"
    "/bin/launchctl"
    "/bin/ln"
    "/bin/sh"
    "/usr/bin/arch"
    "/usr/bin/env"
    "/usr/bin/find"
    "/usr/bin/hidutil"
    "/usr/bin/readlink"
    "/usr/bin/sw_vers"
    "/usr/bin/tccutil"
    "/usr/bin/touch"
    "/usr/bin/true"
    "/usr/sbin/softwareupdate"
  ];

  # Absolute tool paths recovered from a fragment by a token scanner, not a
  # shell parser: common shell punctuation (both quote kinds, backticks,
  # command substitution, redirection, separators, commas) is replaced with
  # spaces, and whitespace tokens matching /bin, /sbin, /usr/bin or /usr/sbin
  # are kept. Forms outside that punctuation set (e.g. a path held in a
  # variable) are not extracted; the self-test pins the quoting forms this
  # repository actually uses. `checks/container-runtime` mirrors this
  # extraction to translate the same paths for its sandbox.
  toolPathTokens = text:
    lib.unique (lib.filter (token: builtins.match "/(usr/)?s?bin/[A-Za-z0-9._-]+" token != null)
      (lib.splitString " " (lib.replaceStrings ["\n" "\t" "\"" "'" "`" "(" ")" "$" ";" "|" "&" "," "<" ">"] (lib.genList (_: " ") 14) text)));

  unvettedToolPaths = text: lib.subtractLists vettedDarwinTools (toolPathTokens text);

  # Minimal nix-darwin surface for standalone evaluation: this check runs on
  # both platforms and `system` does not exist outside nix-darwin.
  darwinStub = {
    options = {
      assertions = lib.mkOption {type = lib.types.listOf lib.types.unspecified;};
      nix.extraOptions = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
      system.activationScripts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.text = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
        });
        default = {};
      };
    };
  };

  # Darwin system fragments this repository authors.
  darwinFragmentSources = [
    {
      name = "docker-socket/postActivation";
      module = ../../modules/darwin/services/docker-socket;
      settings = {
        aytordev.services.docker-socket = {
          enable = true;
          targetPath = "/Users/${username}/.config/colima/default/docker.sock";
        };
      };
    }
    {
      name = "rosetta";
      module = ../../modules/darwin/system/rosetta;
      settings = {aytordev.system.rosetta.enable = true;};
    }
  ];

  # Maintained scope, stated plainly: the Darwin-intended system fragments in
  # `darwinFragmentSources` are vetted against the Darwin allow-list on every
  # platform that builds this check. Home Manager activation entries are
  # cross-platform text, so they are vetted against the Darwin list only on
  # Darwin builds — no Darwin fact is applied to Linux command paths. Launchd
  # program paths and nix-darwin's own upstream activate body are out of
  # scope, and the Darwin sources are enumerated explicitly, not discovered
  # repo-wide: adding an activation fragment means adding it here.
  # Upstream Home Manager entries are vetted on purpose: the list is per path,
  # so a path from any author needs one human verification on a real host
  # instead of a silent switch-time abort.
  homeActivationSurfaces =
    lib.optionals pkgs.stdenv.hostPlatform.isDarwin
    (lib.mapAttrsToList (name: entry: {
        inherit name;
        text = entry.data;
      })
      config.home.activation);

  activationSurfaces =
    (map (source: {
        inherit (source) name;
        text = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (_: entry: entry.text)
          (lib.filterAttrs (_: entry: entry.text != "")
            (lib.evalModules {
              modules = [source.module darwinStub source.settings];
            }).config.system.activationScripts)
        );
      })
      darwinFragmentSources)
    ++ homeActivationSurfaces;

  offenders = map (surface: {
    inherit (surface) name;
    paths = unvettedToolPaths surface.text;
  }) (lib.filter (surface: unvettedToolPaths surface.text != []) activationSurfaces);

  # Non-vacuity. The predicate must reject the exact path that aborted a real
  # switch and accept its repair, or this contract is decorative: the previous
  # check never failed because it translated Darwin paths into portable ones
  # before looking at them.
  selfTestPassed =
    (unvettedToolPaths "/bin/echo x; /usr/bin/ln -sfn a b" == ["/usr/bin/ln"])
    && (unvettedToolPaths "/bin/ln -sfn \"$target\" \"$socket\"" == [])
    && (unvettedToolPaths "'/usr/bin/ln' -s a b" == ["/usr/bin/ln"])
    && (unvettedToolPaths "'/bin/ln' -s a b" == [])
    && (unvettedToolPaths "/usr/bin/env, /usr/bin/ln" == ["/usr/bin/ln"]);

  toolPathChecks =
    (lib.concatMapStrings (offender: ''
        echo "FAIL: ${offender.name} calls tool path(s) outside the vetted Darwin tool list: ${lib.concatStringsSep " " offender.paths}" >&2
        echo "      Unvetted does not mean nonexistent: probe each path on a real macOS host, then repair the fragment or add the verified path to vettedDarwinTools." >&2
        failures=1
      '')
      offenders)
    + (lib.optionalString (!selfTestPassed) ''
      echo "FAIL: the Darwin tool-path predicate is vacuous: it accepted /usr/bin/ln or rejected /bin/ln, so it cannot be trusted to fail." >&2
      failures=1
    '');
in
  pkgs.runCommand "activation-dry-run"
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
    ${entryChecks}
    ${toolPathChecks}
    if [ "$failures" -ne 0 ]; then
      exit 1
    fi
    touch "$out"
  ''
