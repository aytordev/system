{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.starship;
  themes = {
    catppuccin-frappe = import ./themes/catppuccin-frappe.nix {inherit lib;};
    catppuccin-latte = import ./themes/catppuccin-latte.nix {inherit lib;};
    catppuccin-macchiato = import ./themes/catppuccin-macchiato.nix {inherit lib;};
    catppuccin-mocha = import ./themes/catppuccin-mocha.nix {inherit lib;};
  };
  osModule = import ./modules/os.nix {inherit lib;};
  gitModule = import ./modules/git.nix {inherit lib;};
  languagesModule = import ./modules/languages.nix {inherit lib;};
  shellModule = import ./modules/shell-module.nix {inherit lib;};
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
  starshipConfigDir = "${xdgConfigHome}/starship";
  starshipConfigFile = "${starshipConfigDir}/config.toml";
  starshipCacheDir = "${xdgCacheHome}/starship";
  baseConfig = {
    "$schema" = "https://starship.rs/config-schema.json";
    format =
      ''
        [╭](bold overlay1)''
      + "$os"
      + ''
      ''
      + "$username"
      + ''
      ''
      + "$directory"
      + ''
      ''
      + "$git_branch"
      + ''
      ''
      + "$git_status"
      + ''
      ''
      + "$c"
      + ''
      ''
      + "$rust"
      + ''
      ''
      + "$golang"
      + ''
      ''
      + "$nodejs"
      + ''
      ''
      + "$php"
      + ''
      ''
      + "$java"
      + ''
      ''
      + "$kotlin"
      + ''
      ''
      + "$haskell"
      + ''
      ''
      + "$python"
      + ''
      ''
      + "$lua"
      + ''
      ''
      + "$docker_context"
      + ''
      ''
      + "$line_break"
      + "$character"
      + ''
      '';
  };
  mergedConfig = lib.foldl lib.recursiveUpdate {} [
    baseConfig
    (themes.${cfg.theme} or themes.catppuccin-frappe)
    osModule
    gitModule
    languagesModule
    shellModule
  ];
in {
  options.applications.terminal.tools.starship = {
    enable = mkEnableOption "Starship prompt";
    theme = mkOption {
      type = types.enum ["catppuccin-frappe" "catppuccin-latte" "catppuccin-macchiato" "catppuccin-mocha"];
      default = "catppuccin-frappe";
      description = "Color theme to use for Starship prompt";
    };
    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with ZSH";
    };
    enableFishIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with Fish shell";
    };
    enableBashIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with Bash";
    };
    enableNushellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with Nushell";
    };
    settings = mkOption {
      type = types.attrs;
      default = mergedConfig;
      description = "Starship configuration options";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        (pkgs.writeShellScriptBin "starship" ''
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          unset STARSHIP_LOG
          unset STARSHIP_CACHE
          export TMPDIR="${config.xdg.cacheHome}/starship-tmp"
          mkdir -p "$TMPDIR"
          chmod 700 "$TMPDIR"
          exec ${pkgs.starship}/bin/starship "$@"
        '')
      ];
      xdg.configFile = {
        "starship/config.toml".source = (pkgs.formats.toml {}).generate "starship-config" cfg.settings;
        "starship/modules".source = lib.mkForce (pkgs.runCommand "starship-modules-dir" {} ''
          mkdir -p $out
        '');
      };
      home.activation.createStarshipTmpDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/starship-tmp"
        $DRY_RUN_CMD chmod 700 "${config.xdg.cacheHome}/starship-tmp"
      '';
    }
    (mkIf (cfg.enable && cfg.enableZshIntegration) {
      programs.zsh.initContent = ''
        if [ -n "$commands[starship]" ]; then
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          export STARSHIP_CACHE="${xdgCacheHome}/starship"
          for dir in "$STARSHIP_CACHE" "$STARSHIP_CONFIG_DIR/modules"; do
            if [ ! -d "$dir" ]; then
              mkdir -p "$dir"
            fi
          done
          eval "$(${pkgs.starship}/bin/starship init zsh --print-full-init)"
        fi
      '';
    })
    (mkIf (cfg.enable && cfg.enableFishIntegration) {
      programs.fish.interactiveShellInit = ''
        if command -q starship
          set -gx STARSHIP_CONFIG "${starshipConfigFile}"
          set -gx STARSHIP_CONFIG_DIR "${starshipConfigDir}"
          set -gx STARSHIP_CACHE "${xdgCacheHome}/starship"
          for dir in $STARSHIP_CACHE "$STARSHIP_CONFIG_DIR/modules"
            if not test -d "$dir"
              mkdir -p "$dir"
            end
          end
          ${pkgs.starship}/bin/starship init fish | source
        end
      '';
    })
    (mkIf (cfg.enable && cfg.enableNushellIntegration) {
      programs.nushell.extraConfig = ''
        $env.STARSHIP_CONFIG = "${starshipConfigFile}"
        $env.STARSHIP_CONFIG_DIR = "${starshipConfigDir}"
        $env.STARSHIP_CACHE = "${xdgCacheHome}/starship"
        if ("XDG_CACHE_HOME" not-in $env) {
            $env.XDG_CACHE_HOME = (["$env.HOME" ".cache"] | path join)
        }
        if ("XDG_DATA_HOME" not-in $env) {
            $env.XDG_DATA_HOME = (["$env.HOME" ".local" "share"] | path join)
        }
        if ("XDG_CONFIG_HOME" not-in $env) {
            $env.XDG_CONFIG_HOME = (["$env.HOME" ".config"] | path join)
        }
        $env.PROMPT_COMMAND = { || ${pkgs.starship}/bin/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' }
        $env.PROMPT_COMMAND_RIGHT = { || ${pkgs.starship}/bin/starship prompt --right }
        $env.STARSHIP_SHELL = "nu"
        $env.PROMPT_INDICATOR = { || "" }
        $env.PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.PROMPT_INDICATOR_VI_NORMAL = { || "" }
        $env.PROMPT_MULTILINE_INDICATOR = { || "" }
      '';
    })
    (mkIf (cfg.enable && cfg.enableBashIntegration) {
      home.file.".config/bash/conf.d/99-starship.sh" = {
        text = ''
          eval "$(starship init bash)"
        '';
      };
    })
  ]);
}
