{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption getExe;
  cfg = config.aytordev.programs.terminal.tools.eza;
in {
  options.aytordev.programs.terminal.tools.eza = {
    enable = mkEnableOption "eza";
    package = lib.mkPackageOption pkgs "eza" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    programs.eza = {
      enable = true;
      inherit (cfg) package;
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
      la = "${getExe cfg.package} -lah --tree";
      tree = "${getExe cfg.package} --tree --icons=always";
    };
    xdg.configFile."bash/conf.d/eza.sh" = {
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
