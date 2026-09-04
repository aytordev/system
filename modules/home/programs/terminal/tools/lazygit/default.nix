{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.lazygit;
in {
  options.aytordev.programs.terminal.tools.lazygit = {
    enable = mkEnableOption "lazygit";
    package = mkPackageOption pkgs "lazygit" {};
  };
  config = mkIf cfg.enable {
    programs.lazygit =
      {
        enable = true;
        inherit (cfg) package;
        settings = {
          customCommands = import ./custom-commands.nix;
          gui = {
            authorColors = {
              "${config.aytordev.user.fullName}" = "#957fb8";
              "dependabot[bot]" = "#c0a36e";
            };
            branchColors = {
              main = "#c34043";
              master = "#c34043";
              dev = "#7e9cd8";
            };
            nerdFontsVersion = "3";
            showListFooter = false;
            showRandomTip = false;
            expandFocusedSidePanel = true;
          };
          git = {
            overrideGpg = true;
            mainBranches = [
              "main"
              "master"
            ];
          };
          os = {
            editPreset = "nvim";
          };
        };
      }
      // (lib.aytordev.shellIntegration config).flags;
    # The shell-integration wrapper owns `lg` (lazygit + cd on exit). No manual
    # alias/conf.d: a bare alias would shadow the wrapper in bash/fish/nushell.
  };
}
