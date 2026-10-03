{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "db-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  baseModule = {
    aytordev.user = {
      enable = true;
      name = username;
      email = "db@example.test";
      fullName = "DB User";
      home = homeDirectory;
    };
    home.stateVersion = "25.11";
  };

  mkSuiteHome = modules:
    inputs.self.lib.system.mkHome {
      inherit username;
      system = pkgs.stdenv.hostPlatform.system;
      hostname = "db-tooling";
      inherit modules;
    };

  # Baseline: no database suite, so nothing database-related is composed.
  suiteOff = mkSuiteHome [baseModule];

  # Full composition: CLI clients + rainfrog (TUI) + DbGate (GUI).
  suiteOn = mkSuiteHome [
    baseModule
    {aytordev.suites.databases.enable = true;}
  ];

  # GUI/TUI opt-outs must not remove the suite-owned CLI toolchain.
  suiteGuiTuiOff = mkSuiteHome [
    baseModule
    {aytordev.suites.databases.enable = true;}
    {
      aytordev.programs.terminal.tools.rainfrog.enable = false;
      aytordev.programs.desktop.databases.dbgate.enable = false;
    }
  ];

  # Each opt-out must also work on its own: the disabled convenience
  # capability disappears while the other one and the CLI toolchain stay.
  suiteTuiOff = mkSuiteHome [
    baseModule
    {aytordev.suites.databases.enable = true;}
    {aytordev.programs.terminal.tools.rainfrog.enable = false;}
  ];
  suiteGuiOff = mkSuiteHome [
    baseModule
    {aytordev.suites.databases.enable = true;}
    {aytordev.programs.desktop.databases.dbgate.enable = false;}
  ];

  # Capability package options must stay replaceable.
  overriddenPackages = mkSuiteHome [
    baseModule
    {aytordev.suites.databases.enable = true;}
    {
      aytordev.programs.terminal.tools.rainfrog.package = pkgs.hello;
      aytordev.programs.desktop.databases.dbgate.package = pkgs.hello;
    }
  ];

  projectName = "database-client-toolchain";
  clientEnvOf = home:
    lib.findFirst (p: (p.name or "") == projectName) null home.config.home.packages;

  clientEnv = let
    found = clientEnvOf suiteOn;
  in
    if found == null
    then throw "the database suite must install the projected client toolchain"
    else found;

  cliGuiTuiTests = [
    # Suite off: no capabilities composed, no client toolchain, no packages.
    (!suiteOff.config.aytordev.suites.databases.enable)
    (!suiteOff.config.aytordev.programs.terminal.tools.rainfrog.enable)
    (!suiteOff.config.aytordev.programs.desktop.databases.dbgate.enable)
    (clientEnvOf suiteOff == null)
    (!(lib.any (p: (p.name or "") == pkgs.rainfrog.name) suiteOff.config.home.packages))
    (!(lib.any (p: (p.name or "") == pkgs.dbgate.name) suiteOff.config.home.packages))

    # Suite on: both convenience capabilities compose with mkDefault.
    suiteOn.config.aytordev.programs.terminal.tools.rainfrog.enable
    suiteOn.config.aytordev.programs.desktop.databases.dbgate.enable
    (suiteOn.config.aytordev.programs.terminal.tools.rainfrog.package == pkgs.rainfrog)
    (suiteOn.config.aytordev.programs.desktop.databases.dbgate.package == pkgs.dbgate)
    (lib.any (p: (p.name or "") == pkgs.rainfrog.name) suiteOn.config.home.packages)
    (lib.any (p: (p.name or "") == pkgs.dbgate.name) suiteOn.config.home.packages)

    # CLI clients are owned by the suite, independent of GUI/TUI flags.
    (clientEnvOf suiteGuiTuiOff == clientEnv)
    (!(lib.any (p: (p.name or "") == pkgs.rainfrog.name) suiteGuiTuiOff.config.home.packages))
    (!(lib.any (p: (p.name or "") == pkgs.dbgate.name) suiteGuiTuiOff.config.home.packages))

    # TUI-only opt-out: rainfrog absent, DbGate and the CLI toolchain kept.
    (!suiteTuiOff.config.aytordev.programs.terminal.tools.rainfrog.enable)
    suiteTuiOff.config.aytordev.programs.desktop.databases.dbgate.enable
    (suiteTuiOff.config.aytordev.programs.desktop.databases.dbgate.package == pkgs.dbgate)
    (!(lib.any (p: (p.name or "") == pkgs.rainfrog.name) suiteTuiOff.config.home.packages))
    (lib.any (p: (p.name or "") == pkgs.dbgate.name) suiteTuiOff.config.home.packages)
    (clientEnvOf suiteTuiOff == clientEnv)

    # GUI-only opt-out: DbGate absent, rainfrog and the CLI toolchain kept.
    (!suiteGuiOff.config.aytordev.programs.desktop.databases.dbgate.enable)
    suiteGuiOff.config.aytordev.programs.terminal.tools.rainfrog.enable
    (suiteGuiOff.config.aytordev.programs.terminal.tools.rainfrog.package == pkgs.rainfrog)
    (!(lib.any (p: (p.name or "") == pkgs.dbgate.name) suiteGuiOff.config.home.packages))
    (lib.any (p: (p.name or "") == pkgs.rainfrog.name) suiteGuiOff.config.home.packages)
    (clientEnvOf suiteGuiOff == clientEnv)

    # Both capabilities expose replaceable package options.
    (overriddenPackages.config.aytordev.programs.terminal.tools.rainfrog.package == pkgs.hello)
    (overriddenPackages.config.aytordev.programs.desktop.databases.dbgate.package == pkgs.hello)
    (lib.any (p: (p.name or "") == pkgs.hello.name) overriddenPackages.config.home.packages)
  ];

  dbServiceName = n:
    lib.match ".*(postgres|mysql|maria|redis|mongo).*" n != null;
  serviceNames = home:
    (builtins.filter dbServiceName (builtins.attrNames (lib.attrByPath ["launchd" "agents"] {} home.config)))
    ++ (builtins.filter dbServiceName (builtins.attrNames (lib.attrByPath ["systemd" "user" "services"] {} home.config)));
  serviceTests = [
    # No database daemon or user service is enabled by the suite.
    (serviceNames suiteOn == [])
    (serviceNames suiteGuiTuiOff == [])
  ];

  tests = cliGuiTuiTests ++ serviceTests;
  failedTests =
    lib.filter (name: name != null)
    (lib.imap0 (
        i: ok:
          if !ok
          then "test ${toString i}"
          else null
      )
      tests);

  expectedClients = [
    "psql"
    "pg_dump"
    "pg_restore"
    "mysql"
    "mysqldump"
    "sqlite3"
    "duckdb"
    "redis-cli"
    "mongosh"
  ];
  forbiddenServerCommands = [
    "postgres"
    "initdb"
    "pg_ctl"
    "mysqld"
    "mariadbd"
    "mysql_install_db"
    "redis-server"
    "redis-sentinel"
  ];
