{
  cfg,
  lib,
  starshipConfigDir,
  starshipConfigFile,
  xdgCacheHome,
}: {
  options = {
    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with ZSH";
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Fish shell";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Bash";
    };

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Nushell";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableZshIntegration {
      programs.zsh.initContent = ''
        if [ -n "$commands[starship]" ]; then
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          export STARSHIP_CACHE="${xdgCacheHome}/starship"
          for dir in "$STARSHIP_CACHE" "$STARSHIP_CONFIG_DIR/modules"; do
            [ ! -d "$dir" ] && mkdir -p "$dir"
          done
          eval "$(${cfg.package}/bin/starship init zsh --print-full-init)"
        fi
      '';
    })

    (lib.mkIf cfg.enableFishIntegration {
      programs.fish.interactiveShellInit = ''
        if command -q starship
          set -gx STARSHIP_CONFIG "${starshipConfigFile}"
          set -gx STARSHIP_CONFIG_DIR "${starshipConfigDir}"
          set -gx STARSHIP_CACHE "${xdgCacheHome}/starship"
          for dir in $STARSHIP_CACHE "$STARSHIP_CONFIG_DIR/modules"
            test -d "$dir"; or mkdir -p "$dir"
          end
          ${cfg.package}/bin/starship init fish | source
        end
      '';
    })

    (lib.mkIf cfg.enableNushellIntegration {
      programs.nushell.extraConfig = ''
        $env.STARSHIP_CONFIG = "${starshipConfigFile}"
        $env.STARSHIP_CONFIG_DIR = "${starshipConfigDir}"
        $env.STARSHIP_CACHE = "${xdgCacheHome}/starship"
        $env.PROMPT_COMMAND = { || ${cfg.package}/bin/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' }
        $env.PROMPT_COMMAND_RIGHT = { || ${cfg.package}/bin/starship prompt --right }
        $env.STARSHIP_SHELL = "nu"
        $env.PROMPT_INDICATOR = { || "" }
        $env.PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.PROMPT_INDICATOR_VI_NORMAL = { || "" }
        $env.PROMPT_MULTILINE_INDICATOR = { || "" }
      '';
    })

    (lib.mkIf cfg.enableBashIntegration {
      xdg.configFile."bash/conf.d/99-starship.sh".text = ''
        eval "$(starship init bash)"
      '';
    })
  ];
}
