# dev-shells/just.nix
#
# This file defines the development shell for the 'just' task runner.
# It provides a minimal environment for running project tasks.
#
# Version: 1.0.0
# Last Updated: 2025-06-05

{ pkgs, ... }:

{
  # Shell metadata
  name = "just";
  description = "Task runner shell with just";
  
  # Package dependencies
  packages = with pkgs; [
    just  # A handy way to save and run project-specific commands
  ];

  # Shell initialization script
  shellHook = ''
    # Print welcome message
    echo -e "\n\033[1;32m🎯 Task Runner Shell\033[0m"
    echo "Run 'just' to see available tasks"
    
    # Check for Justfile in current directory
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
      just --list
    else
      echo -e "\n\033[33mℹ️  No Justfile found in current directory\033[0m"
    fi
    
    echo ""
  '';
}
