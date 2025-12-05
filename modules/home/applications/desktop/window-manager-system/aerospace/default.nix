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
        mode.main.binding.alt-1 = "workspace 1";
        mode.main.binding.alt-2 = "workspace 2";
        mode.main.binding.alt-3 = "workspace 3";
        mode.main.binding.alt-4 = "workspace 4";
        mode.main.binding.alt-b = "workspace B";
        mode.main.binding.alt-e = "workspace E";
        mode.main.binding.alt-t = "workspace T";
        mode.main.binding.alt-comma = "layout accordion horizontal vertical";
        mode.main.binding.alt-f = "fullscreen";
        mode.main.binding.alt-h = "focus left";
        mode.main.binding.alt-k = "focus down";
        mode.main.binding.alt-j = "focus up";
        mode.main.binding.alt-l = "focus right";
        mode.main.binding.alt-r = "mode resize";
        mode.main.binding.alt-shift-1 = "move-node-to-workspace 1";
        mode.main.binding.alt-shift-2 = "move-node-to-workspace 2";
        mode.main.binding.alt-shift-3 = "move-node-to-workspace 3";
        mode.main.binding.alt-shift-4 = "move-node-to-workspace 4";
        mode.main.binding.alt-shift-b = "move-node-to-workspace B";
        mode.main.binding.alt-shift-e = "move-node-to-workspace E";
        mode.main.binding.alt-shift-t = "move-node-to-workspace T";
        mode.main.binding.alt-shift-h = "move left";
        mode.main.binding.alt-shift-k = "move down";
        mode.main.binding.alt-shift-j = "move up";
        mode.main.binding.alt-shift-l = "move right";
        mode.main.binding.alt-shift-semicolon = "mode service";
        mode.main.binding.alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        mode.main.binding.alt-slash = "layout tiles horizontal vertical";
        mode.main.binding.alt-tab = "workspace-back-and-forth";

        mode.resize.binding.b = ["balance-sizes" "mode main"];
        mode.resize.binding.equal = "resize smart +50";
        mode.resize.binding.esc = "mode main";
        mode.resize.binding.minus = "resize smart -50";

        mode.service.binding.alt-shift-h = ["join-with left" "mode main"];
        mode.service.binding.alt-shift-j = ["join-with down" "mode main"];
        mode.service.binding.alt-shift-k = ["join-with up" "mode main"];
        mode.service.binding.alt-shift-l = ["join-with right" "mode main"];
        mode.service.binding.backspace = ["close-all-windows-but-current" "mode main"];
        mode.service.binding.down = "volume down";
        mode.service.binding.esc = ["reload-config" "mode main"];
        mode.service.binding.f = ["layout floating tiling" "mode main"];
        mode.service.binding.r = ["flatten-workspace-tree" "mode main"];
        mode.service.binding.shift-down = ["volume set 0" "mode main"];
        mode.service.binding.up = "volume up";

        on-focus-changed = ["move-mouse window-lazy-center" "exec-and-forget sketchybar --trigger aerospace_focus_change"];
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        start-at-login = true;
      };
    };
  };
}
