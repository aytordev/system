{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.applications.terminal.tools.fzf;
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
  defaultCommand = "${pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
  commonEnv = ''
    export FZF_DEFAULT_COMMAND="${cfg.defaultCommand}"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="${pkgs.fd}/bin/fd --type d --hidden --exclude .git"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
  '';
  nuFzfBindings = ''
    def fzf-cd [] {
      let path = (${pkgs.fd}/bin/fd --type d --hidden --exclude .git | ${pkgs.fzf}/bin/fzf --preview '${pkgs.fd}/bin/fd --type f --hidden --exclude .git --max-depth 3 --color=always {} | head -n 50' --preview-window=right:50%:wrap)
      if $path != "" {
        cd $path
      }
    }
    def fzf-edit [] {
      let file = (${pkgs.fzf}/bin/fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:wrap)
      if $file != "" {
        nvim $file
      }
    }
    $env.config = ($env.config | upsert keybindings ($env.config.keybindings | append [
      {
        name: fzf-cd
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: { send: ExecuteHostCommand cmd: 'fzf-cd' }
      }
      {
        name: fzf-edit
        modifier: control
        keycode: char_e
        mode: [emacs, vi_normal, vi_insert]
        event: { send: ExecuteHostCommand cmd: 'fzf-edit' }
      }
    ]))
  '';
in {
  options.aytordev.applications.terminal.tools.fzf = {
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
      fd
      zsh-fzf-tab
    ];
    home.activation.createFzfDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.xdg.dataHome}/fzf"
    '';
    applications.fzf = {
      enable = true;
      inherit (cfg) defaultCommand;
      defaultOptions = defaultOptions ++ cfg.extraOptions;
    };
    applications.zsh = {
      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
      initContent = ''
        if [[ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]]; then
          source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
        fi
        if [[ -f "${pkgs.fzf}/share/fzf/completion.zsh" ]]; then
          source "${pkgs.fzf}/share/fzf/completion.zsh"
        fi
        export FZF_DEFAULT_COMMAND="${cfg.defaultCommand}"
        _fzf_compgen_path() {
          ${pkgs.fd}/bin/fd --hidden --follow --exclude ".git" . "$1"
        }
        _fzf_compgen_dir() {
          ${pkgs.fd}/bin/fd --type d --hidden --follow --exclude ".git" . "$1"
        }
      '';
    };
    home.file.".config/bash/conf.d/fzf.sh" = lib.mkIf config.aytordev.applications.terminal.shells.bash.enable {
      text = ''
        if [[ -f "${pkgs.fzf}/share/fzf/key-bindings.bash" ]]; then
          source "${pkgs.fzf}/share/fzf/key-bindings.bash"
        fi
        if [[ -f "${pkgs.fzf}/share/fzf/completion.bash" ]]; then
          source "${pkgs.fzf}/share/fzf/completion.bash"
        fi
        export FZF_DEFAULT_COMMAND="${cfg.defaultCommand}"
        _fzf_compgen_path() {
          ${pkgs.fd}/bin/fd --hidden --follow --exclude ".git" . "$1"
        }
        _fzf_compgen_dir() {
          ${pkgs.fd}/bin/fd --type d --hidden --follow --exclude ".git" . "$1"
        }
      '';
    };
    applications.fish = {
      plugins = [
        {
          name = "fzf-fish";
          src = "${pkgs.fishPlugins.fzf-fish.src}";
        }
      ];
      shellInit = ''
        set -gx FZF_DEFAULT_COMMAND "${cfg.defaultCommand}"
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND "${pkgs.fd}/bin/fd --type d --hidden --exclude .git"
        set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
      '';
    };
    applications.nushell = {
      extraConfig = ''
        ${nuFzfBindings}
      '';
    };
  };
}
