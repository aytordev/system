{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  packages = with pkgs; [
    python313
    uv
  ];
  shellHook = ''
    echo -e "\n\033[1;32m🐍 Python 3.13 Shell\033[0m"
    echo "Run 'python --version' to see the version"
    echo "Run 'uv --version' to see uv version"
    echo ""
    echo "Quick start:"
    echo "  uv init        - Create a new project"
    echo "  uv add <pkg>   - Add a dependency"
    echo "  uv run <cmd>   - Run a command in the venv"
  '';
}
