{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.applications.desktop.window-manager-system.aerospace;
  sketchybar = "${config.programs.sketchybar.package}/bin/sketchybar";
in {
  options = {
    applications.desktop.window-manager-system.aerospace = {
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

      userSettings = {
        accordion-padding = 32;
        after-login-command = [];
        after-startup-command = ["exec-and-forget sketchybar"];
        automatically-unhide-macos-hidden-apps = false;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        exec-on-workspace-change = [
          "/bin/bash"
          "-c"
          "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE"
        ];
        gaps.inner.horizontal = 8;
        gaps.inner.vertical = 8;
        gaps.outer.left = 8;
        gaps.outer.bottom = 40;
        gaps.outer.top = 8;
        gaps.outer.right = 8;
        key-mapping.preset = "qwerty";
        mode.main.binding.alt-shift-j = "move up";
        mode.main.binding.alt-shift-k = "move down";
        mode.main.binding.alt-shift-l = "move right";
        mode.main.binding.alt-shift-h = "move left";
        mode.main.binding.alt-f = "fullscreen";
        mode.main.binding.cmd-shift-f = "fullscreen";
        mode.main.binding.cmd-ctrl-1 = "workspace 1";
        mode.main.binding.cmd-ctrl-2 = "workspace 2";
        mode.main.binding.cmd-ctrl-3 = "workspace 3";
        mode.main.binding.cmd-ctrl-4 = "workspace 4";
        # mode.main.binding.cmd-ctrl-5 = "workspace 5";
        # mode.main.binding.cmd-ctrl-6 = "workspace 6";
        # mode.mainx.binding.cmd-ctrl-7 = "workspace 7";
        # mode.main.binding.cmd-ctrl-8 = "workspace 8";
        mode.main.binding.cmd-ctrl-left = "workspace --wrap-around prev";
        mode.main.binding.cmd-ctrl-right = "workspace --wrap-around next";
        mode.main.binding.alt-shift-1 = "move-node-to-workspace 1";
        mode.main.binding.alt-shift-2 = "move-node-to-workspace 2";
        mode.main.binding.alt-shift-3 = "move-node-to-workspace 3";
        mode.main.binding.alt-shift-4 = "move-node-to-workspace 4";
        # mode.main.binding.alt-shift-5 = "move-node-to-workspace 5";
        # mode.main.binding.alt-shift-6 = "move-node-to-workspace 6";
        # mode.main.binding.alt-shift-7 = "move-node-to-workspace 7";
        # mode.main.binding.alt-shift-8 = "move-node-to-workspace 8";
        mode.main.binding.cmd-up = "volume up";
        mode.main.binding.cmd-down = "volume down";
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-focus-changed = ["exec-and-forget sketchybar --trigger aerospace_focus_change"];
        start-at-login = true;
      };
    };
  };
}
