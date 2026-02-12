{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.programs.terminal.tools.zellij;
  themeCfg = config.aytordev.theme;
  inherit (themeCfg) palette;

  zns = "zellij -s $(basename $(pwd)) options --default-cwd $(pwd)";
  zas = "zellij a $(basename $(pwd))";
  zo = ''
    session_name=$(basename "$(pwd)")
    zellij attach --create "$session_name" options --default-cwd "$(pwd)"
  '';
in {
  imports = [
    ./keybinds.nix
    ./layouts/dev.nix
    ./layouts/system.nix
  ];
  options.aytordev.programs.terminal.tools.zellij = {
    enable = lib.mkEnableOption "zellij";
  };
  config = mkIf cfg.enable {
    programs = {
      bash.shellAliases = {
        inherit zns zas zo;
      };
      zsh.shellAliases = {
        inherit zns zas zo;
      };
      zellij = {
        enable = true;
        settings = {
          copy_command =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "pbcopy"
            else "";
          auto_layouts = true;
          default_layout = "dev";
          default_mode = "locked";
          support_kitty_keyboard_protocol = true;
          on_force_close = "quit";
          pane_frames = true;
          pane_viewport_serialization = true;
          scrollback_lines_to_serialize = 1000;
          session_serialization = true;
          ui.pane_frames = {
            rounded_corners = true;
            hide_session_name = true;
          };
          plugins = {
            tab-bar.path = "tab-bar";
            status-bar.path = "status-bar";
            strider.path = "strider";
            compact-bar.path = "compact-bar";
          };
          theme = themeCfg.appTheme.kebab;
          themes."${themeCfg.appTheme.kebab}" = {
            bg = palette.bg.hex;
            fg = palette.fg.hex;
            red = palette.red.hex;
            green = palette.green.hex;
            yellow = palette.yellow.hex;
            blue = palette.accent.hex;
            magenta = palette.violet.hex;
            orange = palette.orange.hex;
            cyan = palette.cyan.hex;
            black = palette.bg_dim.hex;
            white = palette.fg_reverse.hex;
          };
        };
      };
    };
  };
}
