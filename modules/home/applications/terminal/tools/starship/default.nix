{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.starship;

  # Import themes
  themes = {
    catppuccin-frappe = import ./themes/catppuccin-frappe.nix {inherit lib;};
    catppuccin-latte = import ./themes/catppuccin-latte.nix {inherit lib;};
    catppuccin-macchiato = import ./themes/catppuccin-macchiato.nix {inherit lib;};
    catppuccin-mocha = import ./themes/catppuccin-mocha.nix {inherit lib;};
  };

  # Import modules
  osModule = import ./modules/os.nix {inherit lib;};
  gitModule = import ./modules/git.nix {inherit lib;};
  languagesModule = import ./modules/languages.nix {inherit lib;};
  shellModule = import ./modules/shell-module.nix {inherit lib;};

  # XDG Base Directory paths
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";

  # Starship configuration paths
  starshipConfigDir = "${xdgConfigHome}/starship";
  starshipConfigFile = "${starshipConfigDir}/config.toml";
  starshipCacheDir = "${xdgCacheHome}/starship";

  # Base configuration
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

  # Merge all configurations using foldl and recursiveUpdate
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
      # Create a wrapper script that strictly controls the Starship environment
      home.packages = [
        (pkgs.writeShellScriptBin "starship" ''
          #!/bin/sh
          # Strictly control the Starship environment
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          # Force disable all logging
          unset STARSHIP_LOG
          unset STARSHIP_CACHE
          # Use a temporary directory in the user's cache
          export TMPDIR="${config.xdg.cacheHome}/starship-tmp"
          mkdir -p "$TMPDIR"
          chmod 700 "$TMPDIR"
          # Execute the real Starship binary with the clean environment
          exec ${pkgs.starship}/bin/starship "$@"
        '')
      ];

      # Create Starship configuration directory and files
      xdg.configFile = {
        # Main configuration file - using TOML format
        "starship/config.toml".source = (pkgs.formats.toml {}).generate "starship-config" cfg.settings;

        # Directory for additional configuration files
        "starship/modules".source = lib.mkForce (pkgs.runCommand "starship-modules-dir" {} ''
          mkdir -p $out
          # Add any additional module configurations here
        '');
      };

      # Ensure the temporary directory exists and has the right permissions
      home.activation.createStarshipTmpDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/starship-tmp"
        $DRY_RUN_CMD chmod 700 "${config.xdg.cacheHome}/starship-tmp"
      '';
    }

    # Zsh integration
    (mkIf (cfg.enable && cfg.enableZshIntegration) {
      programs.zsh.initContent = ''
        # Initialize Starship with XDG compliance
        if [ -n "$commands[starship]" ]; then
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          export STARSHIP_CACHE="${xdgCacheHome}/starship"

          # Ensure directories exist
          for dir in "$STARSHIP_CACHE" "$STARSHIP_CONFIG_DIR/modules"; do
            if [ ! -d "$dir" ]; then
              mkdir -p "$dir"
            fi
          done

          # Initialize starship
          eval "$(${pkgs.starship}/bin/starship init zsh --print-full-init)"
        fi
      '';
    })

    # Fish integration
    (mkIf (cfg.enable && cfg.enableFishIntegration) {
      programs.fish.interactiveShellInit = ''
        # Initialize Starship with XDG compliance
        if command -q starship
          set -gx STARSHIP_CONFIG "${starshipConfigFile}"
          set -gx STARSHIP_CONFIG_DIR "${starshipConfigDir}"
          set -gx STARSHIP_CACHE "${xdgCacheHome}/starship"

          # Ensure directories exist
          for dir in $STARSHIP_CACHE "$STARSHIP_CONFIG_DIR/modules"
            if not test -d "$dir"
              mkdir -p "$dir"
            end
          end

          # Initialize starship
          ${pkgs.starship}/bin/starship init fish | source
        end
      '';
    })

    # Nushell integration
    (mkIf (cfg.enable && cfg.enableNushellIntegration) {
      programs.nushell.extraConfig = ''
        # Initialize Starship with XDG compliance
        $env.STARSHIP_CONFIG = "${starshipConfigFile}"
        $env.STARSHIP_CONFIG_DIR = "${starshipConfigDir}"
        $env.STARSHIP_CACHE = "${xdgCacheHome}/starship"

        # Ensure XDG directories exist
        if ("XDG_CACHE_HOME" not-in $env) {
            $env.XDG_CACHE_HOME = (["$env.HOME" ".cache"] | path join)
        }
        if ("XDG_DATA_HOME" not-in $env) {
            $env.XDG_DATA_HOME = (["$env.HOME" ".local" "share"] | path join)
        }
        if ("XDG_CONFIG_HOME" not-in $env) {
            $env.XDG_CONFIG_HOME = (["$env.HOME" ".config"] | path join)
        }

        # Initialize starship directly without saving to file
        $env.PROMPT_COMMAND = { || ${pkgs.starship}/bin/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' }
        $env.PROMPT_COMMAND_RIGHT = { || ${pkgs.starship}/bin/starship prompt --right }

        # Set up environment for the prompt
        $env.STARSHIP_SHELL = "nu"

        # Clear any existing prompt commands
        $env.PROMPT_INDICATOR = { || "" }
        $env.PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.PROMPT_INDICATOR_VI_NORMAL = { || "" }
        $env.PROMPT_MULTILINE_INDICATOR = { || "" }
      '';
    })

    # Bash integration
    (mkIf (cfg.enable && cfg.enableBashIntegration) {
      home.file.".config/bash/conf.d/starship.sh" = {
        text = ''
          # Initialize Starship with XDG compliance
          if command -v starship >/dev/null 2>&1; then
            # Set up Starship environment
            export STARSHIP_CONFIG="${starshipConfigFile}"
            export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
            export STARSHIP_CACHE="${xdgCacheHome}/starship"

            # Ensure directories exist
            for dir in "$STARSHIP_CACHE" "$STARSHIP_CONFIG_DIR/modules"; do
              if [ ! -d "$dir" ]; then
                mkdir -p "$dir"
              fi
            done

            # Initialize starship
            eval "$(starship init bash --print-full-init)"
          fi
        ''; # Suppress error if starship fails
      };
    })
  ]);
}
