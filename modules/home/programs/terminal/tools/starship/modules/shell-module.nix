{lib}: {
  directory = {
    style = "fg:lavender";
    format = "[ $path ]($style)";
    truncation_length = 4;
    truncation_symbol = "…/";
    substitutions = {
      "Documents" = "󰈙 ";
      "Downloads" = " ";
      "Music" = "󰝚 ";
      "Pictures" = " ";
      "Developer" = "󰲋 ";
    };
  };
  docker_context = {
    symbol = "";
    style = "fg:mantle";
    format = "[[ $symbol( $context) ](fg:color_bg3)]($style)";
  };
  time = {
    disabled = false;
    time_format = "%R";
    style = "fg:peach";
    format = "[[  $time ](fg:purple)]($style)";
  };
  line_break = {
    disabled = false;
  };
  character = {
    format = ''
      [╰─$symbol](fg:overlay1) '';
    success_symbol = "[❯](fg:bold text)";
    error_symbol = "[×](fg:bold peach)";
  };
}
