{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  pythonPackages = catalog.python.toolchain "314";
in
  mkShell {
    packages = pythonPackages;

    shellHook = ''
      echo -e "\n\033[1;32m🐍 Python 3.14 Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        pythonPackages}
      echo ""
      echo "Quick start:"
      echo "  uv sync --locked - Install project dependencies from the lockfile"
      echo "  uv run <cmd>     - Run a command in the project environment"
    '';
  }
