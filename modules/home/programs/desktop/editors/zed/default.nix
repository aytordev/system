{
  config,
  lib,
  pkgs,
  ...
} @ args: let
  pkgs-stable = args.pkgs-stable or pkgs;
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.programs.desktop.editors.zed;
in {
  options.aytordev.programs.desktop.editors.zed = {
    enable = mkEnableOption "Whether or not to enable zed-editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;

      # Extensions - https://github.com/zed-industries/extensions/tree/main/extensions
      extensions = [
        "catppuccin"
        "catppuccin-icons"
      ];

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
            "format_on_save" = {"language_server" = {"name" = "ruff";};};
            "formatter" = {"language_server" = {"name" = "ruff";};};
            "language_servers" = ["pyright" "ruff"];
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

      userKeymaps = [
        # keymap.json, generated at Sat Mar 22 2025 17:00:58 GMT+0800 (Singapore Standard Time)
        {
          "context" = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
          "bindings" = {
            # put key-bindings here if you want them to work in normal & visual mode
            # Git
            "space g h d" = "editor::ToggleSelectedDiffHunks";
            "space g s" = "git_panel::ToggleFocus";

            # Toggle inlay hints
            "space t i" = "editor::ToggleInlayHints";

            # Toggle soft wrap
            "space u w" = "editor::ToggleSoftWrap";

            # NOTE: Toggle Zen mode, not fully working yet
            "space c z" = "workspace::ToggleCenteredLayout";

            # Open markdown preview
            "space m p" = "markdown::OpenPreview";
            "space m P" = "markdown::OpenPreviewToTheSide";

            # Open recent project
            "space f p" = "projects::OpenRecent";

            # Search word under cursor
            "space s w" = "pane::DeploySearch";

            # Chat with AI
            "space a c" = "agent::ToggleFocus";

            # Go to file with `gf`
            "g f" = "editor::OpenExcerpts";
          };
        }
        {
          "context" = "Editor && vim_mode == normal && !VimWaiting && !menu";
          "bindings" = {
            # put key-bindings here if you want them to work only in normal mode
            # Window movement bindings
            # Ctrl jklk to move between panes
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";

            # +LSP
            "space c a" = "editor::ToggleCodeActions";
            "space ." = "editor::ToggleCodeActions";
            "space c r" = "editor::Rename";
            "g d" = "editor::GoToDefinition";
            "g D" = "editor::GoToDefinitionSplit";
            "g i" = "editor::GoToImplementation";
            "g I" = "editor::GoToImplementationSplit";
            "g t" = "editor::GoToTypeDefinition";
            "g T" = "editor::GoToTypeDefinitionSplit";
            "g r" = "editor::FindAllReferences";
            "] d" = "editor::GoToDiagnostic";
            "[ d" = "editor::GoToPreviousDiagnostic";
            # TODO: Go to next/prev error
            "] e" = "editor::GoToDiagnostic";
            "[ e" = "editor::GoToPreviousDiagnostic";

            # Symbol search
            "s s" = "outline::Toggle";
            "s S" = "project_symbols::Toggle";

            # Diagnostic
            "space x x" = "diagnostics::Deploy";

            # +Git
            # Git prev/next hunk
            "] h" = "editor::GoToHunk";
            "[ h" = "editor::GoToPreviousHunk";

            # TODO: git diff is not ready yet, refer https://github.com/zed-industries/zed/issues/8665#issuecomment-2194000497

            # + Buffers
            # Switch between buffers
            "shift-h" = "pane::ActivatePreviousItem";
            "shift-l" = "pane::ActivateNextItem";
            # Close active panel
            "shift-q" = "pane::CloseActiveItem";
            "ctrl-q" = "pane::CloseActiveItem";
            "space b d" = "pane::CloseActiveItem";
            # Close other items
            "space b o" = "pane::CloseOtherItems";
            # Save file
            "ctrl-s" = "workspace::Save";

            # File finder
            "space space" = "file_finder::Toggle";

            # Project search
            "space /" = "pane::DeploySearch";

            # TODO: Open other files

            # Show project panel with current file
            "space e" = "pane::RevealInProjectPanel";
          };
        }
        # Empty pane, set of keybindings that are available when there is no active editor
        {
          "context" = "EmptyPane || SharedScreen";
          "bindings" = {
            # Open file finder
            "space space" = "file_finder::Toggle";
            # Open recent project
            "space f p" = "projects::OpenRecent";
          };
        }
        # Comment code
        {
          "context" = "Editor && vim_mode == visual && !VimWaiting && !menu";
          "bindings" = {
            # visual, visual line & visual block modes
            "g c" = "editor::ToggleComments";
          };
        }
        # Better escape
        {
          "context" = "Editor && vim_mode == insert && !menu";
          "bindings" = {
            "j j" = "vim::NormalBefore"; # remap jj in insert mode to escape
            "j k" = "vim::NormalBefore"; # remap jk in insert mode to escape
          };
        }
        # Rename
        {
          "context" = "Editor && vim_operator == c";
          "bindings" = {
            "c" = "vim::CurrentLine";
            "r" = "editor::Rename"; # zed specific
          };
        }
        # Code Action
        {
          "context" = "Editor && vim_operator == c";
          "bindings" = {
            "c" = "vim::CurrentLine";
            "a" = "editor::ToggleCodeActions"; # zed specific
          };
        }
        # Toggle terminal
        {
          "context" = "Workspace";
          "bindings" = {
            "ctrl-\\" = "terminal_panel::ToggleFocus";
          };
        }
        {
          "context" = "Terminal";
          "bindings" = {
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";
          };
        }
        # File panel (netrw)
        {
          "context" = "ProjectPanel && not_editing";
          "bindings" = {
            "a" = "project_panel::NewFile";
            "A" = "project_panel::NewDirectory";
            "r" = "project_panel::Rename";
            "d" = "project_panel::Delete";
            "x" = "project_panel::Cut";
            "c" = "project_panel::Copy";
            "p" = "project_panel::Paste";
            # Close project panel as project file panel on the right
            "q" = "workspace::ToggleRightDock";
            "space e" = "workspace::ToggleRightDock";
            # Navigate between panel
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";
          };
        }
        # Panel nagivation
        {
          "context" = "Dock";
          "bindings" = {
            "ctrl-w h" = "workspace::ActivatePaneLeft";
            "ctrl-w l" = "workspace::ActivatePaneRight";
            "ctrl-w k" = "workspace::ActivatePaneUp";
            "ctrl-w j" = "workspace::ActivatePaneDown";
          };
        }
        {
          "context" = "Workspace";
          "bindings" = {
            # Map VSCode like keybindings
            "cmd-b" = "workspace::ToggleRightDock";
          };
        }
        # Run nearest task
        {
          "context" = "EmptyPane || SharedScreen || vim_mode == normal";
          "bindings" = {
            "space r t" = ["editor::SpawnNearestTask" {"reveal" = "no_focus";}];
          };
        }
        # Sneak motion, refer https://github.com/zed-industries/zed/pull/22793/files#diff-90c0cb07588e2f309c31f0bb17096728b8f4e0bad71f3152d4d81ca867321c68
        {
          "context" = "vim_mode == normal || vim_mode == visual";
          "bindings" = {
            "s" = ["vim::PushSneak" {}];
            "S" = ["vim::PushSneakBackward" {}];
          };
        }
        # Subword motion is not working really nice with `ciw`, disable for now
        # {
        #   "context": "VimControl && !menu",
        #   "bindings": {
        #     "w": "vim::NextSubwordStart",
        #     "b": "vim::PreviousSubwordStart",
        #     "e": "vim::NextSubwordEnd",
        #     "g e": "vim::PreviousSubwordEnd"
        #   }
        # }
      ];
    };
  };
}
