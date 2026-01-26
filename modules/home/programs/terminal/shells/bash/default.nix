{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.aytordev.programs.terminal.shells.bash;
in {
  options.aytordev.programs.terminal.shells.bash = {
    enable = mkEnableOption "Bash shell with useful defaults for Bash 5.3+";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = false; # Disable to prevent bind/complete errors

      # Bash 5.3+ enhanced history settings
      historySize = 10000;
      historyFileSize = 100000;
      historyControl = ["ignoredups" "erasedups"];
      historyFile = "${config.xdg.dataHome}/bash/history";

      # Shell options - verified for Bash 5.3
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
        "autocd"
        "cdspell"
        "dirspell"
        "nocaseglob"
        # Bash 5.3+ options
        "assoc_expand_once"
        "patsub_replacement"
        "varredir_close"
      ];

      # Environment variables via sessionVariables (declarative)
      sessionVariables = {
        BASH_CONFIG_DIR = "${config.xdg.configHome}/bash";
        BASH_DATA_DIR = "${config.xdg.dataHome}/bash";
        BASH_CACHE_DIR = "${config.xdg.cacheHome}/bash";
        INPUTRC = "${config.xdg.configHome}/readline/inputrc";
        # Bash 5.3: New GLOBSORT variable for completion sorting
        GLOBSORT = "name";
      };

      # Extra bashrc content
      bashrcExtra = ''
        # Source system bashrc if present
        [ -f /etc/bashrc ] && . /etc/bashrc

        # Source additional configurations from conf.d
        for f in "${config.xdg.configHome}/bash/conf.d/"*.sh; do
          [[ -f "$f" ]] && source "$f"
        done
      '';

      # Profile extra (login shell)
      profileExtra = ''
        # Login shell specific configuration
      '';

      # Init extra (interactive shell)
      initExtra = ''
        # Interactive shell specific configuration
        # Bash 5.3: ''${| cmd; } syntax available for capturing output without subshell
      '';
    };

    # Readline configuration (declarative)
    programs.readline = {
      enable = true;
      variables = {
        completion-ignore-case = true;
        show-all-if-ambiguous = true;
        show-all-if-unmodified = true;
        colored-stats = true;
        visible-stats = true;
        mark-symlinked-directories = true;
        # Bash 5.3: New readline options
        search-ignore-case = true;
      };
    };

    # XDG directories with proper permissions (declarative via xdg.configFile)
    # XDG directories with proper permissions (declarative via xdg.configFile)
    xdg = {
      configFile."bash/conf.d/.keep".text = "# Custom bash configurations go here\n";
      dataFile."bash/.keep".text = "";
      cacheFile."bash/.keep".text = "";
    };
  };
}