in
  if failedTests == []
  then
    pkgs.runCommand "database-tooling-check" {
      nativeBuildInputs =
        [pkgs.file]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [pkgs.darwin.cctools];
    } ''
      set -euo pipefail

      # The projected toolchain must contain exactly the requested clients.
      expected="$(printf '%s\n' ${lib.escapeShellArgs expectedClients} | sort)"
      actual="$(ls ${clientEnv}/bin | sort)"
      if [ "$actual" != "$expected" ]; then
        echo "ERROR: projected client toolchain mismatch" >&2
        diff <(echo "$expected") <(echo "$actual") >&2 || true
        exit 1
      fi

      # Server commands must be absent from the user-facing projection.
      for server in ${lib.escapeShellArgs forbiddenServerCommands}; do
        if [ -e "${clientEnv}/bin/$server" ]; then
          echo "ERROR: server command present in projection: $server" >&2
          exit 1
        fi
      done

      # Real version checks in an isolated HOME; none of these commands
      # connects to a database.
      export HOME="$(mktemp -d)"
      cd "$HOME"
      ${clientEnv}/bin/psql --version
      ${clientEnv}/bin/pg_dump --version
      ${clientEnv}/bin/pg_restore --version
      ${clientEnv}/bin/mysql --version
      ${clientEnv}/bin/mysqldump --version
      ${clientEnv}/bin/sqlite3 --version
      ${clientEnv}/bin/duckdb --version
      ${clientEnv}/bin/redis-cli --version
      ${clientEnv}/bin/mongosh --version
      ${pkgs.rainfrog}/bin/rainfrog --version

      ${
        lib.optionalString pkgs.stdenv.hostPlatform.isDarwin
        ''
          # DbGate macOS bundle: metadata inspection only, never a GUI launch.
          app="$(echo ${pkgs.dbgate}/Applications/*.app)"
          plist="$app/Contents/Info.plist"
          test -f "$plist"
          version="$(grep -A1 'CFBundleShortVersionString' "$plist" | grep -o '[0-9][0-9.]*' | head -n 1)"
          if [ "$version" != "${pkgs.dbgate.version}" ]; then
            echo "ERROR: DbGate bundle version $version != package ${pkgs.dbgate.version}" >&2
            exit 1
          fi
          binary="$(find "$app/Contents/MacOS" -maxdepth 1 -type f | head -n 1)"
          lipo -info "$binary" | grep -q arm64
          file "$binary" | grep -q arm64
        ''
      }

      touch "$out"
    ''
  else throw "database-tooling eval assertions failed: ${lib.concatStringsSep ", " failedTests}"
