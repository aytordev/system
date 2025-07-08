{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.applications.terminal.tools.starship;

  # Import modules
  nordTheme = import ./themes/nord.nix { inherit lib; };
  osModule = import ./modules/os.nix { inherit lib; };
  gitModule = import ./modules/git.nix { inherit lib; };
  languagesModule = import ./modules/languages.nix { inherit lib; };
  shellModule = import ./modules/shell-module.nix { inherit lib; };

  # XDG Base Directory paths
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";

  # Starship configuration paths
  starshipConfigDir = "${xdgConfigHome}/starship";
  starshipConfigFile = "${starshipConfigDir}/config.toml";

  # Base configuration
  baseConfig = {
    "$schema" = "https://starship.rs/config-schema.json";
    format = """
      [╭](bold overlay1)$username\
      $directory\
      $git_branch\
      $git_status\
      $c\
      $rust\
      $golang\
      $nodejs\
      $php\
      $java\
      $kotlin\
      $haskell\
      $python\
      $lua\
      $docker_context\
      $line_break$character""";
  };

  # Merge all configurations using foldl and recursiveUpdate
  mergedConfig = lib.foldl lib.recursiveUpdate {} [
    baseConfig
    nordTheme
    osModule
    gitModule
    languagesModule
    shellModule
  ];

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
      default = mergedConfig;
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
