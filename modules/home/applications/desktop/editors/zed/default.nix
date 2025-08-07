{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.desktop.editors.zed;
  
in {
  options.applications.desktop.editors.zed = {
    enable = mkEnableOption "Whether or not to enable zed-editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;

      # Main settings
      userSettings = {
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
        theme = "Catppuccin Mocha";
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
        # Uncomment below to use local AI with Ollama, refer https://zed.dev/docs/language-model-integration?highlight=ollama#using-ollama-on-macos
        # "assistant": {
        #   "default_model": {
        #     "provider": "ollama",
        #     "model": "llama3.1:latest"
        #   },
        #   "version": "2",
        #   "provider": null
        # },
        language_models = {
          ollama = {
            api_url = "http://localhost:11434";
          };
        };
        # Inlay hints preconfigured by Zed: Go, Rust, Typescript and Svelte
        inlay_hints = {
          enabled = true;
        };
        # LSP
        lsp = {
          "tailwindcss-language-server" = {
            "settings" = {
              "classAttributes" = ["class" "className" "ngClass" "styles"];
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
            "format_on_save" = { "language_server" = { "name" = "ruff"; }; };
            "formatter" = { "language_server" = { "name" = "ruff"; }; };
            "language_servers" = ["pyright" "ruff"];};
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
          "Dockerfile" = ["Dockerfile" "Dockerfile.*"];
          "JSON" = ["json" "jsonc" "*.code-snippets"];
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
      };
    };
  };
}
