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
      ms-python.python = marker "ms-python.python";
      golang.go = marker "golang.go";
      vscjava = {
        vscode-java-pack = marker "vscjava.vscode-java-pack";
        vscode-java-debug = marker "vscjava.vscode-java-debug";
        vscode-java-test = marker "vscjava.vscode-java-test";
        vscode-maven = marker "vscjava.vscode-maven";
        vscode-gradle = marker "vscjava.vscode-gradle";
        vscode-java-dependency = marker "vscjava.vscode-java-dependency";
      };
    };
    go = marker "go";
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
    nodejs_22 = marker "nodejs_22";
    nodejs_24 = marker "nodejs_24";
    nodejs_26 = marker "nodejs_26";
    pnpm = marker "pnpm";
    nurl = marker "nurl";
    python312 = marker "python312";
    python313 = marker "python313";
    python314 = marker "python314";
    uv = marker "uv";
    yarn = marker "yarn";
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

  testLanguageCatalogRegistersGo = {
    expr = builtins.elem "go" (builtins.attrNames catalog);
    expected = true;
  };

  testLanguageCatalogRegistersNode = {
    expr = builtins.elem "node" (builtins.attrNames catalog);
    expected = true;
  };

  testLanguageCatalogRegistersPython = {
    expr = builtins.elem "python" (builtins.attrNames catalog);
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
    expected = [[(marker "openjdk17")] [(marker "openjdk21")] [(marker "openjdk25")]];
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

  testLanguageRuntimeIsAListForEveryLanguage = {
    expr = {
      go = builtins.isList (catalog.go.runtime null);
      java = builtins.isList (catalog.java.runtime "25");
      nix = builtins.isList (catalog.nix.runtime null);
      node = builtins.isList (catalog.node.runtime "24");
      python = builtins.isList (catalog.python.runtime "313");
    };
    expected = {
      go = true;
      java = true;
      nix = true;
      node = true;
      python = true;
    };
  };

  testLanguageGoHasNoVersionAxis = {
    expr = {
      versions = catalog.go.versions;
      defaultVersion = catalog.go.defaultVersion;
    };
    expected = {
      versions = [];
      defaultVersion = null;
    };
  };

  testLanguagePythonDefaultVersionIsSelectable = {
    expr = builtins.elem catalog.python.defaultVersion catalog.python.versions;
    expected = true;
  };
}
