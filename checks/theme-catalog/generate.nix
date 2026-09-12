# Derive the theme support matrix (`docs/theme-support-matrix.md`) from the live
# provider registry and the inventory of consuming adapters.
#
# The official axis comes straight from `theme.integrations` (the single source
# of native-resource truth). The generated axis comes from `adapters` below: one
# entry per app that consumes `lib.aytordev.resolveApp` (or otherwise derives its
# theme from the shared palette). Each entry pins the adapter source on disk, so
# a renamed or removed adapter fails the generator loudly instead of leaving the
# catalog stale.
#
# Because every current adapter ships a generated fallback, `none` only appears
# for a family/variant that has neither an official resource nor a generated
# path; `{ mode = "none"; }` is the user-level opt-out.
{
  lib,
  theme,
}: let
  inherit
    (lib)
    concatMapStringsSep
    concatStringsSep
    ;

  # Consuming adapters, keyed by the app id used in provider `integrations`.
  # `generated` is the id/mechanism the adapter falls back to when no official
  # resource covers the active variant; `null` means the adapter has no
  # generated fallback. `path` is the adapter source that must exist on disk.
  adapters = [
    {
      id = "bat";
      generated = "aytordev";
      note = "Palette-generated tmTheme.";
      path = ../../modules/home/programs/terminal/tools/bat/config.nix;
    }
    {
      id = "btop";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/btop/config.nix;
    }
    {
      id = "delta";
      generated = "aytordev";
      note = "Palette-generated git-delta styles.";
      path = ../../modules/home/programs/terminal/tools/git/delta-theme.nix;
    }
    {
      id = "eza";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/eza/config.nix;
    }
    {
      id = "firefox";
      generated = "userChrome";
      note = "Exception: userChrome is generated from the palette every family; a declared id is a Firefox Color title, not a UI selection.";
      path = ../../modules/home/programs/desktop/browsers/firefox/default.nix;
    }
    {
      id = "fzf";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/fzf/config.nix;
    }
    {
      id = "ghostty";
      generated = "aytordev";
      note = "Palette-generated conf.";
      path = ../../modules/home/programs/terminal/emulators/ghostty/config.nix;
    }
    {
      id = "jankyborders";
      generated = "palette";
      note = "No upstream resource; consumes raw sketchybar-format palette roles.";
      path = ../../modules/home/services/jankyborders/theme.nix;
    }
    {
      id = "lazygit";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/lazygit/config.nix;
    }
    {
      id = "opencode";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/opencode/config.nix;
    }
    {
      id = "pi";
      generated = "aytordev";
      note = "No upstream resource; theme + banner ship with the gentle shell.";
      path = ../../modules/home/programs/terminal/tools/pi/config.nix;
    }
    {
      id = "sketchybar";
      generated = "palette";
      note = "No upstream resource; runtime family/variant picker (the only hot-reloading consumer).";
      path = ../../modules/home/programs/desktop/bars/sketchybar/theme.nix;
    }
    {
      id = "starship";
      generated = "aytordev";
      note = "Palette-generated palette.";
      path = ../../modules/home/programs/terminal/tools/starship/config.nix;
    }
    {
      id = "tmux";
      generated = "aytordev";
      note = "Palette-generated conf; catppuccin selects via @catppuccin_flavor.";
      path = ../../modules/home/programs/terminal/tools/tmux/config.nix;
    }
    {
      id = "vscode";
      generated = "aytordev-<family>-<variant>";
      note = "Palette-generated extension.";
      path = ../../modules/home/programs/desktop/editors/vscode/config.nix;
    }
    {
      id = "yazi";
      generated = "<family>-<variant>";
      note = "Palette-generated flavor.";
      path = ../../modules/home/programs/terminal/tools/yazi/config.nix;
    }
    {
      id = "zed";
      generated = "aytordev";
      note = "Palette-generated theme JSON.";
      path = ../../modules/home/programs/desktop/editors/zed/config.nix;
    }
    {
      id = "zellij";
      generated = "aytordev";
      note = "Palette-generated theme.";
      path = ../../modules/home/programs/terminal/tools/zellij/config.nix;
    }
  ];

  missingAdapters = builtins.filter (adapter: !(builtins.pathExists adapter.path)) adapters;

  adapterMap = lib.listToAttrs (map (adapter: lib.nameValuePair adapter.id adapter) adapters);

  families = builtins.attrNames theme.providers;
  appColumns = builtins.sort (a: b: a < b) (map (adapter: adapter.id) adapters);

  variantNames = family: builtins.attrNames theme.providers.${family}.variants;

  # The official axis: the family declares an integration for the app and that
  # integration covers the requested variant. Everything else is generated when
  # the adapter offers a fallback, or none.
  resolutionKind = app: family: variant: let
    integration = theme.integrations.${family}.${app} or null;
    covers = builtins.isAttrs integration && (integration.variants or {}) ? ${variant};
  in
    if covers
    then "official"
    else if adapterMap.${app}.generated != null
    then "generated"
    else "none";

  cell = app: family: variant: let
    kind = resolutionKind app family variant;
  in
    if kind == "official"
    then "O"
    else if kind == "generated"
    then "G"
    else "–";

  mdRow = cells: "| ${concatStringsSep " | " cells} |";
  mdTable = headers: rows:
    mdRow headers
    + "\n"
    + "| ${concatStringsSep " | " (map (_: "---") headers)} |"
    + "\n"
    + concatMapStringsSep "\n" mdRow rows;

  familyLabel = family: "${theme.providers.${family}.displayName} (${theme.providers.${family}.defaultVariant})";

  familyRows =
    map (
      family:
        [(familyLabel family)]
        ++ map (app: cell app family theme.providers.${family}.defaultVariant) appColumns
    )
    families;

  variantRows =
    lib.concatMap (
      family:
        map (
          variant:
            ["${theme.providers.${family}.displayName} ${variant}"]
            ++ map (app: cell app family variant) appColumns
        ) (variantNames family)
    )
    families;

  boolLabel = value:
    if value
    then "yes"
    else "no";

  officialRows =
    lib.concatMap (
      family:
        map (
          app: let
            integration = theme.integrations.${family}.${app};
            ref = integration.source.ref;
          in [
            theme.providers.${family}.displayName
            app
            integration.source.provenance
            (boolLabel (integration.source.vendored or false))
            (concatStringsSep ", " (builtins.attrNames integration.variants))
            "${ref.url} @ ${ref.rev}"
          ]
        ) (builtins.attrNames theme.integrations.${family})
    )
    families;

  generatedRows =
    map (adapter: [
      adapter.id
      adapter.generated
      adapter.note
    ])
    adapters;

  markdown = ''
    # Theme Support Matrix

    <!-- Generated by checks/theme-catalog/generate.nix. Do not edit manually. -->
    <!-- Regenerate with: bash checks/theme-catalog/regenerate.sh -->

    How each application resolves the active theme through the hybrid policy
    **explicit override > official exact > generated fallback > none**
    (see [theme-system.md](theme-system.md) and
    [ADR-0012](decisions/0012-theme-resolution-policy.md)).

    Legend: `O` = official resource, `G` = generated fallback, `–` = no
    resource (the app keeps its own default). Cells assume no per-app
    override.

    ## Family × app (default variant)

    ${mdTable (["Family"] ++ appColumns) familyRows}

    ## Variant coverage

    ${mdTable (["Family / variant"] ++ appColumns) variantRows}

    ## Official resources and provenance

    | Family | App | Provenance | Vendored | Covered variants | Pinned source |
    | --- | --- | --- | --- | --- | --- |
    ${concatStringsSep "\n" (map mdRow officialRows)}

    `official-upstream` is the theme project itself; `community-port` is a
    genuine third-party port. `Vendored` means the artifact is copied into this
    repo and hash-pinned; reference-pinned ports are resolved by their
    adapter.

    ## Generated fallbacks

    ${mdTable ["App" "Generated selection" "Notes"] generatedRows}
  '';
in
  if missingAdapters != []
  then
    throw ''
      theme-catalog: adapter source missing for: ${
        concatStringsSep ", " (map (adapter: "${adapter.id} (${toString adapter.path})") missingAdapters)
      }
    ''
  else {
    inherit markdown adapters;
  }
