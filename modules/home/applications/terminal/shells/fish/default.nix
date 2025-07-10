{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.fish;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.fish = {
    enable = mkEnableOption "Fish shell with useful defaults";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Dependencies are managed by the fzf module
      home.packages = with pkgs; [
        fish
        fishPlugins.done
        fishPlugins.forgit
        fishPlugins.grc
        fishPlugins.pisces
        fishPlugins.pure
        fishPlugins.z
      ];

      # Ensure fzf is enabled (configured in tools/fzf)

      # Fish shell configuration
      programs.fish = {
        enable = true;

        # XDG Base Directory compliance
        functions = {
          # Ensure XDG directories exist
          __ensure_xdg_dirs = ''
            set -l xdg_config "$XDG_CONFIG_HOME/fish"
            set -l xdg_data "$XDG_DATA_HOME/fish"
            set -l xdg_cache "$XDG_CACHE_HOME/fish"

            for dir in "$xdg_config" "$xdg_data" "$xdg_cache"
              if not test -d "$dir"
                command mkdir -p "$dir"
              end
            end
          '';
        };

        # Environment variables and shell initialization
        shellInit = ''
          # Set up XDG directories
          set -gx XDG_CONFIG_HOME "${xdgConfigHome}"
          set -gx XDG_DATA_HOME "${xdgDataHome}"
          set -gx XDG_CACHE_HOME "${xdgCacheHome}"

          # Ensure XDG directories exist
          __ensure_xdg_dirs

          # Set fish variables
          set -gx fish_greeting ""  # Disable welcome message

          # Set history file location
          set -gx fish_history "fish"
          set -gx fish_user_paths $fish_user_paths

          # Set up path
          fish_add_path --path --global ~/.local/bin
          fish_add_path --path --global ~/.cargo/bin
          fish_add_path --path --global ~/go/bin

          # Set up editor
          set -gx EDITOR (command -v nvim || command -v vim || command -v vi || echo "vi")
          set -gx VISUAL $EDITOR

          # Set up pager
          set -gx PAGER (command -v less || echo "cat")
          set -gx LESS "-R"

          # Set up language
          set -gx LANG en_US.UTF-8
          set -gx LC_ALL en_US.UTF-8

          # Set up bat
          set -gx BAT_THEME "base16"

          # fzf configuration is managed by tools/fzf module
        '';

        # Interactive shell initialization
        interactiveShellInit = ''
          # Initialize zoxide
          if command -q zoxide
            zoxide init fish | source
          end

          # Initialize direnv
          if command -q direnv
            direnv hook fish | source
          end
        '';

        # Shell aliases
        shellAliases = {
          # Common commands
          ls = "command ls -F --color=auto";
          ll = "ls -lh";
          la = "ls -A";
          l = "ls -CF";

          # Git shortcuts
          gs = "git status";
          gd = "git diff";
          gco = "git checkout";
          gcb = "git checkout -b";
          gcm = "git commit -m";
          gaa = "git add --all";
          gp = "git push";

          # System commands
          rm = "rm -i";
          cp = "cp -i";
          mv = "mv -i";

          # NixOS
          nixos-rebuild = "sudo nixos-rebuild";
          home-manager = "nix-shell -p home-manager --run 'home-manager --flake ~/nixos-config';";

          # Python
          python = "python3";
          pip = "pip3";
        };

        # Plugins
        plugins = [
          {
            name = "z";
            src = "${pkgs.fishPlugins.z.src}";
          }
        ];
      };

      # Create necessary directories
      home.activation.fishDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/fish/functions"
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/fish"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/fish"
      '';
    }
  ]);
}
