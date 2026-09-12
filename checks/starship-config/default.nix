# Guard the generated `starship.toml` against format-syntax regressions.
#
# Nix evaluation and the unit tests validate the resolved settings as data, but
# the starship format parser only reports an invalid `format` string at runtime
# (as a warning that leaves a broken module in the prompt). Render the config the
# adapter produces for each theme family and feed it to the real `starship`
# binary over a probe tree that triggers the language modules.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "starship-check";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  mkHome = {
    theme,
    variant,
  }:
    inputs.self.lib.system.mkHome {
      inherit username;
      system = pkgs.stdenv.hostPlatform.system;
      hostname = "starship-check-host";
      modules = [
        {
          aytordev.user = {
            enable = true;
            name = username;
            email = "starship@example.test";
            fullName = "Starship Check";
            home = homeDirectory;
          };
          home.stateVersion = "25.11";
        }
        {aytordev.suites.common.enable = true;}
        {
          aytordev.theme = {
            name = theme;
            inherit variant;
          };
        }
      ];
    };

  # The same TOML generator Home Manager uses for the starship config.
  renderConfig = home: (pkgs.formats.toml {}).generate "starship.toml" home.config.programs.starship.settings;

  # One config per resolution path: official with a style overlay (sora),
  # official palette-only (catppuccin), and generated (kanagawa).
  configs = {
    sora = renderConfig (mkHome {
      theme = "sora";
      variant = "dark";
    });
    catppuccin = renderConfig (mkHome {
      theme = "catppuccin";
      variant = "mocha";
    });
    kanagawa = renderConfig (mkHome {
      theme = "kanagawa";
      variant = "dragon";
    });
  };

  checkCalls = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: cfg: "check ${name} ${cfg}") configs
  );
in
  pkgs.runCommand "starship-config-check"
  {
    nativeBuildInputs = [
      pkgs.starship
      pkgs.gnugrep
    ];
  }
  ''
    set -euo pipefail
    export HOME="$PWD"
    export XDG_CACHE_HOME="$PWD/.cache"

    # Probe tree that makes starship detect each language module.
    mkdir -p probe
    touch probe/package.json probe/Cargo.toml probe/go.mod probe/requirements.txt \
      probe/composer.json probe/Gemfile probe/build.zig probe/Package.swift \
      probe/pom.xml probe/main.c probe/main.lua probe/deno.json probe/bunfig.toml

    check() {
      name="$1"
      cfg="$2"
      echo "checking starship config: $name"
      STARSHIP_CONFIG="$cfg" starship prompt --path "$PWD/probe" >/dev/null 2>starship.err
      if grep -qiE 'WARN|ERROR' starship.err; then
        echo "starship rejected the $name config:"
        cat starship.err
        exit 1
      fi
    }

    ${checkCalls}

    touch "$out"
  ''
