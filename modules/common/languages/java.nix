# Pure Java language data. See ./catalog.nix.
{pkgs}: let
  jdks = {
    "17" = pkgs.openjdk17;
    "21" = pkgs.openjdk21;
    "25" = pkgs.openjdk25;
  };

  # Maven and Gradle ship wrappers that pin their own JDK (Gradle defaults to
  # jdk21, Maven to jdk_headless), so anything claiming a Java version must
  # override both or the toolchain silently runs on the wrong JDK. Keeping the
  # override here is what makes that guarantee single-sourced; see finding
  # R3-001 in odd/tasks/java-dev-shells.md.
  buildTools = jdk: [
    (pkgs.maven.override {jdk_headless = jdk;})
    (pkgs.gradle.override {java = jdk;})
  ];
in {
  name = "java";
  defaultVersion = "25";
  versions = builtins.attrNames jdks;

  # The runtime this language is about.
  runtime = version: jdks.${version};

  # The full toolchain a development shell needs.
  toolchain = version: [jdks.${version}] ++ buildTools jdks.${version};

  editor.vscode.extensions = [
    # Nixpkgs builds the pack as a plain marketplace extension with no
    # propagated members, so every member is listed explicitly.
    pkgs.vscode-extensions.vscjava.vscode-java-pack
    pkgs.vscode-extensions.redhat.java
    pkgs.vscode-extensions.vscjava.vscode-java-debug
    pkgs.vscode-extensions.vscjava.vscode-java-test
    pkgs.vscode-extensions.vscjava.vscode-maven
    pkgs.vscode-extensions.vscjava.vscode-gradle
    pkgs.vscode-extensions.vscjava.vscode-java-dependency
  ];
}
