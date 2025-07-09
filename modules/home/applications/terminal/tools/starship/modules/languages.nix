{lib}: let
  langFormat = symbol: "[[ $symbol( $version) ](fg:teal)](fg:teal)";
in {
  nodejs = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  c = {
    symbol = " ";
    style = "fg:teal";
    format = langFormat "";
  };

  rust = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  golang = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  php = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  java = {
    symbol = " ";
    style = "fg:teal";
    format = langFormat "";
  };

  kotlin = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  haskell = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  python = {
    symbol = "";
    style = "fg:teal";
    format = langFormat "";
  };

  lua = {
    symbol = "󰢱";
    style = "fg:teal";
    format = langFormat "󰢱";
  };
}
