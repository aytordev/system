{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  enabled = cfg.enable && cfg.client == "bw" && cfg.shellIntegration.enable;
in {
  config = lib.mkIf enabled {
    xdg.configFile = {
      "bitwarden-cli/session.bash" = lib.mkIf (cfg.shellIntegration.bash || cfg.shellIntegration.zsh) {
        text = ''
          bw-unlock() {
            local session
            session="$(bw unlock --raw)" || return
            export BW_SESSION="$session"
          }

          bw-lock() {
            bw lock && unset BW_SESSION
          }
        '';
      };

      "bitwarden-cli/session.fish" = lib.mkIf cfg.shellIntegration.fish {
        text = ''
          function bw-unlock
            set -l session (bw unlock --raw); or return
            set -gx BW_SESSION $session
          end

          function bw-lock
            bw lock; and set -e BW_SESSION
          end
        '';
      };
    };

    programs = {
      zsh.initContent = lib.mkIf cfg.shellIntegration.zsh ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.bash"
        (( $+commands[bw] )) && eval "$(bw completion --shell zsh)"
      '';
      bash.initExtra = lib.mkIf cfg.shellIntegration.bash ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.bash"
        command -v bw >/dev/null && eval "$(bw completion --shell bash)"
      '';
      fish.interactiveShellInit = lib.mkIf cfg.shellIntegration.fish ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.fish"
        command -q bw; and bw completion --shell fish | source
      '';
    };
  };
}
