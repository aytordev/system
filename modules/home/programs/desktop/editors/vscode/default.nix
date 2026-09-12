{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  themeCfg = config.aytordev.theme;
  cfg = config.aytordev.programs.desktop.editors.vscode;

  nativeTheme = builtins.elem "vscode" themeCfg.nativeApps;

  # Explicit override wins; otherwise only select a theme for a supported family.
  themeName =
    if cfg.theme != null
    then cfg.theme
    else if nativeTheme
    then themeCfg.appTheme.capitalized
    else null;
  themeDark =
    if nativeTheme
    then themeCfg.appThemeDark.capitalized
    else null;
  themeLight =
    if nativeTheme
    then themeCfg.appThemeLight.capitalized
    else null;
in {
  options.aytordev.programs.desktop.editors.vscode = {
    enable = mkEnableOption "Whether or not to enable vscode";
    package = mkPackageOption pkgs "vscode" {};
    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Explicit VS Code color theme override. Use when the active family is not natively supported.";
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      inherit (cfg) package;

      profiles = let
        kanagawa-theme = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "kanagawa-vscode-color-theme";
            publisher = "metaphore";
            version = "0.5.0";
            sha256 = "sha256-Os4v1zXnr+WLXyvjS8qgf3UOJHGd4lmCczjVaCArXtA=";
          };
        };

        commonExtensions = with pkgs.vscode-extensions; [
          # Theme families supported by aytordev.theme
          kanagawa-theme
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          github.copilot
          github.copilot-chat
        ];

        commonSettings = import ./settings.nix {
          inherit
            lib
            themeName
            themeDark
            themeLight
            ;
        };
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
