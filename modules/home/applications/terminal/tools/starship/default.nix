{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.applications.terminal.tools.starship;
in {
  options.applications.terminal.tools.starship = {
    enable = mkEnableOption "Starship prompt";
    
    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Starship integration with ZSH";
    };
    
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Starship configuration options";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ pkgs.starship ];
      
      xdg.configFile."starship.toml".source = 
        pkgs.writeText "starship.toml" (builtins.toJSON cfg.settings);
    }
    
    (mkIf (cfg.enable && cfg.enableZshIntegration) {
      programs.zsh.initContent = ''
        # Initialize Starship
        eval "$(starship init zsh)"
      '';
    })
  ]);
}
