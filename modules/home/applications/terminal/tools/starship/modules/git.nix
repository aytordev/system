{lib}: {
  git_branch = {
    symbol = "";
    style = "fg:teal";
    format = "on [$symbol $branch(:$remote_branch)]($style)";
  };

  git_status = {
    style = "fg:teal";
    format = "[[($all_status$ahead_behind )](fg:green)]($style)";
    ahead = "[⬆](bold purple)";
    behind = "[⬇](bold purple)";
    staged = "[✚](green)";
    deleted = "[✖](red)";
    renamed = "[➜](purple)";
    stashed = "[✭](cyan)";
    untracked = "[◼](white)";
    modified = "[✱](blue)";
    conflicted = "[═](yellow)";
    diverged = "⇕";
    up_to_date = "";
  };
}
