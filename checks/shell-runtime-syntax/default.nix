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

  cfgText = v: v.text or (builtins.readFile v.source);
  bashConfD = lib.concatStringsSep "\n" (
    map cfgText (
      lib.attrValues (lib.filterAttrs (name: _: lib.hasPrefix "bash/conf.d/" name) config.xdg.configFile)
    )
  );

  nuConfigDir = config.programs.nushell.configDir;
  nuConfig = config.home.file."${nuConfigDir}/config.nu".text or config.programs.nushell.extraConfig;
  nuEnv = config.home.file."${nuConfigDir}/env.nu".text or config.programs.nushell.envFile.text or "";

  # home.shellAliases fans out to every shell; nushell renders values verbatim.
  # A ';' splits into a bare command executed at config.nu load; '$(' and
  # 'command ' are Nu-syntax hazards; and a '|'/'&&'/'||' or a newline is either
  # a parse error or a silent no-op (pipes are passed as a single arg). These
  # values must never reach nushell.
  nuAliasValues = lib.attrValues config.programs.nushell.shellAliases;
  unsafeNushellAliases =
    builtins.filter (
      v:
        lib.hasInfix ";" v
        || lib.hasInfix "$(" v
        || lib.hasPrefix "command " v
        || lib.hasInfix "|" v
        || lib.hasInfix "&&" v
        || lib.hasInfix "||" v
        || lib.hasInfix "\n" v
    )
    nuAliasValues;

  banshellAliasesFail =
    lib.throwIf (unsafeNushellAliases != [])
    "Nushell receives unsafe shell alias bodies: ${lib.concatStringsSep "; " unsafeNushellAliases}"
    "shell-runtime-syntax";

  bashText = ''
    ${config.programs.bash.profileExtra}
    ${config.programs.bash.initExtra}
    ${config.programs.bash.bashrcExtra}
    ${bashConfD}
  '';
  zshText = ''
    ${config.programs.zsh.envExtra}
    ${config.programs.zsh.initContent}
  '';
  fishText = ''
    ${config.programs.fish.shellInit}
    ${config.programs.fish.interactiveShellInit}
  '';

  bashFile = pkgs.writeText "shell-bashrc" bashText;
  zshFile = pkgs.writeText "shell-zshrc" zshText;
  fishFile = pkgs.writeText "shell-fish" fishText;
  nuConfigFile = pkgs.writeText "shell-config.nu" nuConfig;
  nuEnvFile = pkgs.writeText "shell-env.nu" nuEnv;
in
  pkgs.runCommand "shell-runtime-syntax"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.fish
      pkgs.gnugrep
      pkgs.nushell
      pkgs.zsh
    ];
  }
  ''
    set -euo pipefail
    failures=0
    : ${banshellAliasesFail}

    check() {
      if ! "$@"; then
        echo "FAIL: $*" >&2
        failures=1
      fi
    }

    check ${lib.getExe pkgs.bash} -n ${bashFile}
    check ${lib.getExe pkgs.zsh} -n ${zshFile}
    check ${lib.getExe pkgs.fish} --no-execute ${fishFile}

    # Nushell has no parse-only flag; --ide-check runs a diagnostic pass
    # without executing the file. config.nu must never be executed here: a
    # `;` inside a home.shellAliases value splits into a bare command that
    # runs at load time (e.g. `nix-collect-garbage -d`).
    check_nu_syntax() {
      local file="$1"
      if ${lib.getExe pkgs.nushell} --ide-check 100 "$file" 2>&1 \
        | ${lib.getExe pkgs.gnugrep} -q '"severity":"Error"'; then
        echo "FAIL: nushell syntax error in $file" >&2
        failures=1
      fi
    }

    check_nu_syntax ${nuEnvFile}
    check_nu_syntax ${nuConfigFile}

    if [ "$failures" -ne 0 ]; then
      echo "Shell runtime syntax check failed" >&2
      exit 1
    fi
    touch "$out"
  ''
