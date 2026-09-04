{
  cfg,
  pkgs,
  si,
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
  # upstream programs.fzf integrates bash/zsh/fish/nushell via si.flags. These
  # are additional per-shell conveniences, guarded on the associated shell.
  zsh = si.whenShellEnabled "zsh" {
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
  };
  fish = si.whenShellEnabled "fish" {
    plugins = [
      {
        name = "fzf-fish";
        src = "${pkgs.fishPlugins.fzf-fish.src}";
      }
    ];
  };
  nushell.extraConfig = si.whenShellEnabled "nushell" ''
    ${nuFzfBindings}
  '';
}
