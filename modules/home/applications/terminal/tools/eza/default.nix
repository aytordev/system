{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.applications.terminal.tools.eza;
in {
  options.aytordev.applications.terminal.tools.eza = {
    enable = mkEnableOption "eza";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [eza];
    programs.eza = {
      enable = true;
      package = pkgs.eza;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--hyperlink"
        "--follow-symlinks"
      ];
      git = true;
      icons = "auto";
    };
    home.shellAliases = {
      la = "${getExe pkgs.eza} -lah --tree";
      tree = "${getExe pkgs.eza} --tree --icons=always";
    };
    home.file.".config/bash/conf.d/eza.sh" = {
      text = ''
        if command -v eza &> /dev/null; then
          alias ls='eza --group-directories-first --icons=auto --color=auto'
          alias ll='eza -l --group-directories-first --header --icons=auto --git --color=auto'
          alias la='eza -la --group-directories-first --header --icons=auto --git --color=auto --tree'
          alias lt='eza --tree --level=2 --group-directories-first --icons=auto --color=auto'
          alias l.='eza -a | grep -E "^\." --color=never'
        fi
      '';
      executable = true;
    };
  };
}
