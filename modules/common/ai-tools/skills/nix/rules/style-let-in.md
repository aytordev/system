## Prefer let-in over rec

**Impact:** HIGH

Use `let-in` instead of `rec` attribute sets. `rec` can cause infinite recursion and shadowing issues. `let-in` provides clear separation of definitions and result.

**Incorrect (Recursive Cycle):**

```nix
rec {
  x = y;
  y = x;
  # This causes infinite recursion!
}
```

**Correct (Clear Separation):**

```nix
let
  version = "1.0";
  pname = "my-app";
in
{
  inherit pname version;
  fullName = "${pname}-${version}";

  # Dependencies are clear and evaluated in order
  buildCommand = "echo Building ${fullName}";
}
```
