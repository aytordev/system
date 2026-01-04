{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.applications.terminal.tools.direnv;
in {
  options.aytordev.applications.terminal.tools.direnv = {
    enable = mkEnableOption "direnv - A shell extension that manages your environment";
    nix-direnv = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nix-direnv for faster and more persistent Nix shell environments";
    };
    silent = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to silence direnv output by default";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        direnv
      ];
    }
    (mkIf cfg.nix-direnv {
      home.packages = with pkgs; [
        nix-direnv
      ];
      home.file.".config/nix-direnv/nix-direnv.toml".text = ''
        [nix]
        enable = true
      '';
    })
    {
      applications.direnv = {
        enable = true;
        nix-direnv.enable = cfg.nix-direnv;
        silent = cfg.silent;
        config = mkIf cfg.nix-direnv {
          whitelist = {
            prefix = [
              "${config.home.homeDirectory}/Developer"
            ];
          };
        };
      };
    }
  ]);
}
