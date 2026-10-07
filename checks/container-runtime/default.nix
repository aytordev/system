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

  # T8b: the privileged activation fragment shipped in T6 must actually run
  # somewhere. The adapter module is evaluated standalone with
  # `lib.evalModules`, stubbing only the `system.activationScripts` surface it
  # writes to, and given concrete sandbox paths through
  # `builtins.placeholder "out"` so the generated text operates inside this
  # check's build directory.
  adapterModules = [
    ../../modules/darwin/services/docker-socket
    {
      options.system.activationScripts = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
      };
    }
  ];

  adapterFor = socketName:
    lib.evalModules {
      modules =
        adapterModules
        ++ [
          {
            aytordev.services.docker-socket = {
              enable = true;
              socketPath = "${builtins.placeholder "out"}/${socketName}";
              targetPath = "${builtins.placeholder "out"}/provider.sock";
            };
          }
        ];
    };
  socketAdapter = adapterFor "docker.sock";
  activationFragment = socketAdapter.config.system.activationScripts.docker-socket.text;

  # The fragment calls Darwin's absolute activation-time tool paths
  # (`/usr/bin/readlink`, `/bin/echo`, `/usr/bin/ln`). The symlink state
  # machine under test is platform-independent and the sandbox provides the
  # same tools through coreutils on PATH, so the prefixes are rewritten to
  # plain lookups and the identical logic executes on every platform this
  # check builds on.
  sandboxedActivationFragment =
    lib.replaceStrings
    ["/usr/bin/readlink" "/bin/echo" "/usr/bin/ln"]
    ["readlink" "echo" "ln"]
    activationFragment;

  # Option contract: `targetPath` must have no default, because a derived
  # default would be user-relative and would force user identity during
  # option evaluation. The declaration must not carry one and evaluation must
  # demand one.
  adapterOptionTree = socketAdapter.options.aytordev.services.docker-socket;

  missingTargetPathThrows =
    !(builtins.tryEval
      (lib.evalModules {
        modules =
          adapterModules
          ++ [
            {
              aytordev.services.docker-socket = {
                enable = true;
                socketPath = "${builtins.placeholder "out"}/docker.sock";
              };
            }
          ];
      })
      .config
      .system
      .activationScripts
      .docker-socket
      .text).success;

  # With `enable = false` the adapter must contribute nothing.
  disabledAdapter = lib.evalModules {
    modules =
      adapterModules
      ++ [{aytordev.services.docker-socket.enable = false;}];
  };

  # The Darwin development suite's evaluation-time conflict guard (D7): the
  # pair "Docker Desktop cask + docker-socket adapter" must produce a false
  # assertion. The suite is evaluated standalone with minimal stubs for the
  # option surface it touches, so the guard is observed without building any
  # Darwin system. The guard reads only the adapter's `enable`, so the
  # required `targetPath` stays unset and inert here.
  darwinSuiteEval = suiteConfig:
    lib.evalModules {
      modules =
        [
          ../../modules/darwin/suites/development
          ../../modules/darwin/services/docker-socket
          {
            options = {
              assertions = lib.mkOption {type = lib.types.listOf lib.types.unspecified;};
              system.activationScripts = lib.mkOption {type = lib.types.attrsOf lib.types.anything;};
              homebrew.casks = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
              };
              homebrew.masApps = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
              };
              environment.systemPackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
              };
              nix.settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
              };
              aytordev.tools.homebrew.masEnable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
            };
          }
          {_module.args.pkgs = pkgs;}
        ]
        ++ [suiteConfig];
    };

  darwinSuiteConflictFires = suiteConfig:
    lib.any (assertion: !assertion.assertion) (darwinSuiteEval suiteConfig).config.assertions;

  darwinSuiteConflict = {
    aytordev.suites.development = {
      enable = true;
      dockerDesktopEnable = true;
    };
    aytordev.services.docker-socket.enable = true;
  };
  darwinSuiteDesktopOnly = {
    aytordev.suites.development = {
      enable = true;
      dockerDesktopEnable = true;
    };
  };
  darwinSuiteAdapterOnly = {
    aytordev.suites.development.enable = true;
    aytordev.services.docker-socket.enable = true;
  };

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

    # T8b: the docker-socket option contracts. `targetPath` must not carry a
    # default, must be demanded at evaluation time, and a disabled adapter
    # must contribute nothing to `system.activationScripts`.
    (!(adapterOptionTree.targetPath ? default))
    missingTargetPathThrows
    (!(disabledAdapter.config.system.activationScripts ? docker-socket))

    # T8b: the Darwin development suite's evaluation-time conflict guard
    # fires only when the Docker Desktop cask and the adapter are both
    # enabled; each one alone stays clean.
    (darwinSuiteConflictFires darwinSuiteConflict)
    (!(darwinSuiteConflictFires darwinSuiteDesktopOnly))
    (!(darwinSuiteConflictFires darwinSuiteAdapterOnly))

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

            # T8b: execute the privileged activation fragment from
            # aytordev.services.docker-socket against real filesystem states inside
            # $out. The generated text calls Darwin's absolute activation-time tool
            # paths, rewritten to PATH lookups in `sandboxedActivationFragment`, so
            # the identical symlink logic runs in the sandbox on every platform
            # this check builds on. `set -e` is active, so a non-zero fragment exit
            # aborts this check: refusing is the fail-closed action (D7), and
            # aborting a whole system switch is exactly the behaviour D7 rejects,
            # which is why the foreign-owner cases must exit zero. Nix does
            # not pre-create the output path, but the fragment publishes
            # under it, so it must exist before the first run.
            mkdir -p "$out"

            socketAdapterActivation() {
      ${sandboxedActivationFragment}
            }

            # 1. Create: nothing exists at the socket path, so the fragment must
            #    publish the provider symlink. The target deliberately does not
            #    exist (the provider VM is normally stopped): a dangling symlink is
            #    the accepted steady state.
            createOutput="$(socketAdapterActivation)"
            [ -L "$out/docker.sock" ] || {
              echo "ERROR: activation fragment did not create a symlink at $out/docker.sock" >&2
              exit 1
            }
            [ "$(readlink "$out/docker.sock")" = "$out/provider.sock" ] || {
              echo "ERROR: activation fragment published the wrong link target: $(readlink "$out/docker.sock")" >&2
              exit 1
            }
            [ -z "$createOutput" ] || {
              echo "ERROR: activation fragment printed output while creating the link: $createOutput" >&2
              exit 1
            }

            # 2. Idempotent no-op: a second run must keep the link unchanged, stay
            #    silent and exit zero.
            if ! idempotentOutput="$(socketAdapterActivation)"; then
              echo "ERROR: activation fragment exited non-zero on the idempotent second run" >&2
              exit 1
            fi
            [ "$(readlink "$out/docker.sock")" = "$out/provider.sock" ] || {
              echo "ERROR: idempotent second run changed the link target" >&2
              exit 1
            }
            [ -z "$idempotentOutput" ] || {
              echo "ERROR: idempotent second run printed output: $idempotentOutput" >&2
              exit 1
            }

            # 3a. Foreign symlink owner: the fragment must refuse, leave the entry
            #     untouched, name the current owner and the remediation, and exit
            #     zero.
            rm "$out/docker.sock"
            foreignTarget="/var/run/some-other-provider.sock"
            ln -s "$foreignTarget" "$out/docker.sock"
            if ! foreignSymlinkOutput="$(socketAdapterActivation)"; then
              echo "ERROR: activation fragment exited non-zero on a foreign symlink; aborting the whole switch is the behaviour D7 rejects" >&2
              exit 1
            fi
            [ "$(readlink "$out/docker.sock")" = "$foreignTarget" ] || {
              echo "ERROR: activation fragment replaced a foreign symlink it does not own" >&2
              exit 1
            }
            case "$foreignSymlinkOutput" in
              *"refusing to replace $out/docker.sock"*) ;;
              *)
                echo "ERROR: foreign-symlink run did not report the refusing decision: $foreignSymlinkOutput" >&2
                exit 1
                ;;
            esac
            case "$foreignSymlinkOutput" in
              *"$foreignTarget"*"Remove the existing entry"*) ;;
              *)
                echo "ERROR: foreign-symlink run did not name the current owner and the remediation: $foreignSymlinkOutput" >&2
                exit 1
                ;;
            esac

            # 3b. Regular file owner: same refusal contract, and the file must
            #     survive with its content intact.
            rm "$out/docker.sock"
            printf 'deliberately not a socket\n' > "$out/docker.sock"
            if ! regularFileOutput="$(socketAdapterActivation)"; then
              echo "ERROR: activation fragment exited non-zero on a regular-file owner; aborting the whole switch is the behaviour D7 rejects" >&2
              exit 1
            fi
            [ -f "$out/docker.sock" ] || {
              echo "ERROR: activation fragment removed the regular file it refuses to own" >&2
              exit 1
            }
            [ ! -L "$out/docker.sock" ] || {
              echo "ERROR: activation fragment replaced a regular file with a symlink" >&2
              exit 1
            }
            [ "$(cat "$out/docker.sock")" = "deliberately not a socket" ] || {
              echo "ERROR: activation fragment modified the regular file it refuses to own" >&2
              exit 1
            }
            case "$regularFileOutput" in
              *"non-symlink entry"*"Remove the existing entry"*) ;;
              *)
                echo "ERROR: regular-file run did not name the current owner and the remediation: $regularFileOutput" >&2
                exit 1
                ;;
            esac

            touch "$out"
    ''
  else throw "container-runtime eval assertions failed: ${lib.concatStringsSep ", " failedTests}"
