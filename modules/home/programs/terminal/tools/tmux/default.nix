{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  themeCfg = config.aytordev.theme;

  cfg = config.aytordev.programs.terminal.tools.tmux;

in
{
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
      sensibleOnTop = false;
      terminal = "tmux-256color";

      plugins = with pkgs.tmuxPlugins; [
        # Tested options for TMUX compatibility
        { plugin = sensible; }

        # Clipboard management
        { plugin = yank; }

        # Tmux Navigation
        { plugin = vim-tmux-navigator; }

        # Tmux Resurrect
        { plugin = resurrect; }

        # Which Key
        { plugin = tmux-which-key; }

        # Tema Kanagawa (load last for theme to take effect)
        {
          plugin = kanagawa;
          extraConfig = /* Bash */ ''
            set -g @kanagawa-theme '${themeCfg.variant}'
            set -g @kanagawa-plugins "git cpu-usage ram-usage"
            set -g @kanagawa-ignore-window-colors true
          '';
        }
      ];

      extraConfig = /* Bash */ ''
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

        # --- Floating Scratchpad ---
        bind-key -n M-g if-shell -F '#{==:#{session_name},scratch}' {
          detach-client
        } {
          display-popup -d "#{pane_current_path}" -E "tmux new-session -A -s scratch"
        }

        # --- Status Bar ---
        set -g status-position top
      '';
    };
  };
}
