{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  pythonPackages = with pkgs; [
    python313
    uv
  ];
in
  mkShell {
    packages = pythonPackages;

    shellHook = ''
      echo -e "\n\033[1;32m🐍 Python 3.13 Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        pythonPackages}
      echo ""
      echo "Quick start:"
      echo "  uv init        - Create a new project"
      echo "  uv add <pkg>   - Add a dependency"
      echo "  uv run <cmd>   - Run a command in the venv"
    '';
  }
