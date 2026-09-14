## Closure Size Minimization

**Impact:** HIGH

A store path's *closure* is the set of store paths that are directly or indirectly
reachable from it through the *references* relation — not its list of build
inputs. The closure of a derivation equals its build-time dependencies, while the
closure of an **output path** equals its runtime dependencies. A `buildInputs`
entry is therefore a build-time dependency; it only stays in the runtime closure
if the produced output actually references it (for example a linked library baked
into an ELF binary's RPATH, or a store path embedded in a script). Do not assume
that every build input is retained at runtime.

Reference: [Nix glossary — closure](https://nix.dev/manual/nix/2.35/glossary#gloss-closure).

Use `nix-store --query --requisites` (or `nix path-info -rsSh`) to inspect the
real closure instead of guessing.

**Incorrect (Assuming build inputs leak into the runtime closure):**

`llvm`/`clang` are only invoked while building; `nativeBuildInputs` are not
referenced by `$out`. The comment below states the opposite, and the widened
build-time dependency set buys no runtime correctness.

```nix
{
  pkgs,
  ...
}: {
  # BAD reasoning: "build inputs end up in the runtime closure".
  myPackage = pkgs.stdenv.mkDerivation {
    pname = "my-package";
    version = "1.0";
    src = ./.;
    nativeBuildInputs = [
      # These run on the build machine and are not runtime references.
      pkgs.llvm
      pkgs.clang
      pkgs.cmake
    ];
    # openssl is a build input *and* a runtime dependency here only because the
    # linked binary references it; the buildInputs list alone does not decide
    # what ends up in the output closure.
    buildInputs = [ pkgs.openssl ];
  };
}
```

**Correct (Make runtime references explicit; keep build tools build-only):**

```nix
{
  pkgs,
  ...
}: let
  # A script's runtime closure is what its shebang and PATH reference.
  # writeShellApplication records runtimeInputs as explicit references instead
  # of relying on whatever happens to be on the builder's PATH.
  hello = pkgs.writeShellApplication {
    name = "hello";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      echo "Hello, World!"
      date
    '';
  };

  myPackage = pkgs.stdenv.mkDerivation {
    pname = "my-package";
    version = "1.0";
    src = ./.;

    # Build-machine tools: compiled/run during the build only.
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.clang
    ];

    # Host libraries the output links against become runtime references.
    buildInputs = [ pkgs.openssl ];

    # Split development-only files out of `out` so installing the package does
    # not deploy headers or static archives.
    outputs = [
      "out"
      "dev"
      "doc"
    ];
    postInstall = ''
      moveToOutput "include" "$dev"
      moveToOutput "share/doc" "$doc"
      moveToOutput "lib/*.a" "$dev"
    '';
  };
in {
  # ${hello} closure ≈ hello + bash + coreutils (+ glibc).
  # ${myPackage} `out` closure ≈ myPackage + openssl (+ glibc); cmake/clang absent.
  #
  # Verify with:
  #   nix path-info -rsSh ${myPackage} | grep -E 'openssl|cmake|clang'
}
```

A "minimal builder" such as `writeShellApplication` is smaller in the store and
gives correct `runtimeInputs`, but the reason it is smaller is that its output
references only what the script needs — not because `stdenv` would otherwise be
dragged into every runtime closure.
