{lib, ...}: let
  marker = name: {inherit name;};

  stubPkgs = {
    openjdk17 = marker "openjdk17";
    openjdk21 = marker "openjdk21";
    openjdk25 = marker "openjdk25";
    maven.override = args: marker "maven" // {inherit args;};
    gradle.override = args: marker "gradle" // {inherit args;};
    vscode-extensions = {
      redhat.java = marker "redhat.java";
      vscjava = {
        vscode-java-pack = marker "vscjava.vscode-java-pack";
        vscode-java-debug = marker "vscjava.vscode-java-debug";
        vscode-java-test = marker "vscjava.vscode-java-test";
        vscode-maven = marker "vscjava.vscode-maven";
        vscode-gradle = marker "vscjava.vscode-gradle";
        vscode-java-dependency = marker "vscjava.vscode-java-dependency";
      };
    };
    hydra-check = marker "hydra-check";
    nix-bisect = marker "nix-bisect";
    nix-diff = marker "nix-diff";
    nix-fast-build = marker "nix-fast-build";
    nix-health = marker "nix-health";
    nix-index = marker "nix-index";
    nix-output-monitor = marker "nix-output-monitor";
    nix-update = marker "nix-update";
    nixpkgs-hammering = marker "nixpkgs-hammering";
    nixpkgs-lint-community = marker "nixpkgs-lint-community";
    nixpkgs-review = marker "nixpkgs-review";
    nurl = marker "nurl";
  };

  catalog = import ../../modules/common/languages/catalog.nix {pkgs = stubPkgs;};
  inherit (catalog) java;
in {
  testLanguageCatalogHasNoDefaultNix = {
    expr = builtins.pathExists ../../modules/common/languages/default.nix;
    expected = false;
  };

  testLanguageCatalogRegistersJava = {
    expr = builtins.elem "java" (builtins.attrNames catalog);
    expected = true;
  };

  testLanguageCatalogRegistersNix = {
    expr = builtins.elem "nix" (builtins.attrNames catalog);
    expected = true;
  };

  testLanguageCatalogDefaultVersionIsKnown = {
    expr = builtins.elem java.defaultVersion java.versions;
    expected = true;
  };

  testLanguageCatalogVersions = {
    expr = java.versions;
    expected = ["17" "21" "25"];
  };

  testLanguageRuntimeFollowsTheRequestedVersion = {
    expr = map java.runtime java.versions;
    expected = [(marker "openjdk17") (marker "openjdk21") (marker "openjdk25")];
  };

  # Guards the R3-001 contract: the JDK handed to each build tool must be the
  # one the caller asked for, under nixpkgs' real argument names.
  testLanguageToolchainPinsMavenToTheRequestedJdk = {
    expr = (lib.findFirst (p: p.name == "maven") null (java.toolchain "21")).args;
    expected = {jdk_headless = marker "openjdk21";};
  };

  testLanguageToolchainPinsGradleToTheRequestedJdk = {
    expr = (lib.findFirst (p: p.name == "gradle") null (java.toolchain "17")).args;
    expected = {java = marker "openjdk17";};
  };

  testLanguageToolchainDoesNotLeakOtherVersions = {
    expr = map (p: p.name) (java.toolchain "25");
    expected = ["openjdk25" "maven" "gradle"];
  };

  testLanguageEditorExtensionsCoverTheJavaPack = {
    expr = {
      count = builtins.length java.editor.vscode.extensions;
      hasPack = builtins.elem (marker "vscjava.vscode-java-pack") java.editor.vscode.extensions;
    };
    expected = {
      count = 7;
      hasPack = true;
    };
  };
}
