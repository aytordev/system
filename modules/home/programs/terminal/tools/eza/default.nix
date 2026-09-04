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
  config = mkIf cfg.enable (
    let
      si = lib.aytordev.shellIntegration config;
      eza = getExe cfg.package;
    in {
      programs.eza =
        {
          enable = true;
          inherit (cfg) package;
          extraOptions = [
            "--group-directories-first"
            "--header"
            "--hyperlink"
            "--follow-symlinks"
          ];
          git = true;
          icons = "auto";
        }
        // {
          # bash/fish/zsh integrations (ls/ll/la/lt/lla) reach those shells;
          # nushell keeps its structured `ls`, so we do NOT enable nushell
          # integration and do NOT put `ls` in home.shellAliases.
          inherit
            (si.flags)
            enableBashIntegration
            enableFishIntegration
            enableZshIntegration
            ;
        };
      # Shell-agnostic listing aliases (no `ls`, which would shadow nushell's
      # built-in structured `ls`). These override the HM module's minimal
      # defaults in bash/zsh/fish and reach nushell too.
      home.shellAliases = {
        la = "${eza} -la --group-directories-first --header --icons=auto --git --tree";
        ll = "${eza} -l --group-directories-first --header --icons=auto --git";
        lt = "${eza} --tree --level=2 --group-directories-first --icons=auto";
        tree = "${eza} --tree --icons=always";
      };
    }
  );
}
