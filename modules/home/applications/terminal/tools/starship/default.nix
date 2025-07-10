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
  ]);
}
