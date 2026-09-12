# Catppuccin Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  capitalize,
}: {
  name = "catppuccin";
  displayName = "Catppuccin";

  defaultVariant = "mocha";
  darkVariant = "mocha";
  lightVariant = "latte";

  # Exact native resources the hybrid resolver can select, keyed by app id.
  # `nativeApps` is derived from these keys (never hand-written).
  integrations = {
    # Vendored Ghostty confs (adapted from `themes/catppuccin-*.conf`). Each
    # variant's `hash` pins the in-repo artifact; `source.ref.rev` pins the
    # upstream commit the confs originate from.
    ghostty = {
      source = {
        provenance = "official-upstream";
        vendored = true;
        ref = {
          url = "https://github.com/catppuccin/ghostty";
          rev = "b0b03ccee7ae8f16b13bd4fdfe267616defdb2b7";
          # Anchors the default variant (mocha); each variant below pins its own
          # file so a multi-artifact integration still hashes every resource.
          hash = "sha256-Rq5MJA/5aLadhS+5SXYZyjes2TR6xF5i+nCkS3OkHWE=";
        };
      };
      complete = true;
      variants = {
        latte = {
          id = "catppuccin-latte";
          hash = "sha256-q6oRz2lMa17Nm9dBvr0Jj524RPXl/AV4t4M5nz1JWhw=";
        };
        frappe = {
          id = "catppuccin-frappe";
          hash = "sha256-EAvI51e8MLL2arp2FWX5gz/eUVrRWqQ/2HnNkzlqdxA=";
        };
        macchiato = {
          id = "catppuccin-macchiato";
          hash = "sha256-e8iGejmpjyDKM8ciaoAwQgKEqJP9z9Y5NFs8U3t9Ytc=";
        };
        mocha = {
          id = "catppuccin-mocha";
          hash = "sha256-Rq5MJA/5aLadhS+5SXYZyjes2TR6xF5i+nCkS3OkHWE=";
        };
      };
    };

    # Zed `catppuccin` extension. `rev` is the registry-pinned release
    # (v0.2.26). No content hash: Zed installs the extension itself.
    zed = {
      source = {
        provenance = "official-upstream";
        ref = {
          url = "https://github.com/catppuccin/zed";
          rev = "9e24b02f32ca6bba7ac0cfb1bf758b1ccd8ee5cb";
        };
      };
      complete = true;
      variants = {
        latte = {
          id = "Catppuccin Latte";
        };
        frappe = {
          id = "Catppuccin Frappé";
        };
        macchiato = {
          id = "Catppuccin Macchiato";
        };
        mocha = {
          id = "Catppuccin Mocha";
        };
      };
    };

    # VS Code Catppuccin extension, pinned to the upstream release tag v3.9.0.
    # No content hash: nixpkgs builds and hashes the extension; the integration
    # only selects a theme label.
    vscode = {
      source = {
        provenance = "official-upstream";
        ref = {
          url = "https://github.com/catppuccin/vscode";
          rev = "55b3e5d6248eb201c0e16424ce6f345757e94bad";
        };
      };
      complete = true;
      variants = {
        latte = {
          id = "Catppuccin Latte";
        };
        frappe = {
          id = "Catppuccin Frappé";
        };
        macchiato = {
          id = "Catppuccin Macchiato";
        };
        mocha = {
          id = "Catppuccin Mocha";
        };
      };
    };

    # tmux via ukiyo `theme/variant`, pinned to the nixpkgs ukiyo source.
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
        latte = {
          id = "catppuccin/latte";
        };
        frappe = {
          id = "catppuccin/frappe";
        };
        macchiato = {
          id = "catppuccin/macchiato";
        };
        mocha = {
          id = "catppuccin/mocha";
        };
      };
    };
  };

  variants = {
    latte = import ./variants/latte.nix {inherit mkColor transparent;};
    frappe = import ./variants/frappe.nix {inherit mkColor transparent;};
    macchiato = import ./variants/macchiato.nix {inherit mkColor transparent;};
    mocha = import ./variants/mocha.nix {inherit mkColor transparent;};
  };

  # App theme name formatting per variant
  appTheme = variant: {
    # Upstream ships the accented "Frappé" label in Zed and VS Code.
    capitalized = "Catppuccin ${
      if variant == "frappe"
      then "Frappé"
      else capitalize variant
    }";
    kebab = "catppuccin-${variant}";
    underscore = "catppuccin_${variant}";
    raw = "catppuccin/${variant}";
  };
}
