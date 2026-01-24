{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  themeCfg = config.aytordev.theme;
  cfg = config.aytordev.programs.desktop.editors.vscode;
in {
  options.aytordev.programs.desktop.editors.vscode = {
    enable = mkEnableOption "Whether or not to enable vscode";
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

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

        commonSettings = {
          # Breadcrumbs
          "breadcrumbs.filePath" = "off";
          "breadcrumbs.enabled" = true;

          # Debug
          "debug.console.fontFamily" = lib.mkForce "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "debug.openDebug" = "neverOpen";
          "debug.showInStatusBar" = "never";
          "debug.toolBarLocation" = "hidden";
          "debug.console.fontSize" = 18;

          # Editor
          "editor.bracketPairColorization.enabled" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = "explicit";
          };
          "editor.formatOnSave" = true;
          "editor.guides.indentation" = true;
          "editor.renderLineHighlight" = "gutter";
          "editor.hideCursorInOverviewRuler" = true;
          "editor.scrollBeyondLastLine" = false;
          "editor.lineHeight" = 32;
          "editor.occurrencesHighlight" = "off";
          "editor.overviewRulerBorder" = false;
          "editor.folding" = false;
          "editor.inlayHints.fontFamily" = lib.mkForce "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "editor.inlineSuggest.enabled" = true;
          "editor.snippetSuggestions" = "top";
          "editor.lightbulb.enabled" = "off";
          "editor.guides.bracketPairs" = true;
          "editor.minimap.enabled" = false;
          "editor.minimap.renderCharacters" = false;
          "editor.smoothScrolling" = true;
          "editor.suggestSelection" = "first";
          "editor.cursorBlinking" = "solid";
          "editor.cursorStyle" = "line";
          "editor.fontFamily" =
            lib.mkForce "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "editor.codeLensFontFamily" =
            lib.mkForce "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "editor.fontLigatures" = true;
          "editor.fontSize" = 16;

          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[dockerfile]" = {
            "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
          };
          "[gitconfig]" = {
            "editor.defaultFormatter" = "yy0931.gitconfig-lsp";
          };
          "[html]" = {
            "editor.defaultFormatter" = "vscode.html-language-features";
          };
          "[javascript]" = {
            "editor.defaultFormatter" = "vscode.typescript-language-features";
          };
          "[json]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
          };
          "[lua]" = {
            "editor.defaultFormatter" = "yinfei.luahelper";
          };
          "[shellscript]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[xml]" = {
            "editor.defaultFormatter" = "redhat.vscode-xml";
          };

          # Error Lens
          "errorLens.enableOnDiffView" = true;
          "errorLens.fontFamily" = "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "errorLens.fontSize" = "16px";
          "errorLens.fontStyleItalic" = true;
          "errorLens.gutterIconSet" = "defaultOutline";

          # Explorer
          "explorer.openEditors.visible" = 0;
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.decorations.badges" = false;
          "extensions.ignoreRecommendations" = true;

          # Files
          "files.exclude" = {
            "**/node_modules/" = false;
            "**/.git" = true;
            "**/.next" = true;
            "**/.DS_Store" = true;
            "**/package-lock.json" = false;
            "**/yarn.lock" = true;
            "vendor" = true;
            "**/npm-debug.log" = true;
            "**/dist" = false;
            "**/*.bs.js" = true;
          };
          "files.associations" = {
            "*.toml" = "toml";
            "*.njk" = "html";
            ".env*" = "dotenv";
          };
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "files.eol" = "\n";

          # Git settings
          "git.allowForcePush" = true;
          "git.autofetch" = true;
          "git.blame.editorDecoration.enabled" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "git.openRepositoryInParentFolders" = "always";
          "gitlens.gitCommands.skipConfirmations" = [
            "fetch:command"
            "stash-push:command"
            "switch:command"
            "branch-create:command"
          ];

          # Github Copilot
          "github.copilot.advanced" = {};
          "github.copilot.enable" = {
            "*" = true;
            "yaml" = false;
            "plaintext" = false;
            "markdown" = false;
          };

          # Search
          "search.quickOpen.includeHistory" = false;
          "search.searchEditor.defaultNumberOfContextLines" = null;
          "search.smartCase" = true;
          "search.exclude" = {
            "**/node_modules" = true;
            "**/.git" = true;
            "dist" = true;
            "out" = true;
            "coverage" = true;
          };

          # Terminal
          "terminal.external.osxExec" = "ghostty.app";
          "terminal.integrated.fontFamily" =
            lib.mkForce "MonaspiceNe Nerd Font Mono, MonaspiceNe Nerd Font Propo, Monaspace Neon, monospace";
          "terminal.integrated.copyOnSelection" = true;
          "terminal.integrated.fontSize" = 16;
          "terminal.integrated.inheritEnv" = false;
          "terminal.integrated.cursorBlinking" = true;
          "terminal.integrated.defaultProfile.linux" = "fish";
          "terminal.integrated.enableVisualBell" = false;
          "terminal.integrated.gpuAcceleration" = "on";

          # Window
          "window.autoDetectColorScheme" = true;
          "window.restoreWindows" = "all";
          "window.newWindowDimensions" = "maximized";

          # Workbench
          "workbench.editor.enablePreviewFromQuickOpen" = true;
          "workbench.editor.tabCloseButton" = "left";
          "workbench.colorTheme" = lib.mkDefault themeCfg.appTheme.capitalized;
          "workbench.preferredDarkColorTheme" = lib.mkDefault themeCfg.appTheme.capitalized;
          "workbench.preferredLightColorTheme" = lib.mkDefault "Kanagawa Lotus";
          "workbench.list.horizontalScrolling" = true;
          "workbench.panel.defaultLocation" = "right";
          "workbench.fontAliasing" = "antialiased";
          "workbench.startupEditor" = "none";
          "workbench.settings.editor" = "json";
          "workbench.editor.showIcons" = true;
          "workbench.editor.showTabs" = "single";
          "workbench.settings.enableNaturalLanguageSearch" = false; # formatting only supports LF line endings
          "workbench.sideBar.location" = "right";
          "workbench.iconTheme" = "catppuccin-mocha";
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
