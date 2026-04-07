# Overlay: disable protonmail-bridge self-updater for Nix installations.
#
# The upstream Darwin updater (install_darwin.go) resolves os.Executable()
# to a Nix store path, walks up to /nix/store as the .app bundle root, and
# recursively copies the entire store (~15 GB) to $TMPDIR on every hourly
# update check. The partial directory is never cleaned up (~720 GB / 48 h).
#
# Fix: replace install_darwin.go with a no-op implementation. Nix manages
# package versions via nixos-rebuild / nix-darwin rebuild.
_final: prev: {
  protonmail-bridge = prev.protonmail-bridge.overrideAttrs (oldAttrs: {
    postPatch =
      (oldAttrs.postPatch or "")
      + ''
        cp ${./install_darwin.go} internal/updater/install_darwin.go
      '';
  });
}
