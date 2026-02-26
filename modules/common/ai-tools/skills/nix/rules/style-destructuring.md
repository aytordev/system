## Explicit Destructuring

**Impact:** HIGH

Always use explicit destructuring in function arguments. This makes dependencies self-documenting and tooling-friendly.

**Incorrect (Opaque Arguments):**

```nix
args:
args.stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0";

  src = args.fetchurl {
    url = "https://example.com/file.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  buildInputs = [ args.openssl args.zlib ];
}
```

**Correct (Self-Documenting):**

```nix
{
  stdenv,
  fetchurl,
  lib,
  openssl,
  zlib,
}:

stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0";

  src = fetchurl {
    url = "https://example.com/file.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  buildInputs = [
    openssl
    zlib
  ];

  meta = {
    description = "Example package";
    license = lib.licenses.mit;
  };
}
```
