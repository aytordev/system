{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.window-manager-system.aerospace;
  sketchybar = lib.getExe config.programs.sketchybar.package;
in {
  options = {
    aytordev.programs.desktop.window-manager-system.aerospace = {
      enable = lib.mkEnableOption "Aerospace window manager";
      package = lib.mkPackageOption pkgs "aerospace" {};
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    # The restart command needs command substitution, which parses differently
    # per shell. A single bin is shell-agnostic; no aliases needed (the bin name
    # equals the command name).
    home.packages = [
      cfg.package
      (pkgs.writeShellApplication {
        name = "restart-aerospace";
        runtimeInputs = [pkgs.coreutils];
        text = ''
          exec launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.aerospace"
        '';
      })
    ];

    programs.aerospace = {
      enable = true;
      inherit (cfg) package;
      launchd.enable = true;

      settings = {
        # Config version 2 enables new features like persistent-workspaces
        config-version = 2;

        accordion-padding = 30;
        after-login-command = [];
        after-startup-command = [];
        automatically-unhide-macos-hidden-apps = true;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        # Persistent workspaces - always visible in Sketchybar even when empty
        # B = Browsers    (網 - web/net)
        # C = Coding      (編 - edit/compile)
        # D = Development  (端 - terminal)
        # W = Work        (業 - work/business)
        # S = Social      (話 - conversation)
        # O = Other       (雑 - miscellaneous)

        persistent-workspaces = [
          "B"
          "C"
          "D"
          "W"
          "S"
          "O"
        ];

        exec-on-workspace-change = [
          "/bin/bash"
          "-c"
          "${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
        ];

        # Dynamic gaps per monitor
        gaps = {
          inner = {
            horizontal = 10;
            vertical = 10;
          };
          outer = {
            left = 7;
            bottom = 7;
            top = 40;
            right = 7;
          };
        };
        key-mapping.preset = "qwerty";

        mode = {
          main.binding = {
            # Workspace Navigation
            alt-1 = "workspace B";
            alt-2 = "workspace C";
            alt-3 = "workspace D";
            alt-4 = "workspace W";
            alt-5 = "workspace S";
            alt-6 = "workspace O";

            # Layout Management
            alt-comma = "layout accordion horizontal vertical";
            alt-slash = "layout tiles horizontal vertical";
            alt-shift-f = "layout floating tiling"; # Toggle floating

            # Focus Navigation
            alt-ctrl-h = "focus left";
            alt-ctrl-j = "focus down";
            alt-ctrl-k = "focus up";
            alt-ctrl-l = "focus right";

            # Window Movement
            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            # Move to Workspace
            alt-shift-1 = "move-node-to-workspace B";
            alt-shift-2 = "move-node-to-workspace C";
            alt-shift-3 = "move-node-to-workspace D";
            alt-shift-4 = "move-node-to-workspace W";
            alt-shift-5 = "move-node-to-workspace S";
            alt-shift-6 = "move-node-to-workspace O";

            # Fullscreen
            alt-f = "fullscreen";

            # Resize shortcuts in main mode (no need to enter resize mode)
            alt-minus = "resize smart -50";
            alt-equal = "resize smart +50";

            # Screenshot to clipboard
            alt-shift-s = "exec-and-forget screencapture -i -c";

            # Workspace & Monitor Management
            alt-tab = "workspace-back-and-forth";
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            # Mode Switching
            alt-r = "mode resize";
            alt-shift-semicolon = "mode service";
          };

          resize.binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";
            b = [
              "balance-sizes"
              "mode main"
            ];
            equal = "resize smart +50";
            minus = "resize smart -50";
            esc = "mode main";
          };

          service.binding = {
            alt-shift-h = [
              "join-with left"
              "mode main"
            ];
            alt-shift-j = [
              "join-with down"
              "mode main"
            ];
            alt-shift-k = [
              "join-with up"
              "mode main"
            ];
            alt-shift-l = [
              "join-with right"
              "mode main"
            ];
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];
            esc = [
              "reload-config"
              "mode main"
            ];
            f = [
              "layout floating tiling"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];
            up = "volume up";
            down = "volume down";
            shift-down = [
              "volume set 0"
              "mode main"
            ];
          };
        };

        # Callbacks
        on-focus-changed = [
          "move-mouse window-lazy-center"
          "exec-and-forget ${sketchybar} --trigger aerospace_focus_change"
        ];
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-mode-changed = ["exec-and-forget ${sketchybar} --trigger aerospace_mode_change"];

        # Multi-Monitor Workspace Assignment
        # C/D target the Dell (civislend's secondary), matched by name, and fall
        # back to the secondary monitor on hosts without a Dell. Everything else
        # lives on the primary display.
        workspace-to-monitor-force-assignment = {
          B = "main";
          C = [
            "dell"
            "secondary"
          ];
          D = [
            "dell"
            "secondary"
          ];
          W = "main";
          S = "main";
          O = "main";
        };

        # Application-Specific Rules - Floating apps
        on-window-detected = import ./window-rules.nix;

        start-at-login = true;
      };
    };
  };
}
