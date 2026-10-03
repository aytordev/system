{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  jdk = pkgs.openjdk17;

  # python3 is a need of this shell, not part of Java language support, so it
  # stays a shell-local extra instead of moving into the catalog.
  javaPackages = catalog.java.toolchain "17" ++ [pkgs.python3];
in
  mkShell {
    packages = javaPackages;

    shellHook = ''
      export JAVA_HOME=${jdk}

      echo -e "\n\033[1;32m☕ Java 17 LTS Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        javaPackages}
      echo ""
      echo "Quick start:"
      echo "  java --version  - Check the JDK version"
      echo "  mvn clean install  - Build with Maven"
      echo "  gradle build  - Build with Gradle"
    '';
  }
