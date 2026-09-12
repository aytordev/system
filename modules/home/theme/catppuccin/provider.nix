# Catppuccin Theme Provider
# Returns theme data conforming to the provider contract.
# Each variant is a self-contained file under variants/ exporting
# { isLight, rawColors, palette }.
{
  mkColor,
  transparent,
  ...
}: let
  # Official `catppuccin/*` port resources at concrete upstream revisions.
  # Reference-pinned ports declare no SRI hash (the adapter resolves its own
  # artifact from `source.ref`); ports whose artifact is copied into this repo
  # set `vendored = true` and pin the vendored artifact with a source-level hash.
  # Accent-taking ports use `mauve`, catppuccin/nix's global default accent, and
  # the id is the exact upstream artifact or name the app expects for that flavor.
  mkOfficial = {
    port,
    rev,
    variants,
    vendored ? false,
    hash ? null,
  }: {
    source =
      {
        provenance = "official-upstream";
        ref =
          {
            url = "https://github.com/catppuccin/${port}";
            inherit rev;
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
    complete = true;
    inherit variants;
  };
in {
  name = "catppuccin";
  displayName = "Catppuccin";

  defaultVariant = "mocha";
  darkVariant = "mocha";
  lightVariant = "latte";

  # Exact native resources the hybrid resolver can select, keyed by app id.
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

    # Official `catppuccin/tmux` plugin, pinned to the v2.1.3 release commit
    # (matching nixpkgs' `tmuxPlugins.catppuccin` 2.1.3). The plugin reads
    # `@catppuccin_flavor`, so each id is the lower-case flavour name.
    tmux = mkOfficial {
      port = "tmux";
      rev = "b2f219c00609ea1772bcfbdae0697807184743e4";
      variants = {
        latte.id = "latte";
        frappe.id = "frappe";
        macchiato.id = "macchiato";
        mocha.id = "mocha";
      };
    };

    # Official ports pinned to catppuccin/nix's `sources.json` revisions (or
    # the upstream HEAD for ports it does not package). The id is the resource
    # identifier for each flavor; accent-taking ports pin the `mauve` accent.
    starship = mkOfficial {
      port = "starship";
      rev = "5906cc369dd8207e063c0e6e2d27bd0c0b567cb8";
      variants = {
        latte.id = "catppuccin_latte";
        frappe.id = "catppuccin_frappe";
        macchiato.id = "catppuccin_macchiato";
        mocha.id = "catppuccin_mocha";
      };
    };

    yazi = mkOfficial {
      port = "yazi";
      rev = "d62802be39210ea10e54b3e3b09735c6cb9e57c1";
      vendored = true;
      hash = "sha256-g7kT58o1Wl0zxnGqOFiXFNeKdrhOtytMJcYI08+T0Yo=";
      variants = {
        latte.id = "catppuccin-latte-mauve";
        frappe.id = "catppuccin-frappe-mauve";
        macchiato.id = "catppuccin-macchiato-mauve";
        mocha.id = "catppuccin-mocha-mauve";
      };
    };

    bat = mkOfficial {
      port = "bat";
      rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
      vendored = true;
      hash = "sha256-OVVm8IzrMBuTa5HAd2kO+U9662UbEhVT8gHJnCvUqnc=";
      variants = {
        latte.id = "Catppuccin Latte";
        frappe.id = "Catppuccin Frappé";
        macchiato.id = "Catppuccin Macchiato";
        mocha.id = "Catppuccin Mocha";
      };
    };

    btop = mkOfficial {
      port = "btop";
      rev = "f437574b600f1c6d932627050b15ff5153b58fa3";
      vendored = true;
      hash = "sha256-THRpq5vaKCwf9gaso3ycC4TNDLZtBB5Ofh/tOXkfRkQ=";
      variants = {
        latte.id = "catppuccin_latte";
        frappe.id = "catppuccin_frappe";
        macchiato.id = "catppuccin_macchiato";
        mocha.id = "catppuccin_mocha";
      };
    };

    fzf = mkOfficial {
      port = "fzf";
      rev = "7508f8141286fb95249100a2b5325960320dcf32";
      variants = {
        latte.id = "catppuccin-fzf-latte";
        frappe.id = "catppuccin-fzf-frappe";
        macchiato.id = "catppuccin-fzf-macchiato";
        mocha.id = "catppuccin-fzf-mocha";
      };
    };

    eza = mkOfficial {
      port = "eza";
      rev = "70f805f6cc27fa5b91750b75afb4296a0ec7fec9";
      vendored = true;
      hash = "sha256-2NRBZxzWunhDGGxGyT9riW5BdunoRJi9Q2yD76FsG9U=";
      variants = {
        latte.id = "catppuccin-latte-mauve";
        frappe.id = "catppuccin-frappe-mauve";
        macchiato.id = "catppuccin-macchiato-mauve";
        mocha.id = "catppuccin-mocha-mauve";
      };
    };

    lazygit = mkOfficial {
      port = "lazygit";
      rev = "798ad2e75a11766e9ba50e76e59aea6a81eb4866";
      variants = {
        latte.id = "catppuccin-latte-mauve";
        frappe.id = "catppuccin-frappe-mauve";
        macchiato.id = "catppuccin-macchiato-mauve";
        mocha.id = "catppuccin-mocha-mauve";
      };
    };

    opencode = mkOfficial {
      port = "opencode";
      rev = "d5f409632e6294762925fae869ad0c96dc17cd8e";
      vendored = true;
      hash = "sha256-HMpDzaASeLa31tdXURCOBjcik/240TuBRePz4ps5Yrg=";
      variants = {
        latte.id = "catppuccin-latte-mauve";
        frappe.id = "catppuccin-frappe-mauve";
        macchiato.id = "catppuccin-macchiato-mauve";
        mocha.id = "catppuccin-mocha-mauve";
      };
    };

    zellij = mkOfficial {
      port = "zellij";
      rev = "be841efbfb0b914daecdc4d1cde242fee53781b2";
      vendored = true;
      hash = "sha256-ypGLYcz43vb7veND21OHMKrisUVldD+opOW8RQ8AANQ=";
      variants = {
        latte.id = "catppuccin-latte";
        frappe.id = "catppuccin-frappe";
        macchiato.id = "catppuccin-macchiato";
        mocha.id = "catppuccin-mocha";
      };
    };

    # Firefox Color theme titles generated by `catppuccin/firefox` (`Catppuccin
    # ${flavour} ${accent}`), pinned to the same source catppuccin/nix packages.
    firefox = mkOfficial {
      port = "firefox";
      rev = "1aa345a3312f0a649068418679ceb81a9c599d36";
      variants = {
        latte.id = "Catppuccin latte mauve";
        frappe.id = "Catppuccin frappe mauve";
        macchiato.id = "Catppuccin macchiato mauve";
        mocha.id = "Catppuccin mocha mauve";
      };
    };
  };

  variants = {
    latte = import ./variants/latte.nix {inherit mkColor transparent;};
    frappe = import ./variants/frappe.nix {inherit mkColor transparent;};
    macchiato = import ./variants/macchiato.nix {inherit mkColor transparent;};
    mocha = import ./variants/mocha.nix {inherit mkColor transparent;};
  };
}
