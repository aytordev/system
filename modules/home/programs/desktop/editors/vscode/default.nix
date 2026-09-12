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
  providerMeta = themeCfg.providers.${themeCfg.name};

  vscodeIntegration = themeCfg.integrations.${themeCfg.name}.vscode or null;

  # Hand `resolveApp` the integration only when it covers the requested variant;
  # a dark-only family (Sora) therefore yields "none" for its light companion.
  selectOfficial = variant:
    if !(lib.isAttrs vscodeIntegration)
    then vscodeIntegration
    else if !(vscodeIntegration ? variants)
    then vscodeIntegration
    else if (vscodeIntegration.variants or {}) ? ${variant}
    then vscodeIntegration
    else null;

  resolve = variant: override:
    lib.aytordev.resolveApp {
      app = "vscode";
      inherit variant override;
      official = selectOfficial variant;
      generated = null;
    };

  # The active variant drives `workbench.colorTheme` and honours the override;
  # the preferred dark/light themes follow the family integration regardless of
  # the override, matching the previous behaviour.
  activeResolution = resolve themeCfg.variant cfg.theme;
  darkResolution = resolve providerMeta.darkVariant null;
  lightResolution = resolve providerMeta.lightVariant null;

  themeName =
    if activeResolution.kind == "none"
    then null
    else activeResolution.id;
  themeDark =
    if darkResolution.kind == "none"
    then null
    else darkResolution.id;
  themeLight =
    if lightResolution.kind == "none"
    then null
    else lightResolution.id;

  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family integration, manual pins id, none leaves VS Code's default.";
      };
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Color theme label to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.desktop.editors.vscode = {
    enable = mkEnableOption "Whether or not to enable vscode";
    package = mkPackageOption pkgs "vscode" {};
    theme = mkOption {
      type = types.nullOr (types.either types.str themeOverrideType);
      default = null;
      description = ''
        VS Code color theme override. Null follows `aytordev.theme` through the
        integration resolver. A bare theme label, or
        `{ mode = "manual"; id = ...; }`, pins a theme; `{ mode = "none"; }`
        leaves VS Code's own default.
      '';
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
