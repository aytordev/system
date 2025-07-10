# Terminal Applications Module
#
# This module provides a centralized way to manage all terminal-related configurations
# including shells, tools, and other terminal applications.
#
# Version: 1.0.0
# Last Updated: 2025-07-10
{
  config,
  lib,
  ...
}: {
  imports = [
    ./shells/zsh
    ./tools/fzf
    ./tools/git
    ./tools/starship
  ];

  options.applications.terminal = {
    enable = lib.mkEnableOption "terminal applications configuration";
  };

  config = lib.mkIf config.applications.terminal.enable {
    # Common terminal configurations can go here
  };
}
