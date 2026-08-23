{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  enabled = cfg.enable && cfg.client == "bw" && cfg.shellIntegration.enable;
  executable = lib.getExe cfg.package;
  chmod = lib.getExe' pkgs.coreutils "chmod";
  id = lib.getExe' pkgs.coreutils "id";
  mkdir = lib.getExe' pkgs.coreutils "mkdir";
  mktemp = lib.getExe' pkgs.coreutils "mktemp";
  mv = lib.getExe' pkgs.coreutils "mv";
  rm = lib.getExe' pkgs.coreutils "rm";
in {
  config = lib.mkIf enabled {
    xdg.configFile = {
      "bitwarden-cli/session.bash" = lib.mkIf (cfg.shellIntegration.bash || cfg.shellIntegration.zsh) {
        text = ''
          if [[ -n "''${XDG_RUNTIME_DIR:-}" ]]; then
            _bw_session_root="$XDG_RUNTIME_DIR"
          else
            _bw_session_root="''${TMPDIR:-/tmp}/bitwarden-$(${id} -u)"
          fi
          _bw_session_dir="$_bw_session_root/bitwarden-cli"
          _bw_session_file="$_bw_session_dir/session"

          _bw_prepare_session_dir() {
            if [[ -L "$_bw_session_dir" ]]; then
              printf 'Bitwarden session directory must not be a symlink\n' >&2
              return 1
            fi
            ${mkdir} -p "$_bw_session_dir" || return
            ${chmod} 700 "$_bw_session_dir" || return
            [[ -O "$_bw_session_dir" ]]
          }

          bw() {
            _bw_prepare_session_dir || return
            if [[ -e "$_bw_session_file" || -L "$_bw_session_file" ]]; then
              if [[ ! -f "$_bw_session_file" || -L "$_bw_session_file" || ! -O "$_bw_session_file" ]]; then
                printf 'Bitwarden session file has unsafe ownership or type\n' >&2
                return 1
              fi
              BW_SESSION="$(<"$_bw_session_file")" ${executable} "$@"
            else
              ${executable} "$@"
            fi
          }

          bw-unlock() (
            umask 077
            _bw_prepare_session_dir || exit
            local session_tmp
            session_tmp="$(${mktemp} "$_bw_session_dir/session.XXXXXX")" || exit
            if ${executable} unlock --raw > "$session_tmp"; then
              ${mv} -f "$session_tmp" "$_bw_session_file"
            else
              status=$?
              ${rm} -f "$session_tmp"
              exit "$status"
            fi
          )

          bw-lock() {
            local status=0
            bw lock || status=$?
            ${rm} -f "$_bw_session_file"
            return "$status"
          }
        '';
      };

      "bitwarden-cli/session.fish" = lib.mkIf cfg.shellIntegration.fish {
        text = ''
          if set -q XDG_RUNTIME_DIR; and test -n "$XDG_RUNTIME_DIR"
            set -g __bw_session_root "$XDG_RUNTIME_DIR"
          else
            if set -q TMPDIR
              set -g __bw_session_root "$TMPDIR/bitwarden-"(${id} -u)
            else
              set -g __bw_session_root "/tmp/bitwarden-"(${id} -u)
            end
          end
          set -g __bw_session_dir "$__bw_session_root/bitwarden-cli"
          set -g __bw_session_file "$__bw_session_dir/session"

          function __bw_prepare_session_dir
            if test -L "$__bw_session_dir"
              echo "Bitwarden session directory must not be a symlink" >&2
              return 1
            end
            ${mkdir} -p "$__bw_session_dir"; or return
            ${chmod} 700 "$__bw_session_dir"; or return
          end

          function bw
            __bw_prepare_session_dir; or return
            if test -e "$__bw_session_file"; or test -L "$__bw_session_file"
              if not test -f "$__bw_session_file"; or test -L "$__bw_session_file"
                echo "Bitwarden session file has unsafe type" >&2
                return 1
              end
              env BW_SESSION=(string trim < "$__bw_session_file") ${executable} $argv
            else
              ${executable} $argv
            end
          end

          function bw-unlock
            __bw_prepare_session_dir; or return
            set -l session_tmp (${mktemp} "$__bw_session_dir/session.XXXXXX"); or return
            ${executable} unlock --raw > "$session_tmp"
            set -l unlock_status $status
            if test $unlock_status -ne 0
              ${rm} -f "$session_tmp"
              return $unlock_status
            end
            ${chmod} 600 "$session_tmp"
            ${mv} -f "$session_tmp" "$__bw_session_file"
          end

          function bw-lock
            bw lock
            set -l status $status
            ${rm} -f "$__bw_session_file"
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
