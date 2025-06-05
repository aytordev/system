{ pkgs, ... }:

{
  name = "just";
  
  packages = with pkgs; [
    just  # The task runner
  ];

  shellHook = ''
    echo -e "\n\033[1;32m🎯 Task Runner Shell\033[0m"
    echo "Run 'just' to see available tasks"
    echo ""
  '';
}
