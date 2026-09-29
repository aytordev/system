# Pure snapshot integrity and composition; no module options, downloads or IFD.
{lib}: let
  validPointer = pointer:
    pointer.schema
    == 1
    && builtins.match "[0-9a-f]{40}-[0-9a-f]{64}" pointer.generation != null
    && builtins.match "[0-9a-f]{64}" pointer.manifest_sha256 != null;
  validAction = action:
    action
    == null
    || builtins.isString action
    || (builtins.isList action
      && builtins.length action == 2
      # Parameters have already been parsed as JSON; every JSON value is valid.
      && builtins.isString (builtins.head action));
  contextOf = entry: entry.context or null;
  # Also exposed to pure negative tests; callers must supply the consumed bytes.
  validate = {
    pointer,
    manifestText,
    profileText,
  }: let
    manifest = builtins.fromJSON manifestText;
    profile = builtins.fromJSON profileText;
    selectors = lib.concatMap (entry: map (chord: [(contextOf entry) chord]) (builtins.attrNames entry.bindings)) profile.keymap;
  in
    assert lib.assertMsg (validPointer pointer) "Zed snapshot: invalid relative generation identity";
    assert lib.assertMsg (builtins.hashString "sha256" manifestText == pointer.manifest_sha256) "Zed snapshot: manifest hash mismatch";
    assert lib.assertMsg (
      manifest.schema
      == 1
      && manifest.source.repository == "jellydn/zed-101-setup"
      && pointer.generation == "${manifest.source.revision}-${pointer.manifest_sha256}"
    ) "Zed snapshot: manifest identity/schema mismatch";
    assert lib.assertMsg (builtins.hashString "sha256" profileText == manifest.artifacts."profile.json") "Zed snapshot: profile hash mismatch";
    # This is audited provenance, not a runtime schema check or package pin.
    assert lib.assertMsg (
      manifest.target_version == "1.21.0" && profile.target_version == manifest.target_version
    ) "Zed snapshot: unaudited target version";
    assert lib.assertMsg (
      profile.schema
      == 1
      && builtins.attrNames profile == ["keymap" "schema" "settings" "target_version"]
      && builtins.isAttrs profile.settings
      && builtins.isList profile.keymap
      && builtins.all (
        entry:
          builtins.isAttrs entry
          && builtins.elem (builtins.attrNames entry) [["bindings"] ["bindings" "context"]]
          && (contextOf entry == null || builtins.isString entry.context)
          && builtins.isAttrs entry.bindings
          && builtins.all (chord: chord != "" && validAction entry.bindings.${chord}) (builtins.attrNames entry.bindings)
      )
      profile.keymap
      # Repeated contexts are valid, but selected context/chord collisions are not.
      && builtins.length selectors == builtins.length (lib.unique selectors)
    ) "Zed snapshot: invalid selected-profile schema"; profile;
  load = root: let
    pointer = builtins.fromJSON (builtins.readFile (root + "/snapshot.json"));
    # Check before constructing/reading any pointer-selected path.
    generation = assert lib.assertMsg (validPointer pointer) "Zed snapshot: invalid relative generation identity";
      root + "/snapshots/${pointer.generation}";
  in
    validate {
      inherit pointer;
      manifestText = builtins.readFile (generation + "/manifest.json");
      profileText = builtins.readFile (generation + "/profile.json");
    };
  upstream = load ./.;

  removePath = settings: path:
    assert path != []; let
      key = builtins.head path;
      rest = builtins.tail path;
    in
      if rest == []
      then builtins.removeAttrs settings [key]
      else if builtins.hasAttr key settings
      then settings // {${key} = removePath settings.${key} rest;}
      else settings;
  mergeBlock = blocks: next: let
    lastMatch = builtins.foldl' lib.max (-1) (lib.imap0 (index: entry:
      if contextOf entry == contextOf next
      then index
      else -1)
    blocks);
  in
    if lastMatch == -1
    then blocks ++ [next]
    else
      lib.imap0 (index: entry:
        if index == lastMatch
        then entry // {bindings = entry.bindings // next.bindings;}
        else if contextOf entry == contextOf next
        then entry // {bindings = builtins.removeAttrs entry.bindings (builtins.attrNames next.bindings);}
        else entry)
      blocks;
  compose = {
    source ? upstream,
    ownedSettings ? {},
    ownedKeymaps ? [],
    excludedSettings ? [],
    excludedBindings ? [],
  }: {
    # recursiveUpdate replaces lists; this is distinct from HM definition merging.
    settings = lib.recursiveUpdate (builtins.foldl' removePath source.settings excludedSettings) ownedSettings;
    # Keep every source block in place. Owned chords move to the LAST matching
    # block, removing earlier copies without changing intervening precedence.
    keymaps =
      builtins.foldl' mergeBlock (
        map (entry:
          entry
          // {
            bindings = builtins.removeAttrs entry.bindings (lib.concatMap (
                exclusion:
                  lib.optionals (contextOf entry == contextOf exclusion) exclusion.chords
              )
              excludedBindings);
          })
        source.keymap
      )
      ownedKeymaps;
  };
  # Lists are leaves. Do not descend into module-system priority wrappers.
  defaultLeaves = value:
    if builtins.isAttrs value && value ? _type
    then value
    else if builtins.isAttrs value
    then lib.mapAttrs (_: defaultLeaves) value
    else lib.mkDefault value;
in {
  inherit upstream load validate compose defaultLeaves;
}
