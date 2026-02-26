## Override Functions

**Impact:** HIGH

Use the right override function for the job. Never use `.overrideDerivation` (deprecated).

**Incorrect (overrideDerivation):**

This function is deprecated and should never be used.

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # DEPRECATED - do not use overrideDerivation
      myPackage = prev.myPackage.overrideDerivation (old: {
        buildInputs = old.buildInputs ++ [ prev.newDependency ];
      });
    })
  ];
}
```

**Correct (override vs overrideAttrs):**

`override` changes inputs, `overrideAttrs` changes derivation attributes.

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # Use .override to change function arguments (dependencies)
      # This replaces the openssl dependency with libressl
      nginxWithLibreSSL = prev.nginx.override {
        openssl = prev.libressl;
      };

      # Use .overrideAttrs to change derivation attributes (most common)
      # This adds patches, changes build inputs, modifies build phases, etc.
      patchedNginx = prev.nginx.overrideAttrs (old: {
        # Add custom patches
        patches = (old.patches or [ ]) ++ [
          ./custom-nginx.patch
        ];

        # Add build-time dependencies
        buildInputs = old.buildInputs ++ [
          prev.pcre2
        ];

        # Modify version string
        version = "${old.version}-custom";

        # Add post-install hook
        postInstall = (old.postInstall or "") + ''
          echo "Custom nginx build" > $out/share/doc/nginx/BUILD_INFO
        '';
      });
    })
  ];
}
```
