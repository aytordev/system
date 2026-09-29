{
  # Owned differences only. The selected snapshot supplies 46 base bindings.
  # Delete a source chord with { context = "..."; chords = ["..."]; } here;
  # a null binding below instead disables that chord in Zed.
  excludedBindings = [];
  blocks = [
    # Adapted from jellydn/zed-101-setup; see README.md and LICENSE.upstream.
    {
      "context" = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
      "bindings" = {
        # Disable Vim's single-space motion, not space input in menus/prompts.
        "space" = null;

        # Git
        "space g h e" = "editor::ExpandAllDiffHunks";
        "space g d" = "git::Diff";
        "space g b" = "editor::ToggleGitBlameInline";

        "alt-j" = "editor::MoveLineDown";
        "alt-k" = "editor::MoveLineUp";

        # Reserve s/S for Sneak; symbol pickers live under the space leader.
        "s" = ["vim::PushSneak" {}];
        "S" = ["vim::PushSneakBackward" {}];

        # Editor actions only; panel/model actions use their native contexts below.
        "space a c" = "agent::ToggleFocus";
        "space a a" = "agent::AddSelectionToThread";
        "space a i" = "assistant::InlineAssist";
      };
    }
    {
      "context" = "Editor && vim_mode == normal && !VimWaiting && !menu";
      "bindings" = {
        # Pane navigation remains available both directly and under the leader.
        "space w v" = "pane::SplitRight";
        "space w s" = "pane::SplitDown";
        "space w h" = "workspace::ActivatePaneLeft";
        "space w j" = "workspace::ActivatePaneDown";
        "space w k" = "workspace::ActivatePaneUp";
        "space w l" = "workspace::ActivatePaneRight";
        "space w >" = "vim::ResizePaneRight";
        "space w <" = "vim::ResizePaneLeft";
        "space w +" = "vim::ResizePaneUp";
        "space w -" = "vim::ResizePaneDown";
        "space w q" = "pane::CloseActiveItem";

        # h is already reserved for Git hunks; i navigates diagnostic hints.
        "] i" = ["editor::GoToDiagnostic" {severity = "hint";}];
        "[ i" = ["editor::GoToPreviousDiagnostic" {severity = "hint";}];

        # Symbol search must not shadow Sneak's two-character motion.
        "space s s" = "outline::Toggle";
        "space s S" = "project_symbols::Toggle";
        "space s b" = "buffer_search::Deploy";

        # Buffers: spaced multi-key chords match Zed's native Vim syntax.
        "[ b" = "pane::ActivatePreviousItem";
        "] b" = "pane::ActivateNextItem";
        "space b p" = "pane::ActivatePreviousItem";
        "space b n" = "pane::ActivateNextItem";
        # File finder (native replacement for upstream's unselected FFF task).
        "space f f" = "file_finder::Toggle";

        # Native project search, without external FFF tasks.
        "space f g" = "pane::DeploySearch";
      };
    }
    # Empty pane, set of keybindings that are available when there is no active editor
    {
      "context" = "(EmptyPane || SharedScreen) && !menu && !VimWaiting";
      "bindings" = {
        "space space" = "file_finder::Toggle";
        "space f f" = "file_finder::Toggle";
        "space f g" = "pane::DeploySearch";
        "space f p" = "projects::OpenRecent";
        "space f n" = "workspace::NewFile";
        "space q q" = "workspace::CloseWindow";
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
      "context" = "Editor && vim_mode == insert && !menu && !VimWaiting";
      "bindings" = {
        "j j" = "vim::NormalBefore"; # remap jj in insert mode to escape
        "j k" = "vim::NormalBefore"; # remap jk in insert mode to escape
      };
    }
    # One change-operator context preserves cc, cr and ca without merge ambiguity.
    {
      "context" = "Editor && vim_operator == c && !VimWaiting && !menu";
      "bindings" = {
        "c" = "vim::CurrentLine";
        "r" = "editor::Rename";
        "a" = "editor::ToggleCodeActions";
      };
    }
    # Modified shortcuts avoid swallowing ordinary typing in agent prompts.
    {
      "context" = "AgentPanel && !menu && !VimWaiting";
      "bindings" = {
        "cmd-n" = "agent::NewThread";
        "cmd-alt-c" = "agent::OpenSettings";
      };
    }
    {
      "context" = "(AcpThread || InlineAssistant) && !menu && !VimWaiting";
      "bindings" = {
        "cmd-alt-/" = "agent::ToggleModelSelector";
      };
    }
    {
      "context" = "Editor && editor_agent_diff && vim_mode == normal && !VimWaiting && !menu";
      "bindings" = {
        "space a d" = "agent::OpenAgentDiff";
      };
    }
    # Toggle terminal
    {
      "context" = "Workspace";
      "bindings" = {
        "ctrl-\\" = "terminal_panel::ToggleFocus";
        "cmd-b" = "workspace::ToggleRightDock";
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
    # Panel navigation
    {
      "context" = "Dock";
      "bindings" = {
        "ctrl-w h" = "workspace::ActivatePaneLeft";
        "ctrl-w l" = "workspace::ActivatePaneRight";
        "ctrl-w k" = "workspace::ActivatePaneUp";
        "ctrl-w j" = "workspace::ActivatePaneDown";
      };
    }
    # Run a project-provided nearest task; this module installs no task commands.
    {
      "context" = "(EmptyPane || SharedScreen || (Editor && vim_mode == normal)) && !VimWaiting && !menu";
      "bindings" = {
        "space r t" = [
          "editor::SpawnNearestTask"
          {"reveal" = "no_focus";}
        ];
      };
    }
  ];
}
