{
  cfg,
  pkgs,
}: let
  nuFzfBindings = ''
    def fzf-cd [] {
      let path = (${pkgs.fd}/bin/fd --type d --hidden --exclude .git | ${cfg.package}/bin/fzf --preview '${pkgs.fd}/bin/fd --type f --hidden --exclude .git --max-depth 3 --color=always {} | head -n 50' --preview-window=right:50%:wrap)
      if $path != "" {
        cd $path
      }
    }
    def fzf-edit [] {
      let file = (${cfg.package}/bin/fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:wrap)
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
  zsh = {
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
    initContent = ''
      if [[ -f "${cfg.package}/share/fzf/key-bindings.zsh" ]]; then
        source "${cfg.package}/share/fzf/key-bindings.zsh"
      fi
      if [[ -f "${cfg.package}/share/fzf/completion.zsh" ]]; then
        source "${cfg.package}/share/fzf/completion.zsh"
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
  fish = {
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
  nushell.extraConfig = ''
    ${nuFzfBindings}
  '';
}
