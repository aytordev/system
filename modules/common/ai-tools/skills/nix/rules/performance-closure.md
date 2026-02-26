## Closure Size Minimization

**Impact:** HIGH

Minimize closure size to reduce disk usage and deployment times. Split outputs and use minimal builders for simple scripts.

**Incorrect (Heavy Builder):**

Using stdenv for simple scripts pulls in unnecessary dependencies.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # BAD - pulls in entire stdenv (gcc, binutils, etc.) for a simple script
  myScript = pkgs.stdenv.mkDerivation {
    name = "my-script";
    buildCommand = ''
      mkdir -p $out/bin
      cat > $out/bin/hello <<'EOF'
      #!/bin/sh
      echo "Hello, World!"
      EOF
      chmod +x $out/bin/hello
    '';
  };

  # BAD - includes massive dev dependencies in runtime closure
  myPackage = pkgs.stdenv.mkDerivation {
    name = "my-package";
    buildInputs = [
      pkgs.llvm
      pkgs.clang
      pkgs.cmake
    ];
    # These are only needed at build time, not runtime!
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      myScript
      myPackage
    ];
  };
}
```

**Correct (Minimal Builder):**

Minimal closure, only bash and necessary runtime dependencies.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # GOOD - minimal closure with writeShellApplication
  myScript = pkgs.writeShellApplication {
    name = "hello";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      echo "Hello, World!"
      date
    '';
  };

  # GOOD - split outputs to separate dev dependencies
  myPackage = pkgs.stdenv.mkDerivation {
    name = "my-package";
    outputs = [ "out" "dev" "doc" "lib" ];

    nativeBuildInputs = [
      pkgs.llvm
      pkgs.clang
      pkgs.cmake
    ];

    buildInputs = [
      # Only runtime dependencies here
      pkgs.openssl
    ];

    # Move headers to dev output
    postInstall = ''
      moveToOutput "include" "$dev"
      moveToOutput "share/doc" "$doc"
      moveToOutput "lib/*.a" "$dev"
    '';
  };

  # GOOD - use writeText for pure data files
  configFile = pkgs.writeText "myconfig.json" (builtins.toJSON {
    setting1 = "value1";
    setting2 = "value2";
  });

  # GOOD - use writers for scripts in various languages
  pythonScript = pkgs.writers.writePython3 "myscript" {
    libraries = [ pkgs.python3Packages.requests ];
  } ''
    import requests
    print(requests.get("https://example.com").text)
  '';
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      myScript
      myPackage  # Only includes 'out', not 'dev'
    ];

    environment.etc."myconfig.json".source = configFile;
  };
}
```
