{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  javaPackages = with pkgs; [
    openjdk25
    maven
    gradle
  ];
in
  mkShell {
    packages = javaPackages;

    shellHook = ''
      echo -e "\n\033[1;32m☕ Java 25 LTS Shell\033[0m"
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
