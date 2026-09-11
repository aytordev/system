{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  enabled = cfg.enable && (cfg.client == "bw" || cfg.bw.enable) && cfg.shellIntegration.enable;
  executable = lib.getExe pkgs.bitwarden-cli;
  chmod = lib.getExe' pkgs.coreutils "chmod";
  id = lib.getExe' pkgs.coreutils "id";
  mkdir = lib.getExe' pkgs.coreutils "mkdir";
  mktemp = lib.getExe' pkgs.coreutils "mktemp";
  mv = lib.getExe' pkgs.coreutils "mv";
  rm = lib.getExe' pkgs.coreutils "rm";
  stat = lib.getExe' pkgs.coreutils "stat";
  unlockSession = pkgs.writeShellApplication {
    name = "bw-session-unlock";
    text = ''
      session_dir="$1"
      session_file="$session_dir/session"
      session_tmp="$(${mktemp} "$session_dir/session.XXXXXX")"
      trap '${rm} -f "$session_tmp"' EXIT HUP INT TERM

      if ${executable} unlock --raw > "$session_tmp"; then
        ${chmod} 600 "$session_tmp"
        ${mv} -fT -- "$session_tmp" "$session_file"
        trap - EXIT HUP INT TERM
      else
        exit "$?"
      fi
    '';
  };
in {
  config = lib.mkIf enabled {
    xdg.configFile = {
      "bitwarden-cli/session.bash" = lib.mkIf (cfg.shellIntegration.bash || cfg.shellIntegration.zsh) {
        text = ''
          _bw_uid="$(${id} -u)"
          _bw_session_root_is_fallback=0
          if [[ -n "''${XDG_RUNTIME_DIR:-}" ]]; then
            _bw_session_root="$XDG_RUNTIME_DIR"
          else
            _bw_session_root="/tmp/bitwarden-$_bw_uid"
            _bw_session_root_is_fallback=1
          fi
          _bw_session_dir="$_bw_session_root/bitwarden-cli"
          _bw_session_file="$_bw_session_dir/session"

          _bw_prepare_session_dir() {
            local root_owner root_mode session_dir_owner session_dir_mode
            if (( _bw_session_root_is_fallback )); then
              if [[ -L "$_bw_session_root" ]]; then
                printf 'Bitwarden session root must not be a symlink\n' >&2
                return 1
              fi
              if ! ${mkdir} -m 700 -- "$_bw_session_root" 2>/dev/null && [[ ! -d "$_bw_session_root" ]]; then
                printf 'Bitwarden session root could not be created\n' >&2
                return 1
              fi
            fi
            if [[ -z "$_bw_session_root" || ! -d "$_bw_session_root" || -L "$_bw_session_root" ]]; then
              printf 'Bitwarden session root is unavailable or unsafe\n' >&2
              return 1
            fi
            root_owner="$(${stat} -c %u -- "$_bw_session_root")" || return
            if [[ "$root_owner" != "$_bw_uid" ]]; then
              printf 'Bitwarden session root has unsafe ownership\n' >&2
              return 1
            fi
            if (( _bw_session_root_is_fallback )); then
              ${chmod} 700 "$_bw_session_root" || return
            fi
            root_mode="$(${stat} -c %a -- "$_bw_session_root")" || return
            if [[ "$root_mode" != 700 ]]; then
              printf 'Bitwarden session root has unsafe permissions\n' >&2
              return 1
            fi
            if [[ -L "$_bw_session_dir" ]]; then
              printf 'Bitwarden session directory must not be a symlink\n' >&2
              return 1
            fi
            ${mkdir} -m 700 -p -- "$_bw_session_dir" || return
            session_dir_owner="$(${stat} -c %u -- "$_bw_session_dir")" || return
            session_dir_mode="$(${stat} -c %a -- "$_bw_session_dir")" || return
            if [[ "$session_dir_owner" != "$_bw_uid" || "$session_dir_mode" != 700 ]]; then
              printf 'Bitwarden session directory has unsafe ownership or permissions\n' >&2
              return 1
            fi
          }

          bw() {
            local session_owner session_mode
            _bw_prepare_session_dir || return
            if [[ -e "$_bw_session_file" || -L "$_bw_session_file" ]]; then
              if [[ ! -f "$_bw_session_file" || -L "$_bw_session_file" || ! -O "$_bw_session_file" ]]; then
                printf 'Bitwarden session file has unsafe ownership or type\n' >&2
                return 1
              fi
              session_owner="$(${stat} -c %u -- "$_bw_session_file")" || return
              session_mode="$(${stat} -c %a -- "$_bw_session_file")" || return
              if [[ "$session_owner" != "$_bw_uid" || "$session_mode" != 600 ]]; then
                printf 'Bitwarden session file has unsafe ownership or permissions\n' >&2
                return 1
              fi
              BW_SESSION="$(<"$_bw_session_file")" ${executable} "$@"
            else
              ${executable} "$@"
            fi
          }

          bw-unlock() (
            _bw_prepare_session_dir || exit
            ${lib.getExe unlockSession} "$_bw_session_dir"
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
          set -g __bw_uid (${id} -u)
          set -g __bw_session_root_is_fallback 0
          if set -q XDG_RUNTIME_DIR; and test -n "$XDG_RUNTIME_DIR"
            set -g __bw_session_root "$XDG_RUNTIME_DIR"
          else
            set -g __bw_session_root "/tmp/bitwarden-$__bw_uid"
            set -g __bw_session_root_is_fallback 1
          end
          set -g __bw_session_dir "$__bw_session_root/bitwarden-cli"
          set -g __bw_session_file "$__bw_session_dir/session"

          function __bw_prepare_session_dir
            if test $__bw_session_root_is_fallback -eq 1
              if test -L "$__bw_session_root"
                echo "Bitwarden session root must not be a symlink" >&2
                return 1
              end
              if not ${mkdir} -m 700 -- "$__bw_session_root" 2>/dev/null; and not test -d "$__bw_session_root"
                echo "Bitwarden session root could not be created" >&2
                return 1
              end
            end
            if test -z "$__bw_session_root"; or not test -d "$__bw_session_root"; or test -L "$__bw_session_root"
              echo "Bitwarden session root is unavailable or unsafe" >&2
              return 1
            end
            set -l root_owner (${stat} -c %u -- "$__bw_session_root"); or return
            if test "$root_owner" != "$__bw_uid"
              echo "Bitwarden session root has unsafe ownership" >&2
              return 1
            end
            if test $__bw_session_root_is_fallback -eq 1
              ${chmod} 700 "$__bw_session_root"; or return
            end
            set -l root_mode (${stat} -c %a -- "$__bw_session_root"); or return
            if test "$root_mode" != 700
              echo "Bitwarden session root has unsafe permissions" >&2
              return 1
            end
            if test -L "$__bw_session_dir"
              echo "Bitwarden session directory must not be a symlink" >&2
              return 1
            end
            ${mkdir} -m 700 -p -- "$__bw_session_dir"; or return
            set -l session_dir_owner (${stat} -c %u -- "$__bw_session_dir"); or return
            set -l session_dir_mode (${stat} -c %a -- "$__bw_session_dir"); or return
            if test "$session_dir_owner" != "$__bw_uid"; or test "$session_dir_mode" != 700
              echo "Bitwarden session directory has unsafe ownership or permissions" >&2
              return 1
            end
          end

          function bw
            __bw_prepare_session_dir; or return
            if test -e "$__bw_session_file"; or test -L "$__bw_session_file"
              if not test -f "$__bw_session_file"; or test -L "$__bw_session_file"
                echo "Bitwarden session file has unsafe type" >&2
                return 1
              end
              set -l session_owner (${stat} -c %u -- "$__bw_session_file"); or return
              set -l session_mode (${stat} -c %a -- "$__bw_session_file"); or return
              if test "$session_owner" != "$__bw_uid"; or test "$session_mode" != 600
                echo "Bitwarden session file has unsafe ownership or permissions" >&2
                return 1
              end
              env BW_SESSION=(string trim < "$__bw_session_file") ${executable} $argv
            else
              ${executable} $argv
            end
          end

          function bw-unlock
            __bw_prepare_session_dir; or return
            ${lib.getExe unlockSession} "$__bw_session_dir"
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
