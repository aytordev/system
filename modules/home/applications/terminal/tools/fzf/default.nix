{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.fzf;

  # Default options for fzf
  defaultOptions = [
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

  # Default command for finding files
  defaultCommand = "${pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
in {
  options.applications.terminal.tools.fzf = {
    enable = mkEnableOption "fuzzy finder";

    defaultCommand = mkOption {
      type = types.str;
      default = defaultCommand;
      description = "Default command to use for finding files";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional options to pass to fzf";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      fd # Required for defaultCommand
      zsh-fzf-tab # Enhanced fzf completion for Zsh
    ];

    # Ensure XDG directories exist
    home.activation.createFzfDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.xdg.dataHome}/fzf"
    '';

    # Configure fzf with XDG compliance
    programs.fzf = {
      enable = true;
      inherit (cfg) defaultCommand;

      # Combine default options, XDG history path, and any extra options
      defaultOptions =
        defaultOptions
        ++ [
          "--history=${config.xdg.dataHome}/fzf/history"
        ]
        ++ cfg.extraOptions;
    };

    # fzf-tab configuration
    programs.zsh.plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    # Shell integrations are now configured in the programs.fzf block above

    # Manual Zsh integration to ensure proper loading order
    programs.zsh.initContent = ''
      # Initialize fzf
      if [[ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]]; then
        source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      fi

      if [[ -f "${pkgs.fzf}/share/fzf/completion.zsh" ]]; then
        source "${pkgs.fzf}/share/fzf/completion.zsh"
      fi

      # Set up fzf command
      # Note: FZF_DEFAULT_OPTS is now handled by home-manager's programs.fzf
      export FZF_DEFAULT_COMMAND="${cfg.defaultCommand}"

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
