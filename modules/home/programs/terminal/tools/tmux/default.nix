{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  themeCfg = config.aytordev.theme;

  cfg = config.aytordev.programs.terminal.tools.tmux;
in {
  options.aytordev.programs.terminal.tools.tmux = {
    enable = lib.mkEnableOption "tmux";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      secureSocket = true;
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
              set -g @ukiyo-theme '${themeCfg.appTheme.raw}'
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
