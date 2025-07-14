{lib}: {
  git_branch = {
    symbol = "🌿";
    style = "fg:bold green";
    format = "on [$symbol $branch(:$remote_branch) ]($style)";
  };
  git_status = {
    format = "[[($all_status$ahead_behind)](fg:green)]($style)";
    ahead = "[⬆](bold sapphire)";
    behind = "[⬇](bold sapphire)";
    staged = "[✚](green)";
    deleted = "[✖](red)";
    renamed = "[➜](blue)";
    stashed = "[✭](cyan)";
    untracked = "[◼](white)";
    modified = "[✱](blue)";
    conflicted = "[═](yellow)";
    diverged = "⇕";
    up_to_date = "";
  };
}
