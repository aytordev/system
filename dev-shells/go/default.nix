{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};

  # Go is unversioned in the catalog (nixpkgs carries one supported toolchain),
  # so the pack passes null as required by the catalog contract.
  goPackages = catalog.go.toolchain null;
in
  mkShell {
    packages = goPackages;

    shellHook = ''
      echo -e "\n\033[1;32m🐹 Go Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        goPackages}
      echo ""
      echo "Quick start:"
      echo "  go mod init <module>  - Create a new module"
      echo "  go test ./...         - Run all tests"
      echo "  go build ./...        - Build all packages"
    '';
  }
