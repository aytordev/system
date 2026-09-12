{
  config,
  inputs,
  lib,
  pkgs,
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
  theme = config.aytordev.theme;

  # Map the global theme onto the Neovim distribution contract. Sora is
  # dark-only, so its synthetic `light` companion has no Neovim colorscheme and
  # the editor keeps its built-in default instead of silently using the dark one.
  isSoraLight = theme.name == "sora" && theme.variant == "light";
  colorscheme =
    if isSoraLight
    then "none"
    else theme.name;
  style =
    if theme.name == "sora"
    then "dark"
    else theme.variant;

  neovim = inputs.aytordev-nvim.lib.mkAytordevNeovim {
    inherit pkgs;
    name = "aytordev-nvim";
    extraModules = [
      {
        config.aytordev = {
          inherit colorscheme style;
          transparent = false;
        };
      }
    ];
  };
in {
  options.aytordev.programs.terminal.editors.neovim = {
    enable = mkEnableOption "Neovim";
    package = mkOption {
      type = types.package;
      default = neovim;
      description = "The Neovim package to install. It is rebuilt with the colorscheme selected by aytordev.theme.";
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
