{inputs}: let
  inherit (inputs.nixpkgs) lib;
  inherit
    (lib)
    mkOption
    types
    toUpper
    mkDefault
    mkForce
    ;
in rec {
  /**
  Resolve which aytordev shells are enabled and guard shell integration values.

  Upstream Home Manager programs.<tool>.*Integration options default to
  `home.shell.*` (true), so a tool would integrate into shells that are not
  even configured on the user. tie those integrations (and any tool that drops
  a Bash `conf.d` file) to `aytordev.programs.terminal.shells.enabledNames`.

  # Inputs

  `config`

  : 1\. Module config (the `config` argument of the importing module)

  # Returns

  `shellEnabled`

  : shell -> bool; whether the shell is enabled.

  `flags`

  : attrset with `enable{Bash,Fish,Zsh,Nushell}Integration` booleans, ready to
  merge into `programs.<tool>`.

  `whenShellEnabled`

  : shell -> value -> value; wraps a config value (e.g. `xdg.configFile`) with
  `lib.mkIf` so it only materializes when the shell is enabled.

  # Example

  ```nix
  let
    inherit (lib.aytordev) shellIntegration;
    si = shellIntegration config;
  in
    { programs.zoxide = { enable = true; options = ["--cmd cd"]; } // si.flags; }
  ```
  */
  shellIntegration = config: let
    enabledNames = config.aytordev.programs.terminal.shells.enabledNames or [];
    shellEnabled = shell: builtins.elem shell enabledNames;
  in {
    inherit shellEnabled;

    flags = {
      enableBashIntegration = shellEnabled "bash";
      enableFishIntegration = shellEnabled "fish";
      enableZshIntegration = shellEnabled "zsh";
      enableNushellIntegration = shellEnabled "nushell";
    };

    whenShellEnabled = shell: lib.mkIf (shellEnabled shell);
  };

  /**
  Resolve the effective theme integration for one application.

  Precedence: explicit override > declared (official) integration > generated
  fallback > none. A declared integration that does not cover the requested
  variant is treated as broken and throws instead of silently falling back to
  the generated resource.

  # Inputs

  `app`

  : 1\. App id used in error messages.

  `variant`

  : 2\. Active variant name; selects the declared integration variant.

  `override`

  : Per-app override: `null` or `{mode = "auto";}` (auto), `{mode = "manual";
  id = "...";}` or a bare string (explicit), `{mode = "none";}` (opt out).

  `official`

  : Declared integration attrset for the app, or `null`.

  `generated`

  : Generated fallback id, or `null`.

  # Returns

  `{ kind, id, provenance?, variantProvenance?, source }`

  : `kind` is `explicit` | `official` | `generated` | `none`; `source` is
  `user` | `official` | `generated` | `none`. `provenance` and
  `variantProvenance` are present only for the `official` kind.

  # Example

  ```nix
  lib.aytordev.resolveApp {
    app = "ghostty";
    variant = "dragon";
    official = config.aytordev.theme.integrations.kanagawa.ghostty or null;
    generated = null;
  }
  ```
  */
  resolveApp = {
    app ? null,
    variant ? null,
    override ? null,
    official ? null,
    generated ? null,
  }: let
    label =
      if app == null
      then "app"
      else app;
    invalid = message: throw "theme integration '${label}': ${message}";

    resolution =
      if override == null
      then {mode = "auto";}
      else if lib.isString override
      then
        if override == ""
        then invalid "explicit override is an empty string"
        else {
          mode = "manual";
          id = override;
        }
      else if lib.isAttrs override
      then let
        mode = override.mode or "auto";
      in
        if mode == "auto"
        then {mode = "auto";}
        else if mode == "none"
        then {mode = "none";}
        else if mode == "manual"
        then let
          id = override.id or null;
        in
          if !(lib.isString id) || id == ""
          then invalid "manual override requires a non-empty string 'id'"
          else {
            mode = "manual";
            inherit id;
          }
        else invalid "unknown override mode (expected auto, manual or none), got '${toString mode}'"
      else invalid "override must be null, a string or an attrset";

    resolveOfficial = integration: let
      source = integration.source or null;
      variants = integration.variants or null;
      variantData =
        if lib.isAttrs variants && variant != null && lib.hasAttr variant variants
        then variants.${variant}
        else null;
      id =
        if lib.isAttrs variantData
        then variantData.id or null
        else null;
    in
      if !(lib.isAttrs integration)
      then invalid "declared integration is not an attrset"
      else if source == null
      then invalid "declared integration is missing 'source'"
      else if !(lib.isAttrs source) || !(source ? provenance)
      then invalid "declared integration is missing 'source.provenance'"
      else if !(lib.isAttrs variants)
      then invalid "declared integration is missing 'variants'"
      else if variantData == null
      then invalid "declared integration has no variant '${toString variant}'"
      else if !(lib.isString id) || id == ""
      then invalid "declared integration variant '${toString variant}' has no valid 'id'"
      else {
        kind = "official";
        inherit id;
        inherit (source) provenance;
        variantProvenance = variantData.variantProvenance or "official";
        source = "official";
      };
  in
    if resolution.mode == "manual"
    then {
      kind = "explicit";
      inherit (resolution) id;
      source = "user";
    }
    else if resolution.mode == "none"
    then {
      kind = "none";
      id = null;
      source = "none";
    }
    else if official != null
    then resolveOfficial official
    else if generated != null
    then {
      kind = "generated";
      id = generated;
      source = "generated";
    }
    else {
      kind = "none";
      id = null;
      source = "none";
    };

  /**
  Enable a module with optional configuration.

  # Inputs

  `module`

  : 1\. Function argument

  `config`

  : 2\. Function argument
  */
  enable = module: moduleConfig:
    moduleConfig
    // {
      imports = [module] ++ (moduleConfig.imports or []);
    };

  /**
  Conditionally enable modules based on system.

  # Inputs

  `system`

  : 1\. Function argument

  `modules`

  : 2\. Function argument
  */
  enableForSystem = system: modules:
    builtins.filter (
      mod: mod.systems or [] == [] || builtins.elem system (mod.systems or [])
    )
    modules;

  /**
  Create a module with common options.

  # Inputs

  `name`

  : Module name

  `description`

  : Module description

  `options`

  : Module options

  `config`

  : Module configuration
  */
  mkModule = {
    name,
    description ? "",
    options ? {},
    config ? {},
  }: let
    moduleConfig = config;
  in
    {
      config,
      lib,
      ...
    }: {
      options.aytordev.${name} = lib.mkOption {
        type = lib.types.submodule {
          options =
            {
              enable = lib.mkEnableOption description;
            }
            // options;
        };
        default = {};
      };

      config = lib.mkIf config.aytordev.${name}.enable moduleConfig;
    };

  # Migrated aytordev utilities
  # Option creation helpers

  /**
  Create a nixpkgs option.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument

  `description`

  : 3\. Function argument
  */
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  /**
  Create a nixpkgs option without a description.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument
  */
  mkOpt' = type: default: mkOpt type default null;

  /**
  Create a boolean nixpkgs option.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument

  `description`

  : 3\. Function argument
  */
  mkBoolOpt = mkOpt types.bool;

  /**
  Create a boolean nixpkgs option without a description.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument
  */
  mkBoolOpt' = mkOpt' types.bool;

  /**
  Standard enabled pattern.
  */
  enabled = {
    enable = true;
  };

  /**
  Standard disabled pattern.
  */
  disabled = {
    enable = false;
  };

  /**
  Capitalize a string.

  # Inputs

  `s`

  : 1\. Function argument
  */
  capitalize = s: let
    len = lib.stringLength s;
  in
    if len == 0
    then ""
    else (toUpper (lib.substring 0 1 s)) + (lib.substring 1 len s);

  /**
  Convert a boolean to a number.

  # Inputs

  `bool`

  : 1\. Function argument
  */
  boolToNum = bool:
    if bool
    then 1
    else 0;

  /**
  Apply mkDefault to all attributes in a set.

  # Inputs

  `set`

  : 1\. Function argument
  */
  default-attrs = lib.mapAttrs (_key: mkDefault);

  /**
  Apply mkForce to all attributes in a set.

  # Inputs

  `set`

  : 1\. Function argument
  */
  force-attrs = lib.mapAttrs (_key: mkForce);

  /**
  Apply default-attrs to nested attribute sets.

  # Inputs

  `set`

  : 1\. Function argument
  */
  nested-default-attrs = lib.mapAttrs (_key: default-attrs);

  /**
  Apply force-attrs to nested attribute sets.

  # Inputs

  `set`

  : 1\. Function argument
  */
  nested-force-attrs = lib.mapAttrs (_key: force-attrs);
}
