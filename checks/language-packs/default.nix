# Contract check for the language catalog and every Home language pack.
#
# The motivating bug: `modules/common/languages/node.nix` omitted its `editor`
# key while its pack read `editor.vscode.extensions`, and neither parsing nor
# the catalog unit tests reached the pack body, so only evaluating a real home
# caught it. This check therefore EVALUATES every pack, not just the catalog
# data.
#
# See ADR-0018 (docs/decisions/0018-language-pack-class.md).
{
  lib,
  pkgs,
  ...
}: let
  # Import the real catalog, the same plain-file import every consumer uses.
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};

  packsDir = ../../modules/home/languages;

  # Discover packs from the filesystem so a new pack is covered automatically.
  packNames =
    lib.filter (name: builtins.pathExists (packsDir + "/${name}/default.nix"))
    (builtins.attrNames (builtins.readDir packsDir));

  # WHY: the catalog is the shared data contract for packs and dev shells, so a
  # broken entry would break every consumer. Each violation is a readable
  # string so one run reports everything that is wrong at once.
  catalogViolations =
    lib.concatLists
    (lib.mapAttrsToList (
        name: lang: let
          hasExtensions = lib.hasAttrByPath ["editor" "vscode" "extensions"] lang;
          versionsIsList = builtins.isList (lang.versions or null);
          functionsOk =
            builtins.isFunction (lang.runtime or null)
            && builtins.isFunction (lang.toolchain or null);
          # An unversioned language must default to null; a versioned one must
          # pick a default that exists, or a pack would fail on its enum default.
          defaultVersionOk =
            if !versionsIsList
            then true # already reported; do not pile on
            else if lang.versions == []
            then (lang.defaultVersion or null) == null
            else builtins.elem (lang.defaultVersion or null) lang.versions;

          # Probe every declared version, and null for an unversioned language:
          # the pack passes null exactly when `versions` is empty.
          probedVersions =
            if functionsOk && versionsIsList
            then
              if lang.versions == []
              then [null]
              else lang.versions
            else [];

          # tryEval keeps one broken entry from aborting the whole check, so the
          # throw surfaces as a listed violation instead of an opaque trace.
          versionViolations =
            lib.concatMap (
              version: let
                label =
                  if version == null
                  then "null"
                  else toString version;
                runtime = builtins.tryEval (lang.runtime version);
                toolchain = builtins.tryEval (lang.toolchain version);
              in
                (lib.optionals (!runtime.success) ["${name}: runtime throws for version ${label}"])
                ++ (lib.optionals
                  (runtime.success && (!(builtins.isList runtime.value) || runtime.value == []))
                  ["${name}: runtime must return a non-empty list for version ${label}"])
                ++ (lib.optionals (!toolchain.success) ["${name}: toolchain throws for version ${label}"])
                ++ (lib.optionals
                  (runtime.success
                    && toolchain.success
                    && (!(builtins.isList toolchain.value)
                      || builtins.length toolchain.value < builtins.length runtime.value))
                  ["${name}: toolchain must be at least as long as runtime for version ${label}"])
            )
            probedVersions;
        in
          (lib.optionals (!functionsOk) ["${name}: runtime and toolchain must be functions"])
          ++ (lib.optionals (!versionsIsList) ["${name}: versions must be a list"])
          ++ (lib.optionals (!defaultVersionOk) ["${name}: defaultVersion must be null exactly when versions is empty, otherwise a member of versions"])
          ++ (lib.optional (!hasExtensions) "${name}: editor.vscode.extensions must be declared, even when empty, because a pack reads it unconditionally")
          ++ (lib.optionals
            (hasExtensions && !builtins.isList lang.editor.vscode.extensions)
            ["${name}: editor.vscode.extensions must be a list"])
          ++ versionViolations
      )
      catalog);

  # WHY: the options a pack writes, stubbed so `lib.evalModules` can
  # evaluate a pack in isolation without pulling in Home Manager.
  packStub = {
    options = {
      home.packages = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
      };
      aytordev.programs.desktop.editors.vscode.extraExtensions = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
      };
      aytordev.programs.desktop.editors.vscode.extraSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
      aytordev.programs.desktop.editors.zed.extraLanguages = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
    };
  };

  # Evaluate a pack the way a real home would: real pkgs and lib via
  # specialArgs, the pack directory imported as a module, and its `enable`
  # flag set explicitly. tryEval turns a throw (the original node bug) into a
  # listed violation instead of an aborted check.
  evalPack = name: enable:
    builtins.tryEval (let
      evaluated = lib.evalModules {
        specialArgs = {inherit pkgs lib;};
        modules = [
          packStub
          (packsDir + "/${name}")
          {aytordev.languages.${name}.enable = enable;}
        ];
      };
      # WHY: the lengths force the pack body (catalog reads included) without
      # deepSeq over derivations, which would drag package metadata into the
      # check.
      counts = {
        packages = lib.length evaluated.config.home.packages;
        extensions = lib.length evaluated.config.aytordev.programs.desktop.editors.vscode.extraExtensions;
      };
    in
      builtins.deepSeq counts counts);

  # WHY: the ADR records that a disabled language contributes nothing and an
  # enabled one installs its runtime, and a pack with no catalog entry would
  # silently define options no consumer reads.
  packViolations =
    lib.concatMap (
      name: let
        disabled = evalPack name false;
        enabled = evalPack name true;
        evalError = result:
          if result ? error
          then ": ${toString result.error}"
          else "";
      in
        (lib.optional (!(catalog ? ${name})) "${name}: pack has no catalog entry")
        ++ (lib.optionals (!disabled.success) ["${name}: disabled pack fails to evaluate${evalError disabled}"])
        ++ (lib.optionals
          (disabled.success && disabled.value.packages != 0)
          ["${name}: a disabled pack must contribute no packages"])
        ++ (lib.optionals
          (disabled.success && disabled.value.extensions != 0)
          ["${name}: a disabled pack must contribute no editor extensions"])
        ++ (lib.optionals (!enabled.success) ["${name}: enabled pack fails to evaluate${evalError enabled}"])
        ++ (lib.optionals
          (enabled.success && enabled.value.packages == 0)
          ["${name}: an enabled pack must install at least one package"])
    )
    packNames;

  violations = catalogViolations ++ packViolations;
in
  if violations == []
  then
    pkgs.runCommand "language-packs-check" {} ''
      echo "Checked ${
        toString (lib.attrNames catalog)
      } languages and ${toString packNames} language packs" > "$out"
    ''
  else throw "Language pack contract violations:\n${lib.concatStringsSep "\n" violations}"
