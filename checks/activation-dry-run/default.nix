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

  # Activation entries owned by the terminal/shell modules. Home Manager
  # builtin entries (onFilesChange, copyApps, ...) wrap mutations in the `run`
  # shell function and are out of scope here.
  relevantNames = [
    "createFzfDataDir"
    "createSshControlmastersDir"
    "createStarshipTmpDir"
    "createXdgDirs"
    "createZoxideDataDir"
    "fishDirs"
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
      if ${lib.getExe pkgs.gnugrep} -nE '(^|[;|&[:space:]])[[:space:]]*(mkdir|chmod|mv|rm|ln)[[:space:]]' ${e.file} \
        | ${lib.getExe pkgs.gnugrep} -v '\$DRY_RUN_CMD' \
        | ${lib.getExe pkgs.gnugrep} -q .; then
        echo "FAIL: activation entry ${e.name} mutates without \$DRY_RUN_CMD:" >&2
        ${lib.getExe pkgs.gnugrep} -nE '(^|[;|&[:space:]])[[:space:]]*(mkdir|chmod|mv|rm|ln)[[:space:]]' ${e.file} \
          | ${lib.getExe pkgs.gnugrep} -v '\$DRY_RUN_CMD' || true
        failures=1
      fi
    '')
    writeEntries
  );
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
    if [ "$failures" -ne 0 ]; then
      exit 1
    fi
    touch "$out"
  ''
