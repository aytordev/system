{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  themeCfg = config.aytordev.theme;

  cfg = config.aytordev.programs.terminal.tools.tmux;

  # Only hand `resolveApp` an integration that covers the active variant; Sora
  # declares no tmux integration, so ukiyo keeps its own default (null).
  selectOfficial = integration:
    if !(lib.isAttrs integration)
    then integration
    else if !(integration ? variants)
    then integration
    else if (integration.variants or {}) ? ${themeCfg.variant}
    then integration
    else null;

  themeResolution = lib.aytordev.resolveApp {
    app = "tmux";
    inherit (themeCfg) variant;
    override = cfg.theme;
    official = selectOfficial (themeCfg.integrations.${themeCfg.name}.tmux or null);
    generated = null;
  };

  # Official selection uses the ukiyo `theme/variant` id; no generated resource.
  tmuxTheme =
    if themeResolution.kind == "none"
    then null
    else themeResolution.id;

  themeOverrideType = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family integration, manual pins id, none leaves ukiyo's default.";
      };
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "ukiyo `theme/variant` id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.tmux = {
    enable = lib.mkEnableOption "tmux";
    package = lib.mkPackageOption pkgs "tmux" {nullable = true;};
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.str themeOverrideType);
      default = null;
      description = ''
        ukiyo theme override (e.g. "kanagawa/dragon"). Null follows
        `aytordev.theme` through the integration resolver. A bare
        `theme/variant` string, or `{ mode = "manual"; id = ...; }`, pins a
        theme; `{ mode = "none"; }` leaves ukiyo's own default.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      inherit (cfg) package;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      # HM's default (isLinux) keeps secureSocket off on macOS, where
      # /run/user does not exist and TMUX_TMPDIR would point nowhere.
      sensibleOnTop = false;
      terminal = "tmux-256color";

      plugins = with pkgs.tmuxPlugins; [
        # Tested options for TMUX compatibility
        {plugin = sensible;}

        # Clipboard management
        {plugin = yank;}

        # Tmux Navigation
        {plugin = vim-tmux-navigator;}

        # Tmux Resurrect
        {plugin = resurrect;}

        # Continuous saving of tmux environment
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }

        # Floating pane
        {
          plugin = tmux-floax;
          extraConfig = ''
            set -g @floax-bind 'p'
            set -g @floax-change-path 'true'
          '';
        }

        # Session manager with fuzzy finding
        {
          plugin = tmux-sessionx;
          extraConfig = ''
            set -g @sessionx-bind 'o'
          '';
        }

        # Which Key
        {plugin = tmux-which-key;}

        # Theme (load last for theme to take effect)
        {
          plugin = ukiyo;
          extraConfig =
            /*
            Bash
            */
            ''
              ${lib.optionalString (tmuxTheme != null) "set -g @ukiyo-theme '${tmuxTheme}'"}
              set -g @ukiyo-plugins "git cpu-usage ram-usage"
              set -g @ukiyo-ignore-window-colors true
            '';
        }
      ];

      extraConfig =
        /*
        Bash
        */
        ''
          # --- Terminal & Key Handling ---
          set -ga terminal-overrides ",*:Tc"
          set -s extended-keys off

          # Vi mode copy (platform-aware)
          if-shell 'uname | grep -q Darwin' \
            'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"' \
            'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip"'

          # --- Keymaps ---
          # Splits (v=horizontal, d=vertical)
          unbind '"'
          unbind %
          bind v split-window -h -c "#{pane_current_path}"
          bind d split-window -v -c "#{pane_current_path}"

          # Kill all sessions except current
          bind K confirm-before -p "Kill all other sessions? (y/n)" "kill-session -a"

          # Pane navigation
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          # --- Floating Scratchpad ---
          bind-key -n M-g if-shell -F '#{==:#{session_name},scratch}' {
            detach-client
          } {
            display-popup -d "#{pane_current_path}" -E "tmux new-session -A -s scratch"
          }

          # --- Performance ---
          set -sg escape-time 0
          set -g  history-limit 50000
          set -g  aggressive-resize on

          # --- Session Options ---
          set -g detach-on-destroy off
          set -g renumber-windows  on
          set -g allow-passthrough on
          set -g focus-events      on

          # --- Status Bar ---
          set -g status-position top
        '';
    };
  };
}
