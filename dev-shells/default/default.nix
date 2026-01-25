{
  mkShell,
  shellNames,
  ...
}:
mkShell {
  name = "default";

  shellHook = ''
    echo -e "\n\033[1;32m🚀 Default Development Shell\033[0m"
    echo "Available shells: ${toString shellNames}"
    echo "Enter a specific shell with: nix develop .#<shell-name>"
    echo ""
  '';
}
