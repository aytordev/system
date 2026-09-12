# Kanagawa Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  ...
}: {
  name = "kanagawa";
  displayName = "Kanagawa";

  defaultVariant = "dragon";
  darkVariant = "dragon";
  lightVariant = "lotus";

  # Exact native resources the hybrid resolver can select, keyed by app id.
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

    # tmux: no upstream Kanagawa tmux resource exists, so no integration is
    # declared here. The tmux adapter generates a theme from the shared palette
    # (`modules/home/programs/terminal/tools/tmux/config.nix`, `renderConfig`),
    # which is the documented community/generated fallback for this family.

    # Official bat tmTheme, `extras/tmTheme/kanagawa.tmTheme`, pinned to the
    # same upstream commit the vendored ghostty confs originate from. It
    # declares the single name "Kanagawa" and covers only the wave palette, so
    # the integration is incomplete for dragon/lotus. The adapter vendors the
    # artifact, so it is `vendored` and hash-pinned.
    bat = {
      source = {
        provenance = "official-upstream";
        vendored = true;
        ref = {
          url = "https://github.com/rebelot/kanagawa.nvim";
          rev = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3";
          hash = "sha256-ohgKjj83XzUD/FmnAtQm9rJ2DXwsXJfbRxDbrUYyYcI=";
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
}
