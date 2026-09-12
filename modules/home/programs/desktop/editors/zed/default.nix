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

  cfg = config.aytordev.programs.desktop.editors.zed;

  # Hybrid theme resolution: the exact official extension theme when the active
  # family ships one for the active variant, otherwise a palette-generated
  # theme JSON written under Zed's local themes directory.
  zedTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  zedIntegration = themeCfg.integrations.${themeCfg.name}.zed or null;
  generatedTheme = zedTheme.render {
    inherit (themeCfg) palette ansi isLight;
  };
  themeResolution = zedTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = zedIntegration;
  };
  themeSettings = zedTheme.themeSetting themeResolution;
  # Materialize the generated theme JSON only when the resolver selected it.
  generatedFiles = zedTheme.themeFiles {
    resolution = themeResolution;
    text = generatedTheme;
  };

  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family integration, manual pins id, none leaves Zed's default.";
      };
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Theme name to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.desktop.editors.zed = {
    enable = mkEnableOption "Whether or not to enable zed-editor";
    package = mkPackageOption pkgs "zed-editor" {};
    theme = mkOption {
      type = types.nullOr (types.either types.str themeOverrideType);
      default = null;
      description = ''
        Zed theme override. Null follows `aytordev.theme` through the integration
        resolver. A bare theme name, or `{ mode = "manual"; id = ...; }`, pins a
        theme; `{ mode = "none"; }` leaves Zed's own default.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      inherit (cfg) package;

      # Extensions - https://github.com/zed-industries/extensions/tree/main/extensions
      extensions = [
        "kanagawa-themes"
        "catppuccin"
        "sora-theme"
        "catppuccin-icons"
      ];

      # Main settings
      userSettings =
        {
          # settings.json, generated at Sat Mar 22 2025 17:00:58 GMT+0800 (Singapore Standard Time)
          # Zed settings
          #
          # For information on how to configure Zed, see the Zed
          # documentation: https://zed.dev/docs/configuring-zed
          #
          # To see all of Zed's default settings without changing your
          # custom settings, run the `open default settings` command
          # from the command palette or from `Zed` application menu.

          git_panel = {
            dock = "right";
          };
          icon_theme = "Catppuccin Mocha";
          features = {
            edit_prediction_provider = "zed";
          };
          base_keymap = "VSCode";
          ui_font_size = 16;
          buffer_font_size = 18;
          # Finder model width
          file_finder = {
            modal_width = "medium";
          };
          # NOTE: Change the font family to your preference
          buffer_font_family = "MonaspiceNe Nerd Font Mono";
          # Vim mode settings
          vim_mode = true;
          vim = {
            enable_vim_sneak = true;
          };
          # use relative line numbers
          relative_line_numbers = true;
          tab_bar = {
            show = true;
          };
          scrollbar = {
            show = "never";
          };
          # Only show error on tab
          tabs = {
            show_diagnostics = "errors";
          };
          # Indentation, rainbow indentation
          indent_guides = {
            enabled = true;
            coloring = "indent_aware";
          };
          # NOTE: Zen mode, refer https://github.com/zed-industries/zed/issues/4382 when it's resolved
          centered_layout = {
            left_padding = 0.15;
            right_padding = 0.15;
          };
          # Use Copilot Chat AI as default
          assistant = {
            default_model = {
              provider = "copilot_chat";
              model = "claude-3-7-sonnet";
            };
            version = "2";
          };
          # Inlay hints preconfigured by Zed: Go, Rust, Typescript and Svelte
          inlay_hints = {
            enabled = true;
          };
          # LSP
          lsp = {
            "tailwindcss-language-server" = {
              "settings" = {
                "classAttributes" = [
                  "class"
                  "className"
                  "ngClass"
                  "styles"
                ];
              };
            };
          };
          languages = {
            # Refer https://zed.dev/docs/languages/javascript and https://zed.dev/docs/languages/typescript for more info
            "TypeScript" = {
              # Refer https://github.com/jellydn/ts-inlay-hints for how to setup for Neovim and VSCode
              "inlay_hints" = {
                "enabled" = true;
                "show_parameter_hints" = false;
                "show_other_hints" = true;
                "show_type_hints" = true;
              };
            };
            "Python" = {
              "format_on_save" = {
                "language_server" = {
                  "name" = "ruff";
                };
              };
              "formatter" = {
                "language_server" = {
                  "name" = "ruff";
                };
              };
              "language_servers" = [
                "pyright"
                "ruff"
              ];
            };
          };
          # Use zed commit editor
          terminal = {
            "font_family" = "MonaspiceNe Nerd Font Mono";
            "env" = {
              "EDITOR" = "zed --wait";
            };
          };
          # File syntax highlighting
          file_types = {
            "Dockerfile" = [
              "Dockerfile"
              "Dockerfile.*"
            ];
            "JSON" = [
              "json"
              "jsonc"
              "*.code-snippets"
            ];
          };
          # File scan exclusions, hide on the file explorer and search
          file_scan_exclusions = [
            "**/.git"
            "**/.svn"
            "**/.hg"
            "**/CVS"
            "**/.DS_Store"
            "**/Thumbs.db"
            "**/.classpath"
            "**/.settings"
            # above is default from Zed
            "**/out"
            "**/dist"
            "**/.husky"
            "**/.turbo"
            "**/.vscode-test"
            "**/.vscode"
            "**/.next"
            "**/.storybook"
            "**/.tap"
            "**/.nyc_output"
            "**/report"
            "**/node_modules"
          ];
          # Turn off telemetry
          telemetry = {
            "diagnostics" = false;
            "metrics" = false;
          };
          # Move all panel to the right
          project_panel = {
            "button" = true;
            "dock" = "right";
            "git_status" = true;
          };
          outline_panel = {
            "dock" = "right";
          };
          collaboration_panel = {
            "dock" = "left";
          };
          # Move some unnecessary panels to the left
          notification_panel = {
            "dock" = "left";
          };
          chat_panel = {
            "dock" = "left";
          };
        }
        // themeSettings;

      userKeymaps = import ./keymaps.nix;
    };

    # Local generated theme JSON. An official/explicit/opt-out selection writes
    # nothing: those themes come from the installed extensions.
    xdg.configFile = generatedFiles;
  };
}
