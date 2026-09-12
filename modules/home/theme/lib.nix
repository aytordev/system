# Theme Library Functions
# Generic helpers for color format conversion and provider validation.
{lib}: let
  inherit (lib) stringToCharacters removePrefix;

  hexDigits = "0123456789abcdef";

  # Hex digit to integer lookup table
  hexDigitToInt = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };

  # Convert a hex string (e.g. "1f") to an integer
  hexToInt = s: lib.foldl' (acc: c: acc * 16 + hexDigitToInt.${c}) 0 (stringToCharacters s);

  # Render a 0-255 integer as a two-digit lowercase hex byte.
  toHexByte = n: let
    hi = n / 16;
    lo = n - hi * 16;
  in "${builtins.substring hi 1 hexDigits}${builtins.substring lo 1 hexDigits}";

  # Parse and validate a `#RRGGBB` or `#RRGGBBAA` literal.
  parseHex = value: let
    raw = removePrefix "#" value;
    length = lib.stringLength raw;
    wellFormed = builtins.match "[0-9a-fA-F]+" raw != null;
  in
    if !(lib.hasPrefix "#" value)
    then throw "theme.mkColor: expected '#RRGGBB' or '#RRGGBBAA', got '${value}'"
    else if length != 6 && length != 8
    then throw "theme.mkColor: expected '#RRGGBB' or '#RRGGBBAA', got '${value}'"
    else if !wellFormed
    then throw "theme.mkColor: '${value}' contains non-hexadecimal characters"
    else {
      red = hexToInt (builtins.substring 0 2 raw);
      green = hexToInt (builtins.substring 2 2 raw);
      blue = hexToInt (builtins.substring 4 2 raw);
      alpha =
        if length == 8
        then hexToInt (builtins.substring 6 2 raw)
        else 255;
      inherit raw;
    };

  # Provider fields every theme family must publish.
  requiredProviderFields = [
    "name"
    "displayName"
    "defaultVariant"
    "darkVariant"
    "lightVariant"
    "variants"
    "appTheme"
  ];

  # Allowed provenance markers for a declared app integration source.
  integrationProvenanceValues = [
    "official-upstream"
    "community-port"
  ];

  # Allowed provenance markers for a declared integration variant.
  variantProvenanceValues = [
    "official"
    "synthetic"
  ];

  # Validate a provider attrset against the shared contract.
  # Returns the provider unchanged, except that `nativeApps` is always projected
  # from the keys of `integrations` (the single source of native-resource truth).
  # A hand-authored `nativeApps`, if present, must equal those keys exactly.
  # Throws with every discovered problem otherwise.
  validateProvider = provider: let
    missingFields = builtins.filter (field: !(provider ? ${field})) requiredProviderFields;
    variants = provider.variants or {};
    variantNames = builtins.attrNames variants;

    checkVariantRef = field: let
      value = provider.${field} or null;
    in
      if value == null
      then "missing '${field}'"
      else if !(builtins.hasAttr value variants)
      then "'${field}' = '${value}' is not one of [${lib.concatStringsSep " " variantNames}]"
      else null;

    checkPolarity = field: expected: let
      value = provider.${field} or null;
      variant = variants.${value} or null;
    in
      if variant == null
      then null
      else if variant.isLight != expected
      then "'${field}' must have isLight = ${lib.boolToString expected}"
      else null;

    # ─── Per-app integration contract ─────────────────────────────────────
    # `integrations` is the single source of native-resource truth.
    # integrations.<app> = {
    #   source = { provenance; vendored ?= false; ref = {url; rev; hash?;}; };
    #   complete ?= true;
    #   variants.<variant> = {
    #     id;
    #     hash;  # required when source.vendored
    #     variantProvenance ?= "official"|"synthetic";
    #   };
    # }

    # `nativeApps` is a read-only projection of the integration keys. A provider
    # must not hand-author it; if present it must equal the keys exactly. This
    # is the strict invariant: no subset/superset/union relaxation.
    integrations = provider.integrations or null;
    nativeAppsDerived =
      if builtins.isAttrs integrations
      then builtins.attrNames integrations
      else [];
    declaredNativeApps = provider.nativeApps or null;
    nativeAppsError =
      if declaredNativeApps == null
      then null
      else if !(builtins.isList declaredNativeApps)
      then "'nativeApps' must be a list of app ids, or omitted (it is derived from 'integrations')"
      else if !(builtins.all builtins.isString declaredNativeApps)
      then "'nativeApps' entries must be strings"
      else if builtins.sort (a: b: a < b) declaredNativeApps != builtins.sort (a: b: a < b) nativeAppsDerived
      then "'nativeApps' is derived from 'integrations' and must equal [${lib.concatStringsSep " " nativeAppsDerived}] exactly"
      else null;

    checkIntegrationSource = app: source:
      if !(builtins.isAttrs source)
      then "integrations.${app}.source must be an attrset"
      else if (source ? vendored) && !(builtins.isBool source.vendored)
      then "integrations.${app}.source.vendored must be a boolean"
      else if !(source ? provenance)
      then "integrations.${app}.source is missing 'provenance'"
      else if !(builtins.elem source.provenance integrationProvenanceValues)
      then "integrations.${app}.source.provenance '${toString source.provenance}' is not one of [${lib.concatStringsSep " " integrationProvenanceValues}]"
      else let
        ref = source.ref or null;
      in
        if !(builtins.isAttrs ref)
        then "integrations.${app}.source.ref must be an attrset"
        else if !(ref ? url) || !(builtins.isString ref.url) || ref.url == ""
        then "integrations.${app}.source.ref.url must be a non-empty string"
        else if !(ref ? rev) || !(builtins.isString ref.rev) || ref.rev == ""
        then "integrations.${app}.source.ref.rev must be a non-empty string (pin a concrete revision)"
        else if (ref ? hash) && (!(builtins.isString ref.hash) || ref.hash == "")
        then "integrations.${app}.source.ref.hash must be a non-empty string when present"
        else if (source.vendored or false) && !(ref ? hash)
        then "integrations.${app}.source.ref.hash is required for a vendored resource"
        else null;

    checkIntegrationVariant = app: variant: data:
      if !(builtins.isAttrs data)
      then "integrations.${app}.variants.${variant} must be an attrset"
      else if !(data ? id)
      then "integrations.${app}.variants.${variant} is missing 'id'"
      else if !(builtins.isString data.id) || data.id == ""
      then "integrations.${app}.variants.${variant}.id must be a non-empty string"
      else if (data ? hash) && (!(builtins.isString data.hash) || data.hash == "")
      then "integrations.${app}.variants.${variant}.hash must be a non-empty SRI string when present"
      else if (data ? variantProvenance) && !(builtins.elem data.variantProvenance variantProvenanceValues)
      then "integrations.${app}.variants.${variant}.variantProvenance '${toString data.variantProvenance}' is not one of [${lib.concatStringsSep " " variantProvenanceValues}]"
      else null;

    checkIntegration = app: integration:
      if !(builtins.isAttrs integration)
      then ["integrations.${app} must be an attrset"]
      else let
        source = integration.source or null;
        vendored =
          if builtins.isAttrs source && (source ? vendored) && builtins.isBool source.vendored
          then source.vendored
          else false;
        integrationVariants = integration.variants or null;
        sourceError = checkIntegrationSource app source;
        variantsError =
          if !(builtins.isAttrs integrationVariants)
          then "integrations.${app}.variants must be an attrset"
          else null;
        variantEntries =
          if builtins.isAttrs integrationVariants
          then lib.mapAttrsToList (name: data: {inherit name data;}) integrationVariants
          else [];
        unknownVariantErrors = lib.map (
          entry: "integrations.${app}.variants.${entry.name} is not a provider variant"
        ) (builtins.filter (entry: !(builtins.elem entry.name variantNames)) variantEntries);
        variantFieldErrors = builtins.filter (error: error != null) (
          lib.map (entry: checkIntegrationVariant app entry.name entry.data) variantEntries
        );
        vendoredEmptyError =
          if vendored && variantEntries == []
          then "integrations.${app} is vendored but declares no variant with a hash"
          else null;
        complete = integration.complete or true;
        completeError =
          if !(builtins.isBool complete)
          then "integrations.${app}.complete must be a boolean"
          else if complete && builtins.isAttrs integrationVariants
          then let
            missingVariants = builtins.filter (name: !(integrationVariants ? ${name})) variantNames;
          in
            if missingVariants != []
            then "integrations.${app} is incomplete; missing variants: [${lib.concatStringsSep " " missingVariants}]"
            else null
          else null;
      in
        lib.optional (sourceError != null) sourceError
        ++ lib.optional (variantsError != null) variantsError
        ++ unknownVariantErrors
        ++ variantFieldErrors
        ++ lib.optional (vendoredEmptyError != null) vendoredEmptyError
        ++ lib.optional (completeError != null) completeError;

    integrationsErrors =
      if integrations == null
      then []
      else if !(builtins.isAttrs integrations)
      then ["'integrations' must be an attrset keyed by app id"]
      else lib.concatLists (lib.mapAttrsToList checkIntegration integrations);

    errors =
      lib.optional (
        missingFields != []
      ) "missing required fields: [${lib.concatStringsSep " " missingFields}]"
      ++ lib.optional (variantNames == []) "no variants defined"
      ++ lib.optional (nativeAppsError != null) nativeAppsError
      ++ lib.optionals (missingFields == []) (
        lib.filter (error: error != null) (
          map checkVariantRef [
            "defaultVariant"
            "darkVariant"
            "lightVariant"
          ]
          ++ [
            (checkPolarity "darkVariant" false)
            (checkPolarity "lightVariant" true)
          ]
        )
      )
      ++ integrationsErrors;
  in
    if errors != []
    then throw "theme provider '${provider.name or "<unnamed>"}' is invalid: ${lib.concatStringsSep "; " errors}"
    else
      provider
      // {
        nativeApps = nativeAppsDerived;
      };
in {
  inherit validateProvider;

  # Create a color attrset from a hex literal (#RRGGBB or #RRGGBBAA).
  # Derives all output formats from the single hex value.
  mkColor = value: let
    parsed = parseHex value;
    rgbHex = builtins.substring 0 6 parsed.raw;
    opaque = parsed.alpha == 255;
  in {
    hex = "#${parsed.raw}";
    inherit (parsed) raw;
    rgb =
      if opaque
      then "rgb(${toString parsed.red}, ${toString parsed.green}, ${toString parsed.blue})"
      else "rgba(${toString parsed.red}, ${toString parsed.green}, ${toString parsed.blue}, ${
        if parsed.alpha == 0
        then "0"
        else toString (parsed.alpha / 255.0)
      })";
    sketchybar = "0x${toHexByte parsed.alpha}${rgbHex}";
  };

  # Transparent color (special case — 8-digit hex with zero alpha)
  transparent = {
    hex = "#00000000";
    rgb = "rgba(0, 0, 0, 0)";
    sketchybar = "0x00000000";
    raw = "00000000";
  };

  # Capitalize first letter of a string
  capitalize = s: let
    len = lib.stringLength s;
  in
    if len == 0
    then ""
    else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 len s);
}
