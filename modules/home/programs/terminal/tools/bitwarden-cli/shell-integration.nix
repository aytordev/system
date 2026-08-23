{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  enabled = cfg.enable && cfg.client == "bw" && cfg.shellIntegration.enable;
  executable = lib.getExe cfg.package;
in {
  config = lib.mkIf enabled {
    xdg.configFile = {
      "bitwarden-cli/session.bash" = lib.mkIf (cfg.shellIntegration.bash || cfg.shellIntegration.zsh) {
        text = ''
          _bw_session_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}/bitwarden-$UID}"
          _bw_session_file="$_bw_session_dir/session"

          bw() {
            if [[ -r "$_bw_session_file" ]]; then
              BW_SESSION="$(<"$_bw_session_file")" ${executable} "$@"
            else
              ${executable} "$@"
            fi
          }

          bw-unlock() {
            umask 077
            mkdir -p "$_bw_session_dir"
            local session_tmp="$_bw_session_file.tmp"
            ${executable} unlock --raw > "$session_tmp" || return
            mv "$session_tmp" "$_bw_session_file"
          }

          bw-lock() {
            local status=0
            bw lock || status=$?
            rm -f "$_bw_session_file"
            return "$status"
          }
        '';
      };

      "bitwarden-cli/session.fish" = lib.mkIf cfg.shellIntegration.fish {
        text = ''
          set -g __bw_session_dir "$XDG_RUNTIME_DIR"
          if test -z "$__bw_session_dir"
            if set -q TMPDIR
              set -g __bw_session_dir "$TMPDIR/bitwarden-$UID"
            else
              set -g __bw_session_dir "/tmp/bitwarden-$UID"
            end
          end
          set -g __bw_session_file "$__bw_session_dir/session"

          function bw
            if test -r "$__bw_session_file"
              env BW_SESSION=(string trim < "$__bw_session_file") ${executable} $argv
            else
              ${executable} $argv
            end
          end

          function bw-unlock
            command mkdir -p "$__bw_session_dir"
            command chmod 700 "$__bw_session_dir"
            set -l session_tmp "$__bw_session_file.tmp"
            ${executable} unlock --raw > "$session_tmp"; or return
            command chmod 600 "$session_tmp"
            command mv "$session_tmp" "$__bw_session_file"
          end

          function bw-lock
            bw lock
            set -l status $status
            command rm -f "$__bw_session_file"
            return $status
          end
        '';
      };
    };

    programs = {
      zsh.initContent = lib.mkIf cfg.shellIntegration.zsh ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.bash"
        eval "$(${executable} completion --shell zsh)"
      '';
      bash.initExtra = lib.mkIf cfg.shellIntegration.bash ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.bash"
        eval "$(${executable} completion --shell bash)"
      '';
      fish.interactiveShellInit = lib.mkIf cfg.shellIntegration.fish ''
        source "$XDG_CONFIG_HOME/bitwarden-cli/session.fish"
        ${executable} completion --shell fish | source
      '';
    };
  };
}
