# Overlay: migrate Zed's macOS bundle metadata to the cargo-bundle 0.12 schema
# and restrict the Darwin bundle format.
#
# nixpkgs zed-editor 1.23.2 renames [package.metadata.bundle-stable] to
# [package.metadata.bundle] but keeps the old cargo-bundle key names, so
# `cargo bundle` aborts on Darwin with "unknown field
# `osx_minimum_system_version`". Even with the keys migrated, the pinned
# installPhase runs a bare `cargo bundle --release`, which builds every
# bundle format and fails producing a .dmg because `hdiutil` is absent
# inside the sandbox. Upstream fixed both in nixpkgs 913a51e7e0
# (zed-editor 1.23.2 -> 1.24.2) by migrating the same three keys and
# building with `--format osx`; this applies the key migration in
# postPatch, where the section rename the pinned installPhase already
# performs stays untouched, and restricts the bundle format by rewriting
# the pinned installPhase.
#
# Retirement condition: nixos-unstable carries zed-editor 1.24.2 or newer.
_final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  zed-editor = prev.zed-editor.overrideAttrs (oldAttrs: {
    postPatch =
      (oldAttrs.postPatch or "")
      + ''
        substituteInPlace crates/zed/Cargo.toml \
          --replace-fail 'osx_minimum_system_version' 'osx.minimum_system_version' \
          --replace-fail 'osx_info_plist_exts' 'osx.info_plist_exts' \
          --replace-fail 'osx_url_schemes' 'osx.url_schemes'
      '';
    installPhase =
      builtins.replaceStrings
      ["cargo bundle --release | xargs"]
      ["cargo bundle --release --format osx | xargs"]
      oldAttrs.installPhase;
  });
}
