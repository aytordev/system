{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  jdk = pkgs.openjdk25;

  # Maven and Gradle ship wrappers that pin their own JDK (Gradle defaults to
  # jdk25 for gradle_9 but jdk21 for gradle_8, Maven to jdk_headless), so
  # without these overrides `mvn` and `gradle` would run on a different JDK
  # than the one this shell advertises.
  javaPackages = [
    jdk
    (pkgs.maven.override {jdk_headless = jdk;})
    (pkgs.gradle.override {java = jdk;})
    pkgs.python3
  ];
in
  mkShell {
    packages = javaPackages;

    shellHook = ''
      export JAVA_HOME=${jdk}

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
