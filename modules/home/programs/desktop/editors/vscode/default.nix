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

  vscodeTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  vscodeIntegration = themeCfg.integrations.${themeCfg.name}.vscode or null;

  # Palette theme label for a variant of the active family. Used whenever the
  # family ships no covering official resource (Sora).
  generatedLabel = variant:
    vscodeTheme.generatedThemeLabel {
      inherit (providerMeta) displayName;
      inherit variant;
    };

  resolve = variant: override:
    vscodeTheme.resolve {
      inherit variant override;
      integration = vscodeIntegration;
      generated = generatedLabel variant;
    };

  # The active variant drives `workbench.colorTheme` and honours the override;
  # the preferred dark/light themes follow the family integration regardless of
  # the override.
  activeResolution = resolve themeCfg.variant cfg.theme;
  darkResolution = resolve providerMeta.darkVariant null;
  lightResolution = resolve providerMeta.lightVariant null;

  # `none` opts the whole app out: no selection, no preferred themes and no
  # generated extension.
  selectionEnabled = activeResolution.kind != "none";
  themeName =
    if selectionEnabled
    then activeResolution.id
    else null;
  themeDark =
    if selectionEnabled && darkResolution.kind != "none"
    then darkResolution.id
    else null;
  themeLight =
    if selectionEnabled && lightResolution.kind != "none"
    then lightResolution.id
    else null;

  # Every generated resolution the active family needs a theme for.
  generatedVariants = lib.unique (
    map (pair: pair.variant) (
      builtins.filter (pair: pair.resolution.kind == "generated") [
        {
          resolution = activeResolution;
          inherit (themeCfg) variant;
        }
        {
          resolution = darkResolution;
          variant = providerMeta.darkVariant;
        }
        {
          resolution = lightResolution;
          variant = providerMeta.lightVariant;
        }
      ]
    )
  );

  generatedThemes =
    map (
      variant:
        vscodeTheme.mkTheme {
          family = themeCfg.name;
          inherit (providerMeta) displayName;
          inherit variant;
          palette = providerMeta.variants.${variant};
          ansi = providerMeta.ansi.${variant};
          isLight = variant == providerMeta.lightVariant;
        }
    )
    generatedVariants;

  # A real, self-contained VS Code extension built from the shared palette. It
  # is only referenced when the resolver selects a generated theme, so an
  # official family never evaluates or builds it.
  generatedSrcName = "${vscodeTheme.generatedExtensionName themeCfg.name}-src";
  generatedSrc = pkgs.runCommand generatedSrcName {} ''
    mkdir -p "$out/themes"
    cp ${
      pkgs.writeText "package.json" (
        builtins.toJSON (
          vscodeTheme.manifest {
            family = themeCfg.name;
            inherit (providerMeta) displayName;
            themes = generatedThemes;
          }
        )
      )
    } "$out/package.json"
    ${lib.concatMapStrings (theme: ''
        cp ${pkgs.writeText (builtins.baseNameOf theme.path) (builtins.toJSON theme.json)} "$out/themes/${builtins.baseNameOf theme.path}"
      '')
      generatedThemes}
  '';

  generatedExtension = pkgs.vscode-utils.buildVscodeExtension {
    pname = vscodeTheme.generatedExtensionName themeCfg.name;
    version = "1.0.0";
    vscodeExtPublisher = "aytordev";
    vscodeExtName = vscodeTheme.generatedExtensionName themeCfg.name;
    vscodeExtUniqueId = "aytordev.${vscodeTheme.generatedExtensionName themeCfg.name}";

    src = generatedSrc;
    # The default `sourceRoot` is "extension" (VSIX layout); a directory `src`
    # unpacks to its hash-stripped store name, so point the build there and let
    # the default install phase move package.json and themes/ together.
    sourceRoot = generatedSrcName;
  };

  # Resolutions are only offered to the composer while the app is selected, so
  # `none` never drags the generated extension into the profile.
  profileResolutions =
    if selectionEnabled
    then [
      activeResolution
      darkResolution
      lightResolution
    ]
    else [];

  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family integration (or generated theme), manual pins id, none leaves VS Code's default.";
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
        integration resolver, falling back to a palette-generated extension when
        the family ships no official theme. A bare theme label, or
        `{ mode = "manual"; id = ...; }`, pins a theme; `{ mode = "none"; }`
        leaves VS Code's own default and installs no generated extension.
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

        nixExtensions = [
          pkgs.vscode-extensions.arrterian.nix-env-selector
          pkgs.vscode-extensions.bbenoist.nix
          pkgs.vscode-extensions.mkhl.direnv
        ];

        # The generated extension is appended to every profile, and only when a
        # generated resolution is active.
        mkExtensions = base:
          vscodeTheme.profileExtensions {
            inherit base;
            resolutions = profileResolutions;
            inherit generatedExtension;
          };

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
          extensions = mkExtensions commonExtensions;
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          userSettings = commonSettings;
        };
        Nix = {
          extensions = mkExtensions (commonExtensions ++ nixExtensions);
        };
      };
    };
  };
}
