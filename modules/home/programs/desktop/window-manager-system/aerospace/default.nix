{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.window-manager-system.aerospace;
  sketchybar = "${config.programs.sketchybar.package}/bin/sketchybar";
in {
  options = {
    aytordev.programs.desktop.window-manager-system.aerospace = {
      enable = lib.mkEnableOption "Aerospace window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      restart-aerospace = ''launchctl kickstart -k gui/"$(id -u)"/org.nix-community.home.aerospace'';
    };

    home.packages = with pkgs; [
      aerospace
    ];

    programs.aerospace = {
      enable = true;
      package = pkgs.aerospace;
      launchd.enable = true;

      settings = {
        # Config version 2 enables new features like persistent-workspaces
        config-version = 2;

        accordion-padding = 30;
        after-login-command = [];
        after-startup-command = ["exec-and-forget ${sketchybar}"];
        automatically-unhide-macos-hidden-apps = true;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        # Persistent workspaces - always visible in Sketchybar even when empty
        # B = Browsers
        # C = Coding
        # D = Development
        # W = Work
        # S = Social
        # O = Other

        persistent-workspaces = ["B" "C" "D" "W" "S" "O"];

        exec-on-workspace-change = [
          "/bin/bash"
          "-c"
          "${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
        ];

        # Dynamic gaps per monitor
        gaps.inner.horizontal = 10;
        gaps.inner.vertical = 10;
        gaps.outer.left = 7;
        gaps.outer.bottom = 7;
        gaps.outer.top = 32;
        gaps.outer.right = 7;
        key-mapping.preset = "qwerty";

        # Workspace Navigation - Semantic Names
        mode.main.binding.alt-1 = "workspace B";
        mode.main.binding.alt-2 = "workspace C";
        mode.main.binding.alt-3 = "workspace D";
        mode.main.binding.alt-4 = "workspace W";
        mode.main.binding.alt-5 = "workspace S";
        mode.main.binding.alt-6 = "workspace O";

        # Layout Management
        mode.main.binding.alt-comma = "layout accordion horizontal vertical";
        mode.main.binding.alt-slash = "layout tiles horizontal vertical";
        mode.main.binding.alt-shift-f = "layout floating tiling"; # Toggle floating

        # Focus Navigation
        mode.main.binding.alt-ctrl-h = "focus left";
        mode.main.binding.alt-ctrl-j = "focus down";
        mode.main.binding.alt-ctrl-k = "focus up";
        mode.main.binding.alt-ctrl-l = "focus right";

        # Window Movement
        mode.main.binding.alt-shift-h = "move left";
        mode.main.binding.alt-shift-j = "move down";
        mode.main.binding.alt-shift-k = "move up";
        mode.main.binding.alt-shift-l = "move right";

        # Move to Workspace
        mode.main.binding.alt-shift-1 = "move-node-to-workspace B";
        mode.main.binding.alt-shift-2 = "move-node-to-workspace C";
        mode.main.binding.alt-shift-3 = "move-node-to-workspace D";
        mode.main.binding.alt-shift-4 = "move-node-to-workspace W";
        mode.main.binding.alt-shift-5 = "move-node-to-workspace S";
        mode.main.binding.alt-shift-6 = "move-node-to-workspace O";

        # Fullscreen
        mode.main.binding.alt-f = "fullscreen";

        # Resize shortcuts in main mode (no need to enter resize mode)
        mode.main.binding.alt-minus = "resize smart -50";
        mode.main.binding.alt-equal = "resize smart +50";

        # Screenshot to clipboard
        mode.main.binding.alt-shift-s = "exec-and-forget screencapture -i -c";

        # Workspace & Monitor Management
        mode.main.binding.alt-tab = "workspace-back-and-forth";
        mode.main.binding.alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # Mode Switching
        mode.main.binding.alt-r = "mode resize";
        mode.main.binding.alt-shift-semicolon = "mode service";

        # Resize Mode
        mode.resize.binding.h = "resize width -50";
        mode.resize.binding.j = "resize height +50";
        mode.resize.binding.k = "resize height -50";
        mode.resize.binding.l = "resize width +50";
        mode.resize.binding.b = ["balance-sizes" "mode main"];
        mode.resize.binding.equal = "resize smart +50";
        mode.resize.binding.minus = "resize smart -50";
        mode.resize.binding.esc = "mode main";

        # Service Mode
        mode.service.binding.alt-shift-h = ["join-with left" "mode main"];
        mode.service.binding.alt-shift-j = ["join-with down" "mode main"];
        mode.service.binding.alt-shift-k = ["join-with up" "mode main"];
        mode.service.binding.alt-shift-l = ["join-with right" "mode main"];
        mode.service.binding.backspace = ["close-all-windows-but-current" "mode main"];
        mode.service.binding.esc = ["reload-config" "mode main"];
        mode.service.binding.f = ["layout floating tiling" "mode main"];
        mode.service.binding.r = ["flatten-workspace-tree" "mode main"];
        mode.service.binding.up = "volume up";
        mode.service.binding.down = "volume down";
        mode.service.binding.shift-down = ["volume set 0" "mode main"];

        # Callbacks
        on-focus-changed = ["move-mouse window-lazy-center" "exec-and-forget ${sketchybar} --trigger aerospace_focus_change"];
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-mode-changed = ["exec-and-forget ${sketchybar} --trigger aerospace_mode_change"];

        # Multi-Monitor Workspace Assignment
        workspace-to-monitor-force-assignment = {
          B = "main";
          C = "main";
          D = "main";
          W = "main";
          S = "main";
          O = "main";
        };

        # Application-Specific Rules - Floating apps
        on-window-detected = [
          {
            "if".app-id = "com.apple.finder";
            run = "layout floating";
          }
          {
            "if".app-id = "com.apple.systempreferences";
            run = "layout floating";
          }
          {
            "if".app-id = "com.apple.calculator";
            run = "layout floating";
          }
          {
            "if".app-id = "org.videolan.vlc";
            run = "layout floating";
          }
          # ══════════════════════════════════════════════════════════════════
          # App-to-workspace assignments
          # ══════════════════════════════════════════════════════════════════
          # To find an app's ID, run in terminal:
          #   aerospace list-apps
          # Or:
          #   mdls -name kMDItemCFBundleIdentifier -r /Applications/AppName.app
          #
          # Template:
          # {
          #   "if".app-id = "com.example.app";
          #   run = "move-node-to-workspace B";
          #   check-further-callbacks = false;
          # }
          # ══════════════════════════════════════════════════════════════════

          # ─── Workspace B (Browsers) ────────────────────────────────────────
          {
            "if".app-id = "com.google.Chrome";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "com.google.Chrome.canary";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "org.chromium.Chromium";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "org.mozilla.firefox";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "com.brave.Browser";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "com.apple.Safari";
            run = "move-node-to-workspace B";
            check-further-callbacks = false;
          }

          # ─── Workspace C (Coding) ──────────────────────────────────────────
          {
            "if".app-id = "com.google.antigravity";
            run = "move-node-to-workspace C";
            check-further-callbacks = false;
          }
          {
            "if".app-id = "dev.zed.Zed";
            run = "move-node-to-workspace C";
            check-further-callbacks = false;
          }
          # {
          #   "if".app-id = "com.microsoft.VSCode";
          #   run = "move-node-to-workspace C";
          #   check-further-callbacks = false;
          # }

          # ─── Workspace D (Development) ─────────────────────────────────────
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = "move-node-to-workspace D";
            check-further-callbacks = false;
          }

          # ─── Workspace W (Work) ────────────────────────────────────────────
          # Examples: Slack, Teams, Outlook

          # ─── Workspace S (Social) ──────────────────────────────────────────
          # Examples: Signal, Telegram, Discord, Messages

          # ─── Workspace O (Other) ───────────────────────────────────────────
          # Examples: Mail, Obsidian, Notes, Calendar, Notion
        ];

        start-at-login = true;
      };
    };
  };
}
