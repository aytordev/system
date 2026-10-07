{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "container-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  baseModule = {
    aytordev.user = {
      enable = true;
      name = username;
      email = "container@example.test";
      fullName = "Container User";
      home = homeDirectory;
    };
    home.stateVersion = "25.11";
  };

  mkSuiteHome = modules:
    inputs.self.lib.system.mkHome {
      inherit username;
      system = pkgs.stdenv.hostPlatform.system;
      hostname = "container-runtime";
      inherit modules;
    };

  # Baseline: no development suite, so no container capability is composed.
  suiteOff = mkSuiteHome [baseModule];

  # Podman-only shape: the suite derives the opt-in shim because Docker is off.
  podmanOnly = mkSuiteHome [
    baseModule
    {
      aytordev.suites.development = {
        enable = true;
        podmanEnable = true;
      };
    }
  ];

  # Docker-only shape: the docker capability owns the hyphenated name.
  dockerOnly = mkSuiteHome [
    baseModule
    {aytordev.suites.development.enable = true;}
    {aytordev.programs.terminal.tools.docker.enable = true;}
  ];

  # The civislend shape: both runtimes installed, Docker owns the name.
  bothRuntimes = mkSuiteHome [
    baseModule
    {
      aytordev.suites.development = {
        enable = true;
        podmanEnable = true;
      };
    }
    {
      aytordev.programs.terminal.tools = {
        docker.enable = true;
        colima.enable = true;
      };
    }
  ];

  # Conflict shape: an explicit shim value must beat the suite's mkDefault,
  # so the two-owners guard in the suite has to fire.
  conflict = mkSuiteHome [
    baseModule
    {
      aytordev.suites.development = {
        enable = true;
        podmanEnable = true;
      };
    }
    {
      aytordev.programs.terminal.tools = {
        docker.enable = true;
        podman-compose.dockerComposeShim.enable = true;
      };
    }
  ];

  # Conflict shape: the explicit shim value beats the suite's mkDefault, so
  # the two-owners guard must evaluate false. This home is never built and
  # its `config` cannot be forced at all: Home Manager throws at evaluation
  # time when an assertion fails (fail closed), and the module system forces
  # the merged assertion values even under `options.assertions` introspection.
  # The guard firing is therefore observed as an evaluation throw, caught
  # here with tryEval; the thrown message is the two-owners guard (verified
  # in the negative-control rebuild).
  conflictConfigThrows = !(builtins.tryEval conflict.config.assertions).success;

  # Capability package options must stay replaceable (module contract).
  overriddenPackages = mkSuiteHome [
    baseModule
    {aytordev.suites.development.enable = true;}
    {
      aytordev.programs.terminal.tools = {
        docker = {
          enable = true;
          package = pkgs.hello;
        };
        colima = {
          enable = true;
          package = pkgs.hello;
        };
      };
    }
  ];

  packageNames = home: map (p: p.name or "") home.config.home.packages;
  hasPackage = home: package: lib.elem package.name (packageNames home);

  # Every package publishing a `bin/docker-compose` path has a name starting
  # with "docker-compose": the real compose binary and the Podman shim.
  composeOwners = home: lib.filter (n: lib.hasPrefix "docker-compose" n) (packageNames home);

  tests = [
    # Suite off: no runtime capability composes and no container package
    # reaches home.packages.
    (!suiteOff.config.aytordev.programs.terminal.tools.docker.enable)
    (!suiteOff.config.aytordev.programs.terminal.tools.colima.enable)
    (!suiteOff.config.aytordev.programs.terminal.tools.podman-compose.enable)
    (!suiteOff.config.aytordev.programs.terminal.tools.lazydocker.enable)
    (!(lib.any (n: n == pkgs.docker-client.name) (packageNames suiteOff)))
    (!(lib.any (n: n == pkgs.docker-compose.name) (packageNames suiteOff)))
    (!(lib.any (n: n == pkgs.colima.name) (packageNames suiteOff)))
    (!(lib.any (n: n == pkgs.lazydocker.name) (packageNames suiteOff)))

    # Podman only: the suite's mkDefault enables the shim because Docker is
    # off, so the shim owns the hyphenated name and it is not the real
    # compose binary.
    (!podmanOnly.config.aytordev.programs.terminal.tools.docker.enable)
    podmanOnly.config.aytordev.programs.terminal.tools.podman-compose.enable
    podmanOnly.config.aytordev.programs.terminal.tools.podman-compose.dockerComposeShim.enable
    podmanOnly.config.aytordev.programs.terminal.tools.lazydocker.enable
    (lib.length (composeOwners podmanOnly) == 1)
    ((lib.head (composeOwners podmanOnly)) == "docker-compose")
    ((lib.head (composeOwners podmanOnly)) != pkgs.docker-compose.name)

    # Docker only: the docker capability is on, the suite yields the shim
    # off and podman-compose off, lazydocker stays, and the real compose
    # binary plus the capability package are present.
    dockerOnly.config.aytordev.programs.terminal.tools.docker.enable
    (!dockerOnly.config.aytordev.programs.terminal.tools.podman-compose.enable)
    (!dockerOnly.config.aytordev.programs.terminal.tools.podman-compose.dockerComposeShim.enable)
    dockerOnly.config.aytordev.programs.terminal.tools.lazydocker.enable
    (hasPackage dockerOnly pkgs.docker-compose)
    (hasPackage dockerOnly dockerOnly.config.aytordev.programs.terminal.tools.docker.package)
    (lib.length (composeOwners dockerOnly) == 1)
    ((lib.head (composeOwners dockerOnly)) == pkgs.docker-compose.name)

    # Both runtimes (civislend shape): Docker owns the hyphenated name, the
    # shim stays off, Podman stays installed for `podman compose`, Colima is
    # enabled with its package present, and every home assertion holds.
    (!bothRuntimes.config.aytordev.programs.terminal.tools.podman-compose.dockerComposeShim.enable)
    bothRuntimes.config.aytordev.programs.terminal.tools.lazydocker.enable
    bothRuntimes.config.aytordev.programs.terminal.tools.podman-compose.enable
    bothRuntimes.config.aytordev.programs.terminal.tools.colima.enable
    (hasPackage bothRuntimes pkgs.colima)
    (lib.length (composeOwners bothRuntimes) == 1)
    ((lib.head (composeOwners bothRuntimes)) == pkgs.docker-compose.name)
    (lib.all (a: a.assertion) bothRuntimes.config.assertions)

    # Conflict shape: the explicit shim value beats the suite's mkDefault,
    # so the two-owners guard fires and the home's config evaluation throws.
    conflictConfigThrows

    # Both capability package options stay replaceable.
    (overriddenPackages.config.aytordev.programs.terminal.tools.docker.package == pkgs.hello)
    (overriddenPackages.config.aytordev.programs.terminal.tools.colima.package == pkgs.hello)
    (hasPackage overriddenPackages overriddenPackages.config.aytordev.programs.terminal.tools.docker.package)
    (hasPackage overriddenPackages overriddenPackages.config.aytordev.programs.terminal.tools.colima.package)

    # Decision D3 guard: Home Manager must not manage anything under
    # ~/.docker, because Colima rewrites ~/.docker/config.json on start AND
    # on stop. Do not "fix" the deliberately absent plugin wiring; this
    # assertion exists to catch a future reader reintroducing it.
    (!(lib.any (k: lib.hasPrefix ".docker/" k)
      (builtins.attrNames (lib.attrByPath ["home" "file"] {} bothRuntimes.config))))
  ];

  failedTests =
    lib.filter (name: name != null)
    (lib.imap0 (
        i: ok:
          if !ok
          then "test ${toString i}"
          else null
      )
      tests);
in
  if failedTests == []
  then
    pkgs.runCommand "container-runtime-check" {} ''
      set -euo pipefail

      # Real artifact checks, no daemon and no network: every command below
      # works with the VM stopped, so no container VM is ever started here.
      export HOME="$(mktemp -d)"
      cd "$HOME"

      dockerVersion="$(${pkgs.docker-client}/bin/docker --version)"
      case "$dockerVersion" in
        "Docker version "*) ;;
        *)
          echo "ERROR: unexpected docker --version output: $dockerVersion" >&2
          exit 1
          ;;
      esac

      composeVersion="$(${pkgs.docker-compose}/bin/docker-compose version)"
      case "$composeVersion" in
        "Docker Compose version"*) ;;
        *)
          echo "ERROR: unexpected docker-compose version output: $composeVersion" >&2
          exit 1
          ;;
      esac

      colimaVersion="$(${pkgs.colima}/bin/colima version)"
      case "$colimaVersion" in
        "colima version"*) ;;
        *)
          echo "ERROR: unexpected colima version output: $colimaVersion" >&2
          exit 1
          ;;
      esac

      touch "$out"
    ''
  else throw "container-runtime eval assertions failed: ${lib.concatStringsSep ", " failedTests}"
