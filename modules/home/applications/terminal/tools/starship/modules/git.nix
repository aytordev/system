{lib}: {
  git_branch = {
    symbol = "";
    style = "fg:teal";
    format = "[[ $symbol $branch ](fg:green)]($style)";
  };

  git_status = {
    style = "fg:teal";
    format = "[[($all_status$ahead_behind )](fg:green)]($style)";
  };
}
