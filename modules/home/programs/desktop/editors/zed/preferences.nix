# Owned policy/preferences. The updater never writes this file.
{
  lib,
  package,
  terminalShell ? "system",
}: {
  extensions = ["kanagawa-themes" "sora-theme"];

  # Explicit source exclusions, applied before owned values. Null is a JSON
  # value, not a deletion marker. Appearance belongs solely to config.nix.
  excludedSettings = [["theme"] ["icon_theme"]];
  settings = {
    ui_font_size = 16;
    buffer_font_size = 18;
    buffer_font_family = "MonaspiceNe Nerd Font Mono";
    edit_predictions.provider = "zed";
    tabs.show_diagnostics = "all";
    agent = {
      dock = "right";
      sidebar_side = "right";
      notify_when_agent_waiting = "primary_screen";
      play_sound_when_agent_done = "never";
      single_file_review = true;
    };
    languages = {
      Rust = {
        hard_tabs = false;
        format_on_save = "on";
      };
      JSON.hard_tabs = false;
    };
    terminal = {
      font_family = "MonaspiceNe Nerd Font Mono";
      shell = terminalShell;
      env.EDITOR = "${lib.getExe package} --wait";
    };
    file_types = {
      Dockerfile = ["Dockerfile" "Dockerfile.*"];
      JSON = ["json" "jsonc" "*.code-snippets"];
    };
    file_scan_exclusions = [
      "**/.git"
      "**/.svn"
      "**/.hg"
      "**/CVS"
      "**/.DS_Store"
      "**/Thumbs.db"
      "**/.classpath"
      "**/.settings"
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
    project_panel = {
      button = true;
      dock = "right";
      git_status = true;
      file_icons = true;
      folder_indicator = "icon";
      show_diagnostics = "all";
    };
    outline_panel.dock = "right";
    collaboration_panel.dock = "left";
  };

  # Ordinary priority, deliberately stronger than preferences; not enforcement.
  # An explicit stronger user definition (e.g. mkForce) can still override these.
  safety = {
    telemetry = {
      diagnostics = false;
      metrics = false;
    };
    redact_private_values = true;
    agent = {
      default_profile = "ask";
      tool_permissions.default = "confirm";
    };
  };
}
