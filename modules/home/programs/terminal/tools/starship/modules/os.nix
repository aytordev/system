{lib}: {
  os = {
    format = "[ [$symbol](fg:text) ]($style)";
    disabled = false;
    style = "fg:text";
    symbols = {
      Windows = "󰍲";
      Ubuntu = "󰕈";
      SUSE = "";
      Raspbian = "󰐿";
      Mint = "󰣭";
      Macos = "";
      Manjaro = "";
      Linux = "󰌽";
      Gentoo = "󰣨";
      Fedora = "󰣛";
      Alpine = "";
      Amazon = "";
      Android = "";
      Arch = "󰣇";
      Artix = "󰣇";
      CentOS = "";
      Debian = "󰣚";
      Redhat = "󱄛";
      RedHatEnterprise = "󱄛";
    };
  };
  username = {
    show_always = true;
    style_user = "fg:mauve";
    style_root = "fg:mauve";
    format = "[$user]($style)";
  };
  localip = {
    ssh_only = false;
    style = "fg:surface0";
    format = "[ $localipv4 ]($style)";
    disabled = false;
  };
}
