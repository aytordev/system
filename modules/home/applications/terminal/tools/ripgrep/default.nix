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
        # Don't have ripgrep vomit a bunch of stuff on the screen
        "--max-columns=150"
        "--max-columns-preview"

        # Ignore git files
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
