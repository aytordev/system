# Sora Theme Provider
# Returns theme data conforming to the provider contract.
# Sora ships only a dark palette; the light variant is a local synthetic
# companion (see variants/light.nix).
{
  mkColor,
  transparent,
  ...
}: let
  # Official Sora extras, pinned to the single upstream commit that ships
  # `extras/`. Integrations whose adapter copies the artifact into this repo
  # (`yazi`, `tmux`, `bat`, `btop`, `opencode`) set `vendored = true` and pin it
  # with a hash; the rest are reference-pinned (the adapter resolves its own
  # artifact from `source.ref`). Sora ships only a dark resource, so every
  # integration stays incomplete for the synthetic `light` companion.
  soraRev = "504df4913c55dd9ad658e331b172f86b0537b439";
  mkSoraDark = {
    id,
    vendored ? false,
    hash ? null,
  }: {
    source =
      {
        provenance = "official-upstream";
        ref =
          {
            url = "https://github.com/Aejkatappaja/sora";
            rev = soraRev;
          }
          // (
            if hash != null
            then {inherit hash;}
            else {}
          );
      }
      // (
        if vendored
        then {vendored = true;}
        else {}
      );
    complete = false;
    variants.dark.id = id;
  };
in {
  name = "sora";
  displayName = "Sora";

  defaultVariant = "dark";
  darkVariant = "dark";
  lightVariant = "light";

  # Exact native resources the hybrid resolver can select, keyed by app id.
  # Sora is dark-only, so every integration is `complete = false` with a single
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
          # Registry-pinned `sora-theme` release commit. (A prior revision had a
          # typo -- `...33ecec621c7` -- which resolved to no upstream commit.)
          rev = "823a786dfea9f2b04e729cdd9ad7f33ecee621c7";
        };
      };
      complete = false;
      variants = {
        dark = {
          id = "Sora";
        };
      };
    };

    # Reference-pinned official extras. Each `id` is the name the app expects:
    # Starship palette, Yazi theme stem, bat tmTheme name, btop theme name, fzf
    # / eza / lazygit / opencode resource stem, Firefox Color manifest name. The
    # tmux conf is vendored (`extras/tmux/sora.tmux.conf`) and its hash pins the
    # in-repo artifact; the adapter sources it.
    starship = mkSoraDark {id = "sora";};
    yazi = mkSoraDark {
      id = "sora";
      vendored = true;
      hash = "sha256-i7PMvLhpQ+JPIXsV53xU/TVCox/Q+jJQkmOx6T0SCjw=";
    };
    bat = mkSoraDark {
      id = "Sora";
      vendored = true;
      hash = "sha256-vqlNSPIS30z0U0oXZ/neJm2WkGrDz30wrHoBSZBSooE=";
    };
    btop = mkSoraDark {
      id = "sora";
      vendored = true;
      hash = "sha256-CcHi7rRHnbQWHMcD/GVTy1CaiytVjFf6tpo/nBbSM4g=";
    };
    fzf = mkSoraDark {id = "sora";};
    eza = mkSoraDark {id = "sora";};
    lazygit = mkSoraDark {id = "sora";};
    opencode = mkSoraDark {
      id = "sora";
      vendored = true;
      hash = "sha256-bMx6/tgeJSzmyD0RRLS0tzAeHertEy9h/1sWSYVXa+4=";
    };
    tmux = mkSoraDark {
      id = "sora";
      vendored = true;
      hash = "sha256-ePb+D4kuHHOFMyS795BMkAxswpFz/1scIvf+B4x7JLs=";
    };
    firefox = mkSoraDark {id = "Sora";};
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
