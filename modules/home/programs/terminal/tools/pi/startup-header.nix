{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.programs.terminal.tools.pi.startup-header;

  # Runtime config consumed by the extension through `config.json`, read as a
  # sibling of its entry point. `art` is published as a base file name because
  # the extension resolves it relative to its own directory.
  configJson = pkgs.writeText "startup-header-config.json" (builtins.toJSON {
    inherit (cfg) maxWidthCells maxHeightCells cadence disableGentlePiBanner;
    art = builtins.baseNameOf (toString cfg.art);
  });

  # One derivation, one directory: `index.ts`, the PNG and `config.json` are
  # published as siblings so a single directory symlink is a complete install.
  extensionDir = pkgs.linkFarm "pi-startup-header" [
    {
      name = "index.ts";
      path = ./startup-header/index.ts;
    }
    {
      name = builtins.baseNameOf (toString cfg.art);
      path = cfg.art;
    }
    {
      name = "config.json";
      path = configJson;
    }
  ];

  # Idempotent, surgical merge: rewrite only the `npm:gentle-pi` entry of the
  # `packages` array so it carries `extensions: ["!startup-banner.ts"]`. Any
  # other package, and every unrelated key, is preserved. A missing file, a
  # missing/unusable jq, or a `packages` value that is not an array all leave
  # the file untouched. The rewrite is guarded by a SEMANTIC comparison (`jq -S`)
  # so a formatting-only difference never rewrites the file: with the filter
  # already present the script is a true no-op regardless of how Pi formatted it.
  # This activation runs once per `darwin-switch`, but `settings.json` is a
  # runtime file that Pi, the Gentle AI installer and package installers rewrite.
  # A `packages` rewrite that drops the filter silently re-enables gentle-pi's
  # own banner, so the extension re-applies the same filter at setup time when
  # `disableGentlePiBanner` is on (`ensureGentlePiBannerFilter` in `index.ts`).
  # The activation stays authoritative; the runtime heal only closes the window
  # between two switches.
  mergeGentlePiBannerFilter = ''
    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    if [ ! -f "$settings" ]; then exit 0; fi
    jq_bin="${lib.getExe pkgs.jq}"
    if [ ! -x "$jq_bin" ]; then exit 0; fi

    tmp="$(mktemp "$settings.XXXXXX")" || exit 0
    if "$jq_bin" '
      if has("packages") and ((.packages | type) == "array") then
        .packages = [
          .packages[] |
          if (type == "string" and . == "npm:gentle-pi")
             or (type == "object" and .source == "npm:gentle-pi")
          then
            (if type == "object" then . else { source: "npm:gentle-pi" } end)
            | if ((.extensions // []) | index("!startup-banner.ts")) != null
              then .
              else . + { extensions: ((.extensions // []) + ["!startup-banner.ts"]) }
              end
          else .
          end
        ]
      else .
      end
    ' "$settings" > "$tmp"; then
      norm="$(mktemp "$settings.XXXXXX")" || exit 0
      "$jq_bin" -S . "$settings" > "$norm"
      if "$jq_bin" -S . "$tmp" | cmp -s - "$norm"; then
        $DRY_RUN_CMD rm -f "$tmp" "$norm"
      else
        $DRY_RUN_CMD rm -f "$norm"
        $DRY_RUN_CMD mv "$tmp" "$settings"
      fi
    else
      $DRY_RUN_CMD rm -f "$tmp"
    fi
  '';
in {
  # File-publication capability: no primary executable and no profile ownership.
  # It publishes one extension directory and, at most, patches one settings key.
  options.aytordev.programs.terminal.tools.pi.startup-header = {
    enable = mkEnableOption "the custom Pi startup header extension";

    art = lib.mkOption {
      type = lib.types.path;
      default = ./startup-header/pink-monster.png;
      description = "PNG rendered by the startup header.";
    };

    maxWidthCells = lib.mkOption {
      type = lib.types.int;
      default = 44;
      description = "Maximum image width in terminal cells.";
    };

    maxHeightCells = lib.mkOption {
      type = lib.types.int;
      default = 20;
      description = "Maximum image height in terminal cells.";
    };

    cadence = lib.mkOption {
      type = lib.types.enum ["quality" "performance" "off"];
      default = "quality";
      description = "Animated panel cadence: 80 ms, 250 ms, or static.";
    };

    disableGentlePiBanner = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Add the `!startup-banner.ts` extension filter to the `npm:gentle-pi`
        package so the built-in banner releases the single Pi header slot. The
        activation merges it, and the extension re-applies it at setup time when
        a later writer rewrites `settings.json` without it.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Single directory symlink: the extension, its art and its config resolve as
    # siblings. `settings.json` is deliberately NOT declared here: Pi and the
    # gentle-ai installer rewrite it at runtime, so a store symlink would break
    # both. The filter is merged by activation instead.
    home.file.".pi/agent/extensions/startup-header".source = extensionDir;

    home.activation.piStartupHeaderBannerFilter =
      mkIf cfg.disableGentlePiBanner
      (lib.hm.dag.entryAfter ["writeBoundary"] mergeGentlePiBannerFilter);
  };
}
