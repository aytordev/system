{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;

  themeCfg = config.aytordev.theme;
  cfg = config.aytordev.programs.desktop.editors.vscode;
in {
  options.aytordev.programs.desktop.editors.vscode = {
    enable = mkEnableOption "Whether or not to enable vscode";
    package = mkPackageOption pkgs "vscode" {};
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      inherit (cfg) package;

      profiles = let
        kanagawa-theme = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "kanagawa-vscode-color-theme";
            publisher = "metaphor";
            version = "0.5.0";
            sha256 = "1l2y5ch6im9qff15kqlxf4j0wxbzl354pqrbby5ybbz76pbjzkis";
          };
        };

        commonExtensions = with pkgs.vscode-extensions; [
          # Kanagawa theme
          kanagawa-theme
          catppuccin.catppuccin-vsc-icons
          github.copilot
          github.copilot-chat
        ];

        commonSettings = import ./settings.nix {inherit lib themeCfg;};
      in {
        default = {
          extensions = commonExtensions;
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          userSettings = commonSettings;
        };
        Nix = {
          extensions = with pkgs.vscode-extensions;
            commonExtensions
            ++ [
              arrterian.nix-env-selector
              bbenoist.nix
              mkhl.direnv
            ];
        };
      };
    };
  };
}
