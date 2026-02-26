## Overlay Structure

**Impact:** HIGH

Use the `final:prev` naming convention for overlay arguments. `prev` is the original package set, `final` is the set after all overlays are applied.

**Incorrect (Deprecated names):**

Using `self:super` is deprecated and confusing.

```nix
{
  nixpkgs.overlays = [
    # Old naming convention - deprecated
    (self: super: {
      myPackage = super.myPackage.overrideAttrs (old: {
        version = "2.0.0";
        src = super.fetchurl {
          url = "https://example.com/mypackage-2.0.0.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000";
        };
      });

      # This is confusing - which "self" are we referring to?
      customTool = super.stdenv.mkDerivation {
        name = "custom-tool";
        buildInputs = [ self.myPackage ];
      };
    })
  ];
}
```

**Correct (Modern Naming):**

Use `prev` to reference the unmodified package, `final` when you need the fully composed set.

```nix
{
  nixpkgs.overlays = [
    # Modern naming convention - clear and explicit
    (final: prev: {
      myPackage = prev.myPackage.overrideAttrs (old: {
        version = "2.0.0";
        src = prev.fetchurl {
          url = "https://example.com/mypackage-2.0.0.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000";
        };
      });

      # Clear: we want the final version of myPackage (after all overlays)
      customTool = prev.stdenv.mkDerivation {
        name = "custom-tool";
        buildInputs = [
          final.myPackage  # Gets the overridden version
          prev.git         # Gets original version
        ];
      };
    })
  ];
}
```
