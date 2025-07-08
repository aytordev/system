{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.starship;

  # XDG Base Directory paths
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";

  # Starship configuration paths
  starshipConfigDir = "${xdgConfigHome}/starship";
  starshipConfigFile = "${starshipConfigDir}/config.toml";
in {
  options.applications.terminal.tools.starship = {
    enable = mkEnableOption "Starship prompt";

    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with ZSH";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Starship configuration options";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [pkgs.starship];

      # Create Starship configuration directory and files
      xdg.configFile = {
        # Main configuration file
        "starship/config.toml".source =
          pkgs.writeText "starship-config.toml" (builtins.toJSON cfg.settings);

        # Directory for additional configuration files
        "starship/modules".source = lib.mkForce (pkgs.runCommand "starship-modules-dir" {} ''
          mkdir -p $out
          # Add any additional module configurations here
        '');
      };

      # Set STARSHIP_CACHE and other environment variables according to XDG spec
      home.sessionVariables = {
        STARSHIP_CACHE = "${xdgCacheHome}/starship";
        STARSHIP_CONFIG = "${starshipConfigFile}";
        STARSHIP_CONFIG_DIR = "${starshipConfigDir}";
      };

      # Create cache directory
      xdg.cacheFile."starship".source = lib.mkForce (pkgs.runCommand "starship-cache-dir" {} ''
        mkdir -p $out
      '');
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
