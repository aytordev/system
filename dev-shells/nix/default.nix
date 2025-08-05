{pkgs, ...}: {
  name = "nix";
  description = "Task runner shell with just";
  packages = with pkgs; [
    just
  ];
  shellHook = ''
    echo -e "\n\033[1;32m🎯 Nix Runner Shell\033[0m"
    echo "Run 'just' to see available tasks"
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
      just --list
    else
      echo -e "\n\033[33mℹ️  No Justfile found in current directory\033[0m"
    fi
  '';
}
