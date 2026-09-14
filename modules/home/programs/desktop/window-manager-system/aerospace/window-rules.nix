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
  # Firefox is Home-Manager-packaged on Darwin, so its bundle id is
  # `org.nixos.firefox` (not `org.mozilla.firefox`).
  {
    "if".app-id = "org.nixos.firefox";
    run = "move-node-to-workspace B";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "app.zen-browser.zen";
    run = "move-node-to-workspace B";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "net.imput.helium";
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
    "if".app-id = "dev.zed.Zed";
    run = "move-node-to-workspace C";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.microsoft.VSCode";
    run = "move-node-to-workspace C";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.mitchellh.ghostty";
    run = "move-node-to-workspace C";
    check-further-callbacks = false;
  }

  # ─── Workspace D (Development / 端) ─────────────────────────────
  {
    "if".app-id = "com.usebruno.app";
    run = "move-node-to-workspace D";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "io.podmandesktop.PodmanDesktop";
    run = "move-node-to-workspace D";
    check-further-callbacks = false;
  }

  # ─── Workspace W (Work / 業) ────────────────────────────────────
  # Thunderbird is Home-Manager-packaged on Darwin (`org.nixos.thunderbird`).
  {
    "if".app-id = "com.tinyspeck.slackmacgap";
    run = "move-node-to-workspace W";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.microsoft.teams2";
    run = "move-node-to-workspace W";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "org.nixos.thunderbird";
    run = "move-node-to-workspace W";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.microsoft.Word";
    run = "move-node-to-workspace W";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.microsoft.Excel";
    run = "move-node-to-workspace W";
    check-further-callbacks = false;
  }

  # ─── Workspace S (Social / 話) ──────────────────────────────────
  # Examples: Signal, Telegram, Discord, Messages

  # ─── Workspace O (Other / 雑) ───────────────────────────────────
  # Examples: Mail, Notes, Calendar, Notion
  {
    "if".app-id = "md.obsidian";
    run = "move-node-to-workspace O";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "com.bitwarden.desktop";
    run = "move-node-to-workspace O";
    check-further-callbacks = false;
  }
  {
    "if".app-id = "ch.protonvpn.mac";
    run = "move-node-to-workspace O";
    check-further-callbacks = false;
  }
]
