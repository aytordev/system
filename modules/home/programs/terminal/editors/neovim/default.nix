{
  config,
  inputs,
  lib,
  system,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.aytordev) mkBoolOpt;

  cfg = config.aytordev.programs.terminal.editors.neovim;

  neovim = inputs.aytordev-nvim.packages.${system}.default;
in {
  options.aytordev.programs.terminal.editors.neovim = {
    enable = mkEnableOption "Neovim";
    package = mkOption {
      type = types.package;
      default = neovim;
      description = "The Neovim package to install.";
    };
    default = mkBoolOpt true "Whether to set Neovim as the session EDITOR";
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = mkIf cfg.default {
        EDITOR = "nvim";
        MANPAGER = "nvim -c 'set ft=man bt=nowrite noswapfile nobk shada=\"NONE\" ro noma' +Man! -o -";
      };

      packages = [
        cfg.package
      ];
    };
  };
}
