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
        accordion-padding = 30;
        after-login-command = [];
        after-startup-command = ["exec-and-forget sketchybar"];
        automatically-unhide-macos-hidden-apps = true;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        exec-on-workspace-change = [
          "/bin/bash"
          "-c"
          "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE"
        ];
        gaps.inner.horizontal = 8;
        gaps.inner.vertical = 8;
        gaps.outer.left = 8;
        gaps.outer.bottom = 8;
        gaps.outer.top = 8;
        gaps.outer.right = 8;
        key-mapping.preset = "qwerty";

        # Workspace Navigation - Semantic Names
        mode.main.binding.alt-1 = "workspace social";
        mode.main.binding.alt-2 = "workspace work";
        mode.main.binding.alt-3 = "workspace development";
        mode.main.binding.alt-4 = "workspace others";
        mode.main.binding.alt-5 = "workspace stream";
        mode.main.binding.alt-6 = "workspace 6";
        mode.main.binding.alt-7 = "workspace 7";

        # Layout Management
        mode.main.binding.alt-comma = "layout accordion horizontal vertical";
        mode.main.binding.alt-slash = "layout tiles horizontal vertical";

        # Focus Navigation (alt-ctrl for consistency with provided config)
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
        mode.main.binding.alt-shift-1 = "move-node-to-workspace social";
        mode.main.binding.alt-shift-2 = "move-node-to-workspace work";
        mode.main.binding.alt-shift-3 = "move-node-to-workspace development";
        mode.main.binding.alt-shift-4 = "move-node-to-workspace others";
        mode.main.binding.alt-shift-5 = "move-node-to-workspace stream";
        mode.main.binding.alt-shift-6 = "move-node-to-workspace 6";
        mode.main.binding.alt-shift-7 = "move-node-to-workspace 7";

        # Fullscreen (user preference: alt-f)
        mode.main.binding.alt-f = "fullscreen";

        # Workspace & Monitor Management
        mode.main.binding.alt-tab = "workspace-back-and-forth";
        mode.main.binding.alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # Mode Switching
        mode.main.binding.alt-r = "mode resize";
        mode.main.binding.alt-shift-semicolon = "mode service";

        # Resize Mode
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
        on-focus-changed = ["move-mouse window-lazy-center" "exec-and-forget sketchybar --trigger aerospace_focus_change"];
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        # Multi-Monitor Workspace Assignment
        workspace-to-monitor-force-assignment = {
          social = "main";
          work = "main";
          development = "main";
          others = "main";
          stream = "main";
        };

        # Application-Specific Rules
        on-window-detected = [
          {
            "if".app-id = "com.apple.finder";
            run = "layout floating";
          }
        ];

        start-at-login = true;
      };
    };
  };
}
