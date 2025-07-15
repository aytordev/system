{
  config,
  lib,
  pkgs,
  ...
}: {
  options.applications.terminal.tools.ripgrep = {
    enable = lib.mkEnableOption "ripgrep";
  };
  config = lib.mkIf config.applications.terminal.tools.ripgrep.enable {
    programs.ripgrep = {
      enable = true;
      package = pkgs.ripgrep;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
    home.shellAliases = {
      grep = "${pkgs.ripgrep}/bin/rg";
    };
    home.file.".config/bash/conf.d/ripgrep.sh".text = ''
      export RIPGREP_CONFIG_PATH="${pkgs.ripgrep}/share/ripgreprc"
      alias grep="rg"
    '';
  };
}
