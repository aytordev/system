[
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

  # ─── Workspace B (Browsers / 網) ─────────────────────────────────
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

  # ─── Workspace C (Coding / 編) ──────────────────────────────────
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

  # ─── Workspace D (Development / 端) ─────────────────────────────
  {
    "if".app-id = "com.mitchellh.ghostty";
    run = "move-node-to-workspace D";
    check-further-callbacks = false;
  }

  # ─── Workspace W (Work / 業) ────────────────────────────────────
  # Examples: Slack, Teams, Outlook

  # ─── Workspace S (Social / 話) ──────────────────────────────────
  # Examples: Signal, Telegram, Discord, Messages

  # ─── Workspace O (Other / 雑) ───────────────────────────────────
  # Examples: Mail, Obsidian, Notes, Calendar, Notion
]
