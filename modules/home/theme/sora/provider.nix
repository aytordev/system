# Sora Theme Provider
# Returns theme data conforming to the provider contract.
# Sora ships only a dark palette; the light variant is a local synthetic
# companion (see variants/light.nix).
{
  mkColor,
  transparent,
  ...
}: {
  name = "sora";
  displayName = "Sora";

  defaultVariant = "dark";
  darkVariant = "dark";
  lightVariant = "light";

  # Exact native resources the hybrid resolver can select, keyed by app id.
  # Sora is dark-only, so both integrations are `complete = false` with a single
  # `dark` variant. Consumers fall through to generated (Ghostty) or none (Zed)
  # for the synthetic `light` companion. `nativeApps` is derived, not authored.
  integrations = {
    # Vendored `themes/sora.conf` (adapted from `extras/ghostty/sora`). The
    # variant `hash` pins the in-repo artifact; the rev pins the upstream origin.
    ghostty = {
      source = {
        provenance = "official-upstream";
        vendored = true;
        ref = {
          url = "https://github.com/Aejkatappaja/sora";
          rev = "504df4913c55dd9ad658e331b172f86b0537b439";
          hash = "sha256-wnmkZiqBdebcgqr6KZKIsg3q6sp0CrMhwdyw98eYTyE=";
        };
      };
      complete = false;
      variants = {
        dark = {
          id = "sora";
          hash = "sha256-wnmkZiqBdebcgqr6KZKIsg3q6sp0CrMhwdyw98eYTyE=";
        };
      };
    };

    # Zed `sora-theme` extension at its registry-pinned commit. The extension
    # ships one dark theme named "Sora"; there is no light resource.
    zed = {
      source = {
        provenance = "official-upstream";
        ref = {
          url = "https://github.com/Aejkatappaja/sora";
          rev = "823a786dfea9f2b04e729cdd9ad7f33ecec621c7";
        };
      };
      complete = false;
      variants = {
        dark = {
          id = "Sora";
        };
      };
    };
  };

  variants = {
    dark = import ./variants/dark.nix {inherit mkColor transparent;};
    light = import ./variants/light.nix {inherit mkColor transparent;};
  };

  # Sora ships a single native theme name, independent of the (synthetic) variant.
  appTheme = _: {
    capitalized = "Sora";
    kebab = "sora";
    underscore = "sora";
    raw = "sora";
  };
}
