# Kanagawa Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  capitalize,
}: {
  name = "kanagawa";
  displayName = "Kanagawa";

  defaultVariant = "dragon";
  darkVariant = "dragon";
  lightVariant = "lotus";

  # Exact native resources the hybrid resolver can select, keyed by app id.
  # `nativeApps` is derived from these keys (never hand-written).
  integrations = {
    # Vendored Ghostty confs, adapted from `extras/ghostty/kanagawa-*`. Each
    # variant's `hash` pins the in-repo artifact; `source.ref.rev` pins the
    # upstream commit the confs originate from.
    ghostty = {
      source = {
        provenance = "official-upstream";
        vendored = true;
        ref = {
          url = "https://github.com/rebelot/kanagawa.nvim";
          rev = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3";
          # Anchors the default variant (dragon); each variant below pins its own
          # file so a multi-artifact integration still hashes every resource.
          hash = "sha256-bywRkxLw3FS7Wm5REW3+Y52ARn/rD7uiNGBW0oz3bl8=";
        };
      };
      complete = true;
      variants = {
        wave = {
          id = "kanagawa-wave";
          hash = "sha256-evNOkf2MuVKdu28M0oeCd7ER/extG4Mot30JNLlq0fs=";
        };
        dragon = {
          id = "kanagawa-dragon";
          hash = "sha256-bywRkxLw3FS7Wm5REW3+Y52ARn/rD7uiNGBW0oz3bl8=";
        };
        lotus = {
          id = "kanagawa-lotus";
          hash = "sha256-eGOqYcxxdneuhtJ40F8LlF00pKQEOG4xQwtchcn8NrA=";
        };
      };
    };

    # Zed `kanagawa-themes` extension. `id` is the theme label the extension
    # publishes; `rev` is the commit pinned by the Zed extension registry.
    # No content hash: Zed resolves and installs the extension itself, so there
    # is no artifact we fetch or address here.
    zed = {
      source = {
        provenance = "community-port";
        ref = {
          url = "https://github.com/ethangilmore/zed-kanagawa";
          rev = "45b4295e708a5720d75514013a20a00917d50cc5";
        };
      };
      complete = true;
      variants = {
        wave = {
          id = "Kanagawa Wave";
        };
        dragon = {
          id = "Kanagawa Dragon";
        };
        lotus = {
          id = "Kanagawa Lotus";
        };
      };
    };

    # VS Code Marketplace extension. The marketplace listing is the source of
    # truth: `rev` is the pinned extension version and `hash` is the SRI of the
    # published VSIX (mirrored in vscode/default.nix `mktplcRef`).
    vscode = {
      source = {
        provenance = "community-port";
        ref = {
          url = "https://marketplace.visualstudio.com/items?itemName=metaphore.kanagawa-vscode-color-theme";
          rev = "0.5.0";
          hash = "sha256-Os4v1zXnr+WLXyvjS8qgf3UOJHGd4lmCczjVaCArXtA=";
        };
      };
      complete = true;
      variants = {
        wave = {
          id = "Kanagawa Wave";
        };
        dragon = {
          id = "Kanagawa Dragon";
        };
        lotus = {
          id = "Kanagawa Lotus";
        };
      };
    };

    # tmux via the ukiyo plugin, which parses `theme/variant`. `rev` and `hash`
    # are the nixpkgs-pinned ukiyo source (see pkgs/misc/tmux-plugins).
    tmux = {
      source = {
        provenance = "community-port";
        ref = {
          url = "https://github.com/Nybkox/tmux-ukiyo";
          rev = "dd8730a2a41da79425c11c0cea69e0bd81545e19";
          hash = "sha256-jOcGNKb8QrIgT7l3D3RiJOPIC9JU1rOy8tk0x5ULrdc=";
        };
      };
      complete = true;
      variants = {
        wave = {
          id = "kanagawa/wave";
        };
        dragon = {
          id = "kanagawa/dragon";
        };
        lotus = {
          id = "kanagawa/lotus";
        };
      };
    };

    # Official bat tmTheme, `extras/tmTheme/kanagawa.tmTheme`, pinned to the
    # same upstream commit the vendored ghostty confs originate from. It
    # declares the single name "Kanagawa" and covers only the wave palette, so
    # the integration is incomplete for dragon/lotus. Reference-pinned, not
    # vendored here: no SRI hash.
    bat = {
      source = {
        provenance = "official-upstream";
        ref = {
          url = "https://github.com/rebelot/kanagawa.nvim";
          rev = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3";
        };
      };
      complete = false;
      variants.wave.id = "Kanagawa";
    };
  };

  variants = {
    wave = import ./variants/wave.nix {inherit mkColor transparent;};
    dragon = import ./variants/dragon.nix {inherit mkColor transparent;};
    lotus = import ./variants/lotus.nix {inherit mkColor transparent;};
  };

  # App theme name formatting per variant
  appTheme = variant: {
    capitalized = "Kanagawa ${capitalize variant}";
    kebab = "kanagawa-${variant}";
    underscore = "kanagawa_${variant}";
    raw = "kanagawa/${variant}";
  };
}
