{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.fzf;
in {
  options.applications.terminal.tools.fzf = {
    enable = mkEnableOption "fuzzy finder";
    
    defaultCommand = mkOption {
      type = types.str;
      default = "${pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
      description = "Default command to use for finding files";
    };
    
    defaultOptions = mkOption {
      type = types.listOf types.str;
      default = [
        "--layout=reverse"
        "--exact"
        "--bind=alt-p:toggle-preview,alt-a:select-all"
        "--multi"
        "--no-mouse"
        "--info=inline"
        "--ansi"
        "--with-nth=1.."
        "--pointer=' '"
        "--header-first"
        "--border=rounded"
      ];
      description = "Default options for fzf";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      fd  # Required for defaultCommand
      zsh-fzf-tab  # Enhanced fzf completion for Zsh
    ];
    
    # fzf-tab configuration
    programs.zsh.plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    programs.fzf = {
      enable = true;
      inherit (cfg) defaultCommand defaultOptions;
      
      # Enable shell integrations
      enableBashIntegration = true;
      enableZshIntegration = false;  # We'll handle Zsh integration manually
      enableFishIntegration = true;

      # Enable tmux integration
      tmux = {
        enableShellIntegration = true;
      };
    };

    # Manual Zsh integration to ensure proper loading order
    programs.zsh.initExtra = ''
      # Initialize fzf
      if [[ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]]; then
        source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      fi
      
      if [[ -f "${pkgs.fzf}/share/fzf/completion.zsh" ]]; then
        source "${pkgs.fzf}/share/fzf/completion.zsh"
      fi
      
      # Set up fzf key bindings and completion
      export FZF_DEFAULT_COMMAND="${cfg.defaultCommand}"
      export FZF_DEFAULT_OPTS="${concatStringsSep " " cfg.defaultOptions}"
      
      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path() {
        ${pkgs.fd}/bin/fd --hidden --follow --exclude ".git" . "$1"
      }
      
      # Use fd to generate the list for directory completion
      _fzf_compgen_dir() {
        ${pkgs.fd} --type d --hidden --follow --exclude ".git" . "$1"
      }
    '';
  };
}
